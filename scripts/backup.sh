#!/usr/bin/env bash
# Creates a timestamped pg_dump of the running "hotel-db" container's database.
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-hotel-db}"
DB_USER="${DB_USER:-hotel_app}"
DB_NAME="${DB_NAME:-hotel_bookings}"
BACKUP_DIR="${BACKUP_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backups}"

mkdir -p "$BACKUP_DIR"

timestamp="$(date +%Y%m%d_%H%M%S)"
backup_file="$BACKUP_DIR/hotel_bookings_${timestamp}.dump"

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
    echo "Error: container '$CONTAINER_NAME' is not running. Start it with: docker compose up -d" >&2
    exit 1
fi

echo "Backing up database '$DB_NAME' from container '$CONTAINER_NAME'..."

# Custom format (-F c): compressed, and restorable with pg_restore
# (supports parallel restore and selective restore, unlike plain SQL dumps).
docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" -d "$DB_NAME" -F c > "$backup_file"

echo "Backup written to: $backup_file"
echo "Size: $(du -h "$backup_file" | cut -f1)"
