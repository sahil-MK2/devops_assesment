#!/usr/bin/env bash
# Restores a pg_dump backup into a fresh database inside the running
# "hotel-db" container, so restore can be verified without touching the
# original database.
#
# Usage: ./scripts/restore.sh [path/to/backup.dump]
# If no path is given, the most recent file in ./backups is used.
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-hotel-db}"
DB_USER="${DB_USER:-hotel_app}"
RESTORE_DB_NAME="${RESTORE_DB_NAME:-hotel_bookings_restore}"
BACKUP_DIR="${BACKUP_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backups}"

backup_file="${1:-}"
if [[ -z "$backup_file" ]]; then
    backup_file="$(ls -t "$BACKUP_DIR"/*.dump 2>/dev/null | head -n1 || true)"
fi

if [[ -z "$backup_file" || ! -f "$backup_file" ]]; then
    echo "Error: no backup file found. Run ./scripts/backup.sh first, or pass a path explicitly." >&2
    exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
    echo "Error: container '$CONTAINER_NAME' is not running. Start it with: docker compose up -d" >&2
    exit 1
fi

echo "Restoring '$backup_file' into fresh database '$RESTORE_DB_NAME'..."

# Drop and recreate the target database so the restore starts from a clean slate.
docker exec "$CONTAINER_NAME" dropdb -U "$DB_USER" --if-exists "$RESTORE_DB_NAME"
docker exec "$CONTAINER_NAME" createdb -U "$DB_USER" "$RESTORE_DB_NAME"

docker exec -i "$CONTAINER_NAME" pg_restore -U "$DB_USER" -d "$RESTORE_DB_NAME" --no-owner < "$backup_file"

echo "Restore complete into database '$RESTORE_DB_NAME'."
echo
echo "Verify with:"
echo "  docker exec -it $CONTAINER_NAME psql -U $DB_USER -d $RESTORE_DB_NAME -c \"SELECT COUNT(*) FROM hotel_bookings;\""
echo "  docker exec -it $CONTAINER_NAME psql -U $DB_USER -d $RESTORE_DB_NAME -c \"SELECT COUNT(*) FROM booking_events;\""
