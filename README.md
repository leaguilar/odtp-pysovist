# odtp-pysovist

An [ODTP](https://github.com/odtp-org/odtp) component that computes isovists and view volumes with [pysovist](https://github.com/leaguilar/pysovist).

- `TASK=isovist`: exact 2D isovists from wall segments, for every query point.
- `TASK=volume`: 3D view volumes from a point cloud, a mesh or a plan extruded between floor and ceiling.

Each run writes `<OUTPUT_PREFIX>_<TASK>.csv`, with one row per query point, and `<OUTPUT_PREFIX>_<TASK>.json`, which records the pysovist version, every parameter and the sha256 of every input. All parameters are listed in `odtp.yml`.

## Inputs

Put the files in the component input folder and name them in the parameters:

| Parameter | File |
|---|---|
| `QUERY_FILE` | CSV with columns `x`, `y` and, for volumes, `z` (metres) |
| `PLAN_FILE` | wall segments: JSON records `{"start": [x, y], "end": [x, y]}`, or CSV `x0,y0,x1,y1` |
| `CLOSE_FILE` | optional JSON polygon `[[x, y], ...]` that closes the domain, for example the building footprint |
| `POINTCLOUD_FILE` | `.pts`, `.las`, `.laz`, `.e57`, `.ply` or `.pcd` |
| `MESH_FILE` | any mesh format open3d reads |

## Run without ODTP

```
docker build -t odtp-pysovist .
docker run --rm -v "$PWD/input:/odtp/odtp-input" -v "$PWD/output:/odtp/odtp-output" \
    -e TASK=isovist -e PLAN_FILE=walls.json -e QUERY_FILE=points.csv odtp-pysovist
```

`tests/run_local.sh` builds the image and checks both tasks on a 10 m x 10 m room: every isovist has an area of 100 m2, and every view volume under a 2.5 m ceiling is 250 m3 to within 0.2 %.

## Licence

MIT.
