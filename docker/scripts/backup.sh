#!/bin/bash
echo "Backing up data..."
tar -czf backup_$(date +%Y%m%d).tar.gz docker/data
echo "Backup complete!"
