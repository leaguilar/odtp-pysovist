# Changelog

## v0.3.0

- Pins pysovist 0.3.0. The tasks, their parameters, the columns of the CSV and the fields of the JSON record are unchanged, and every input that v0.2.1 accepts gives the same values.
- `PLAN_FILE` also takes a JSON list of segments `[[x0, y0], [x1, y1]]`. A JSON plan in neither format, a file that is not JSON in UTF-8, and a coordinate that is missing or not finite stop the run with a message that names the file, both formats or the record counted from 1.

## v0.2.1

- Pins pysovist 0.2.1. The tasks, their parameters, the columns of the CSV and the fields of the JSON record are unchanged.
- Every input is checked before the run computes, and an inconsistent input stops the run with a message before it writes an output: a missing or empty file, a missing column, a coordinate that is not a finite number, a parameter outside its range, a section plane that cuts no ball of the cloud, or an eye outside an extruded plan. `QUERY_FILE` and exactly one scene file are required (`PLAN_FILE` for `TASK=isovist`, `POINTCLOUD_FILE` for `TASK=section`, one of `POINTCLOUD_FILE`, `MESH_FILE` and `PLAN_FILE` for `TASK=volume`), and the message names the variable that is missing.
- `CLOSE_FILE` sets the `--close` option of the pysovist command line, and every edge of the polygon becomes a wall. A wall with more than half of its length outside the polygon is now refused with a message that names `--close`. For a plan whose walls extend beyond its outline, pass the outline edges as walls in `PLAN_FILE`, in order and with the edge from the last vertex back to the first, and give no `CLOSE_FILE`. For `TASK=isovist` this is the plan that v0.1.2 built from the two files, segment for segment.
- A variable applies only to its scene: `CLOSE_FILE`, `FLOOR` and `CEILING` to `PLAN_FILE`, and `SPLAT_RADIUS` to `POINTCLOUD_FILE`. The others are ignored, so a workflow can pass every parameter with its default.
- CSV coordinates (`QUERY_FILE`, and `PLAN_FILE` as CSV) and `.pts` point clouds are read to the nearest float64. The parser of v0.1.2 returned some coordinates written with 16 or 17 significant digits a few units in the last place off. Such a coordinate now differs from its v0.1.2 value by those few units, and the metrics of its eye can change in their last digits.
- Text inputs and the JSON record are read and written as UTF-8 on every platform.

## v0.1.2

- Pins pysovist 0.1.2. The tasks and their results are unchanged. The release adds IFC input to the library, which this component does not yet expose.

## v0.1.1

- `TASK=section`: isovist areas of the horizontal section of `POINTCLOUD_FILE` at eye height, one row per query point, from `pysovist section`.
- New integer parameter `SECTION_RAYS` (default 3600), the rays per eye in the section plane, separate from `N_RAYS`.
- Pins pysovist 0.1.1.
- The local test also checks the section of a sampled room against its erosion bounds.

## v0.1.0

- First version: isovist and volume tasks, parameters in odtp.yml, local test on a reference room.
