from flask import Flask, request, render_template_string, redirect, url_for, session
import subprocess
import os

app = Flask(__name__)
app.secret_key = 'super_secret_ctf_key'

# Credentials for the login (found in the Docker image)
VALID_USERNAME = "admin"
VALID_PASSWORD = "admin123" # The user cracks the hash in the docker image to get this 

LOGIN_HTML = """
<!DOCTYPE html>
<html>
<head><title>Internal Ping Tool</title></head>
<body>
    <h1>Restricted Access</h1>
    <p>Please login to use the ping tool.</p>
    <form action="/login" method="POST">
        <input type="text" name="username" placeholder="Username"><br>
        <input type="password" name="password" placeholder="Password"><br>
        <input type="submit" value="Login">
    </form>
    {% if error %}
    <p style="color:red">{{ error }}</p>
    {% endif %}
</body>
</html>
"""

TOOL_HTML = """
<!DOCTYPE html>
<html>
<head><title>Ping Tool</title></head>
<body>
    <h1>Server Connectivity Tester</h1>
    <p>Welcome, Admin.</p>
    <form action="/ping" method="POST">
        <input type="text" name="ip" placeholder="8.8.8.8">
        <input type="submit" value="Ping">
    </form>
    {% if result %}
    <h2>Output:</h2>
    <pre>{{ result }}</pre>
    {% endif %}
</body>
</html>
"""

@app.route('/', methods=['GET', 'POST'])
def login():
    if session.get('logged_in'):
        return redirect(url_for('ping_tool'))
        
    error = None
    if request.method == 'POST':
        user = request.form.get('username')
        pwd = request.form.get('password')
        if user == VALID_USERNAME and pwd == VALID_PASSWORD:
            session['logged_in'] = True
            return redirect(url_for('ping_tool'))
        else:
            error = "Invalid credentials"
            
    return render_template_string(LOGIN_HTML, error=error)

@app.route('/tool', methods=['GET'])
def ping_tool():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    return render_template_string(TOOL_HTML)

@app.route('/ping', methods=['POST'])
def ping():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
        
    ip = request.form.get('ip', '')
    
    # Advanced Challenge: Input Sanitization
    blacklist = [';', '&', '|', '`', ' ', '(', ')'] 
    # Allowed: $ { } < > / \ - .
    # Hint: BASH variable expansion for spaces: ${IFS}
    
    for char in blacklist:
        if char in ip:
            return render_template_string(TOOL_HTML, result=f"Security Alert: Invalid character '{char}' detected.")

    try:
        # VULNERABILITY HERE: IP is passed directly to shell
        # Bypass required for space and operators
        output = subprocess.check_output(f"ping -c 1 {ip}", shell=True, stderr=subprocess.STDOUT)
        return render_template_string(TOOL_HTML, result=output.decode('utf-8'))
    except subprocess.CalledProcessError as e:
        return render_template_string(TOOL_HTML, result=e.output.decode('utf-8'))
    except Exception as e:
        return render_template_string(TOOL_HTML, result=str(e))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
