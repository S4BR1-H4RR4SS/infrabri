#!/usr/bin/env bash
# Run on the target Linux VM from the unzipped project.
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$project_dir"

if ! command -v docker >/dev/null 2>&1; then
  printf '%s\n' 'Docker is missing. Complete step 3 in README.md first.' >&2
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  printf '%s\n' 'Cannot access Docker. If needed, run: sudo bash start-website.sh' >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  printf '%s\n' 'The Docker Compose plugin is missing. See README.md.' >&2
  exit 1
fi
test -s dist/index.html
docker compose config --quiet
docker compose pull
docker compose run --rm --no-deps website caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
docker compose up -d
docker compose ps
printf '%s\n' 'Web server started. Check HTTPS once DNS points to this VM:' '  https://infrabri.be' 'Logs: sudo docker compose logs --tail=80 website'
