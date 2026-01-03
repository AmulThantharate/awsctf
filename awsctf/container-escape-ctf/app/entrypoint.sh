#!/bin/bash

# Fix permissions for the docker socket if it is mounted
# In a real scenario, the group ID of the socket on host might differ.
# We'll just force the socket to be writable by svc-backup or everyone for the CTF.
if [ -S /var/run/docker.sock ]; then
    chmod 666 /var/run/docker.sock
fi

# Switch to www-data and run the app
# using su instead of USER directive in Dockerfile to ensure permissions logic runs as root first
exec su -s /bin/bash www-data -c "python /app/app.py"
