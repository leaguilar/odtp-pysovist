#!/usr/bin/env bash
# Build the component image and run it on a 10 m x 10 m room, without ODTP.
# Usage: tests/run_local.sh [image]   (default image: odtp-pysovist:dev)
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image="${1:-odtp-pysovist:dev}"
work="$here/tests/work"
# The container writes as root, so clean the previous run through Docker.
if [ -d "$work" ]; then docker run --rm -v "$work:/w" alpine:3.20 sh -c "rm -rf /w/*"; fi
mkdir -p "$work/input" "$work/out-isovist" "$work/out-volume"
python3 - "$work/input" <<'PY'
import json, sys
corners = [(0, 0), (10, 0), (10, 10), (0, 10)]
walls = [{"start": [*a, 0], "end": [*b, 0]} for a, b in zip(corners, corners[1:] + corners[:1])]
json.dump(walls, open(f"{sys.argv[1]}/walls.json", "w"))
open(f"{sys.argv[1]}/points.csv", "w").write("x,y,z\n5,5,1.7\n2,3,1.7\n8,9,0.8\n")
PY
run() {
    docker run --rm -v "$work/input:/odtp/odtp-input:ro" -v "$work/$1:/odtp/odtp-output" "${@:2}" "$image" > "$work/$1.log" 2>&1
}
run out-isovist -e TASK=isovist -e PLAN_FILE=walls.json -e QUERY_FILE=points.csv -e OUTPUT_PREFIX=room
run out-volume -e TASK=volume -e PLAN_FILE=walls.json -e QUERY_FILE=points.csv -e CEILING=2.5 \
    -e N_RAYS=65536 -e OUTPUT_PREFIX=room
python3 - "$work" <<'PY'
import csv, sys
w = sys.argv[1]
area = [float(r["area"]) for r in csv.DictReader(open(f"{w}/out-isovist/room_isovist.csv"))]
vol = [float(r["volume"]) for r in csv.DictReader(open(f"{w}/out-volume/room_volume.csv"))]
assert all(abs(a - 100) < 1e-6 for a in area), area
assert all(abs(v - 250) / 250 < 2e-3 for v in vol), vol
print("isovist areas", area, "| view volumes", [round(v, 2) for v in vol], "| OK")
PY
