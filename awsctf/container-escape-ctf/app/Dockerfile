FROM python:3.9-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Install Flask
COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

# Create users
# www-data is usually 33. Let's create svc-backup
RUN useradd -m -s /bin/bash svc-backup

# Setup vulnerable app
WORKDIR /app
COPY app.py /app/app.py
COPY templates /app/templates
RUN mkdir /tmp/uploads && chown www-data:www-data /tmp/uploads

# Setup backup script for lateral movement
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh
# svc-backup owns it, but it runs things in /tmp/uploads which www-data controls
RUN chown svc-backup:svc-backup /usr/local/bin/backup.sh

# Configure sudoers for www-data to run backup.sh as svc-backup
RUN echo "www-data ALL=(svc-backup) NOPASSWD: /usr/local/bin/backup.sh" >> /etc/sudoers

# Make svc-backup part of a group that will have access to docker socket
# We will handle group ID mapping in entrypoint or assume standard
# For now, let's just make sure svc-backup can read/write the socket path IF permissions allow
# In many CTFs, we just chmod the socket in entrypoint.

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port
EXPOSE 5000

ENTRYPOINT ["/entrypoint.sh"]
