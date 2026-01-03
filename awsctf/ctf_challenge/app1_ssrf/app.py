from flask import Flask, request, render_template_string
import requests

app = Flask(__name__)

HTML = """
<!DOCTYPE html>
<html>
<head><title>Uptime Checker</title></head>
<body>
    <h1>Website Status Checker</h1>
    <p>Use our free tool to check if a website is up!</p>
    <form action="/check" method="GET">
        <input type="text" name="url" placeholder="http://google.com">
        <input type="submit" value="Check">
    </form>
    {% if result %}
    <h2>Result:</h2>
    <pre>{{ result }}</pre>
    {% endif %}
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML)

@app.route('/check')
def check():
    url = request.args.get('url', '')
    if not url:
        return "Missing URL parameter", 400
    
    # Advanced Challenge: Filters enabled
    blacklist = ["169.254", "localhost", "127.0.0.1", "::1", "0.0.0.0"]
    for banned in blacklist:
        if banned in url:
            return "Security Alert: Malicious Input Detected", 403
            
    try:
        # Intentionally vulnerable to SSRF (if you bypass filters)
        # Hint: IP Address encodings (Decimal, Octal, Hex)
        resp = requests.get(url, timeout=5)
        return render_template_string(HTML, result=f"Status Code: {resp.status_code}\n\nContent:\n{resp.text[:1000]}")
    except Exception as e:
        return render_template_string(HTML, result=f"Error accessing {url}: {str(e)}")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
