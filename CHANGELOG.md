# Changelog

## v0.1.1

- `TASK=section`: isovist areas of the horizontal section of `POINTCLOUD_FILE` at eye height, one row per query point, from `pysovist section`.
- New integer parameter `SECTION_RAYS` (default 3600), the rays per eye in the section plane, separate from `N_RAYS`.
- Pins pysovist 0.1.1.
- The local test also checks the section of a sampled room against its erosion bounds.

## v0.1.0

- First version: isovist and volume tasks, parameters in odtp.yml, local test on a reference room.
