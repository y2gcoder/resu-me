#!/bin/sh
set -e

echo "🪣 Initializing MinIO buckets..."

# Wait a bit for MinIO to be fully ready
sleep 2

# Configure MinIO client
mc alias set local http://storage:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}

# Create bucket if it doesn't exist
mc mb -p local/${MINIO_BUCKET} || echo "Bucket ${MINIO_BUCKET} already exists"

# Set public download policy (optional - for resume exports)
mc anonymous set download local/${MINIO_BUCKET} || true

echo "✅ MinIO initialization complete!"