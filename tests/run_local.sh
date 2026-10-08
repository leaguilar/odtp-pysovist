#!/usr/bin/env bash
# Run the component image on a 10 m x 10 m room, without ODTP, and check the three tasks.
# Build the image first (docker build -t odtp-pysovist:dev .).
# Usage: tests/run_local.sh [image]   (default image: odtp-pysovist:dev)
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image="${1:-odtp-pysovist:dev}"
work="$here/tests/work"
# The container writes as root, so clean the previous run through Docker.
if [ -d "$work" ]; then docker run --rm -v "$work:/w" alpine:3.20 sh -c "rm -rf /w/*"; fi
mkdir -p "$work/input" "$work/out-isovist" "$work/out-volume" "$work/out-section"
python3 - "$work/input" <<'PY'
import json, sys
corners = [(0, 0), (10, 0), (10, 10), (0, 10)]
walls = [{"start": [*a, 0], "end": [*b, 0]} for a, b in zip(corners, corners[1:] + corners[:1])]
json.dump(walls, open(f"{sys.argv[1]}/walls.json", "w"))
open(f"{sys.argv[1]}/points.csv", "w").write("x,y,z\n5,5,1.7\n2,3,1.7\n8,9,0.8\n")
# The same walls as a scan: points every 2 cm along each wall, rows every 2 cm from 1 m to 2 m.
s = 0.02
with open(f"{sys.argv[1]}/room.pts", "w") as f:
    for k in range(51):
        for i in range(501):
            u, z = i * s, 1 + k * s
            for x, y in ((u, 0), (u, 10), (0, u), (10, u)):
                f.write(f"{x!r} {y!r} {z!r}\n")
PY
run() {
    docker run --rm -v "$work/input:/odtp/odtp-input:ro" -v "$work/$1:/odtp/odtp-output" "${@:2}" "$image" > "$work/$1.log" 2>&1
}
run out-isovist -e TASK=isovist -e PLAN_FILE=walls.json -e QUERY_FILE=points.csv -e OUTPUT_PREFIX=room
run out-volume -e TASK=volume -e PLAN_FILE=walls.json -e QUERY_FILE=points.csv -e CEILING=2.5 \
    -e N_RAYS=65536 -e OUTPUT_PREFIX=room
# N_RAYS and N_JOBS belong to the other tasks and must not reach the section.
run out-section -e TASK=section -e POINTCLOUD_FILE=room.pts -e QUERY_FILE=points.csv \
    -e EYE_HEIGHT=1.5 -e SPLAT_RADIUS=0.03 -e N_RAYS=65536 -e N_JOBS=-1 -e OUTPUT_PREFIX=room
python3 - "$work" <<'PY'
import csv, json, math, sys
w = sys.argv[1]
area = [float(r["area"]) for r in csv.DictReader(open(f"{w}/out-isovist/room_isovist.csv"))]
vol = [float(r["volume"]) for r in csv.DictReader(open(f"{w}/out-volume/room_volume.csv"))]
assert all(abs(a - 100) < 1e-6 for a in area), area
assert all(abs(v - 250) / 250 < 2e-3 for v in vol), vol
# Balls of radius r on a lattice of spacing s erode the room by a depth between
# sqrt(r^2 - s^2 / 2) and r. 3600 equiangular rays add a relative error below 1.1e-6.
r, s = 0.03, 0.02
inner, outer = (10 - 2 * r) ** 2, (10 - 2 * math.sqrt(r * r - s * s / 2)) ** 2
rows = list(csv.DictReader(open(f"{w}/out-section/room_section.csv")))
sec = [float(row["area"]) for row in rows]
assert all(inner * (1 - 1e-5) < a < outer * (1 + 1e-5) for a in sec), (sec, inner, outer)
assert all(row["z"] == "1.5" and row["inside_occluder"] == row["unbounded"] == "False"
           for row in rows), rows
rec = json.load(open(f"{w}/out-section/room_section.json"))
assert rec["task"] == "section" and rec["parameters"]["n_rays"] == 3600, rec
assert rec["parameters"]["radius"] == r, rec
print("isovist areas", area, "| view volumes", [round(v, 2) for v in vol],
      "| section areas", [round(a, 3) for a in sec], f"in [{inner:.3f}, {outer:.3f}]",
      "| pysovist", rec["pysovist_version"], "| OK")
PY
