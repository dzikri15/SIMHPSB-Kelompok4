#!/bin/bash
# =============================================================
# deploy.sh — Push Docker image ke Docker Hub
# Jalankan dari komputer lokal kamu (Windows: pakai Git Bash)
#
# Usage:
#   ./deploy.sh                  → build & push tag 'latest'
#   ./deploy.sh v1.0.0           → build & push dengan tag versi
# =============================================================

set -e

# ── Konfigurasi ───────────────────────────────────────────────
DOCKERHUB_USERNAME="dzikrisagara"
IMAGE_NAME="simhpsb-app"
TAG="${1:-latest}"
FULL_IMAGE="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}"

echo "================================================"
echo "  SIMHPSB — Docker Build & Push"
echo "  Image: ${FULL_IMAGE}"
echo "================================================"

# ── Pastikan sudah login ke Docker Hub ───────────────────────
echo ""
echo "[1/3] Checking Docker Hub login..."
docker login

# ── Build image ───────────────────────────────────────────────
echo ""
echo "[2/3] Building Docker image..."
docker build \
  --platform linux/amd64 \
  --no-cache \
  -t "${FULL_IMAGE}" \
  -f Dockerfile \
  .

echo "✅ Build selesai: ${FULL_IMAGE}"

# ── Push ke Docker Hub ───────────────────────────────────────
echo ""
echo "[3/3] Pushing to Docker Hub..."
docker push "${FULL_IMAGE}"

# Jika tag bukan latest, juga push sebagai latest
if [ "${TAG}" != "latest" ]; then
  docker tag "${FULL_IMAGE}" "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
  docker push "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
  echo "✅ Juga di-push sebagai :latest"
fi

echo ""
echo "================================================"
echo "  ✅ SELESAI! Image berhasil di-push."
echo "  ${FULL_IMAGE}"
echo ""
echo "  Sekarang SSH ke VPS dan jalankan:"
echo "  docker-compose -f docker-compose.prod.yml pull"
echo "  docker-compose -f docker-compose.prod.yml up -d"
echo "================================================"
