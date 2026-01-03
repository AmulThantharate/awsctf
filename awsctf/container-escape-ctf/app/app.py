import os
import zipfile
from flask import Flask, request, render_template, send_file

app = Flask(__name__)
UPLOAD_FOLDER = '/tmp/uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/')
def index():
    page = request.args.get('page')
    if page:
        # LFI Vulnerability: No sanitization on 'page'
        # In a real scenario, this might need `render_template` if it's a template,
        # or `send_file` / `open().read()` if it's raw content.
        # For this CTF, let's just read the file content and display it.
        try:
            # Simple LFI
            with open(page, 'r') as f:
                content = f.read()
            return render_template('index.html', content=content)
        except Exception as e:
            return render_template('index.html', error=str(e))
    return render_template('index.html')

@app.route('/admin')
def admin():
    return "<h1>403 Forbidden</h1><p>You do not have permission to access /admin.</p>", 403

@app.route('/login')
def login():
    return render_template('index.html', error="Login functionality is currently disabled for maintenance.")

@app.route('/dashboard')
def dashboard():
    return "<h1>Redirecting...</h1>", 302, {'Location': '/login'}

@app.route('/api/health')
def health():
    return {"status": "ok", "service": "cloud-breach-web"}

@app.route('/upload', methods=['GET', 'POST'])
def upload():
    if request.method == 'POST':
        if 'file' not in request.files:
            return 'No file part'
        file = request.files['file']
        if file.filename == '':
            return 'No selected file'
        
        if file:
            filepath = os.path.join(UPLOAD_FOLDER, file.filename)
            file.save(filepath)
            
            # Zip Slip Vulnerability
            if zipfile.is_zipfile(filepath):
                try:
                    with zipfile.ZipFile(filepath, 'r') as zip_ref:
                        # VULNERABLE: Extracting without checking for directory traversal characters in filenames
                        zip_ref.extractall(UPLOAD_FOLDER)
                    return f"File uploaded and extracted to {UPLOAD_FOLDER}"
                except Exception as e:
                    return f"Error extracting zip: {e}"
            return "File uploaded (not a zip)"
            
    return render_template('upload.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
