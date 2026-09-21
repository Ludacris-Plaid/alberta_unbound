#!/usr/bin/env sh
# Migration runner for Alberta Unbound
# Applies all migration files in order

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/supabase/migrations"

if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo "Error: Migrations directory not found at $MIGRATIONS_DIR"
    exit 1
fi

# Get sorted list of migration files
MIGRATIONS=($(ls -1 "$MIGRATIONS_DIR"/*.sql 2>/dev/null | sort))

if [ ${#MIGRATIONS[@]} -eq 0 ]; then
    echo "Error: No migration files found"
    exit 1
fi

echo "Found ${#MIGRATIONS[@]} migration files"

for migration in "${MIGRATIONS[@]}"; do
    echo "Running: $(basename "$migration")"
    psql -h "$DATABASE_URL" -U "$DB_USER" -d "$DATABASE_NAME" -f "$migration"
    echo "Completed: $(basename "$migration")"
done

echo "All migrations completed successfully!"
