#!/bin/bash

# Script untuk membersihkan Docker cache dan rebuild dari nol
# Jalankan script ini di VPS sebelum deploy ulang

echo "🧹 Membersihkan Docker cache..."

# Stop dan hapus container
echo "Stopping container kua-emulators..."
docker stop kua-emulators 2>/dev/null || true
docker rm kua-emulators 2>/dev/null || true

# Hapus image lama
echo "Removing old images..."
docker rmi kua-emulators:v2 2>/dev/null || true
docker rmi kua-emulators:v3 2>/dev/null || true
docker rmi kua-emulators:latest 2>/dev/null || true

# Hapus build cache
echo "Pruning build cache..."
docker builder prune -af

# Hapus dangling images
echo "Removing dangling images..."
docker image prune -f

echo "✅ Cleanup selesai!"
echo ""
echo "Sekarang deploy ulang stack via Portainer."
echo "Portainer akan build image dari nol tanpa cache."
