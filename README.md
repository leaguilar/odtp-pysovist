# odtp-pysovist

An [ODTP](https://github.com/odtp-org/odtp) component that computes isovists and view volumes with [pysovist](https://github.com/leaguilar/pysovist).

- `TASK=isovist`: exact 2D isovists from wall segments, for every query point.
- `TASK=volume`: 3D view volumes from a point cloud, a mesh or a plan extruded between floor and ceiling.
- `TASK=section`: isovist areas of the horizontal section of a point cloud at eye height. Every ball that the plane cuts leaves a disk, and `SECTION_RAYS` rays at equal angle steps (default 3600) meet the first disk.

Each run writes `<OUTPUT_PREFIX>_<TASK>.csv`, with one row per query point, and `<OUTPUT_PREFIX>_<TASK>.json`, which records the pysovist version, every parameter and the sha256 of every input. All parameters are listed in `odtp.yml`.

## Inputs

Put the files in the component input folder and name them in the parameters:

| Parameter | File |
|---|---|
| `QUERY_FILE` | CSV with columns `x`, `y` and, for volumes and sections, `z` (metres) |
| `PLAN_FILE` | wall segments: JSON records `{"start": [x, y], "end": [x, y]}`, or CSV `x0,y0,x1,y1` |
| `CLOSE_FILE` | optional JSON polygon `[[x, y], ...]` that closes the domain of `PLAN_FILE`, for example the building footprint. It sets the `--close` option of the pysovist command line. Every edge of the polygon becomes a wall, and a wall with more than half of its length outside the polygon is refused with a message that names `--close`. For a plan whose walls extend beyond its outline, pass the outline edges as walls in `PLAN_FILE` and give no `CLOSE_FILE`. |
| `POINTCLOUD_FILE` | `.pts`, `.las`, `.laz`, `.e57`, `.ply` or `.pcd` |
| `MESH_FILE` | any mesh format open3d reads |

## Run without ODTP

```
docker build -t odtp-pysovist .
docker run --rm -v "$PWD/input:/odtp/odtp-input" -v "$PWD/output:/odtp/odtp-output" \
    -e TASK=isovist -e PLAN_FILE=walls.json -e QUERY_FILE=points.csv odtp-pysovist
```

`tests/run_local.sh [image]` runs a built image on a 10 m x 10 m room and checks the three tasks. Every isovist has an area of 100 m2. Every view volume under a 2.5 m ceiling is 250 m3 to within 0.2 %. The walls sampled every 2 cm, with balls of radius 3 cm, give a section area between that of the room eroded by 3 cm and that of the room eroded by 2.6 cm.

## Licence

MIT.
