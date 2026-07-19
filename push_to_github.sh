#!/bin/bash
# Cach dung:
#   1. Sua GITHUB_USER va REPO_NAME ben duoi cho dung cua ban
#   2. Vao thu muc SystemHUD-App, chay: bash push_to_github.sh
#   3. Neu chua tao repo tren github.com, mo https://github.com/new va tao truoc (repo trong, KHONG tick add README)

GITHUB_USER="ten-github-cua-ban"
REPO_NAME="SystemHUD-App"

git init
git add .
git commit -m "SystemHUD app: floating in-app bubble HUD (FPS/battery/RAM + quick toggles)"
git branch -M main
git remote add origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
git push -u origin main

echo ""
echo "Xong! Kiem tra tai: https://github.com/${GITHUB_USER}/${REPO_NAME}"
