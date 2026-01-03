#!/bin/bash
cd /tmp/uploads
# Vulnerable to wildcard injection because of '*'
tar cf /tmp/backup.tar *
