FROM python:3.12-slim-bookworm

LABEL org.opencontainers.image.title="odtp-pysovist"
LABEL org.opencontainers.image.description="Exact isovists and view volumes from plans, meshes and point clouds, as an ODTP component"
LABEL org.opencontainers.image.licenses="MIT"

# zip is used by the ODTP client. libgomp1, libgl1, libegl1 and libusb-1.0-0 are needed by numba and open3d.
RUN apt-get update && apt-get install -y --no-install-recommends zip libgomp1 libgl1 libegl1 libusb-1.0-0 && \
    rm -rf /var/lib/apt/lists/*

COPY odtp-component-client/requirements.txt /tmp/odtp.requirements.txt
RUN pip install --no-cache-dir -r /tmp/odtp.requirements.txt

# pysovist from PyPI, pinned so that a component version always runs the same library.
# To test an unreleased build, place its wheel in wheels/ and pass
# --build-arg PYSOVIST_SPEC=pysovist[pointcloud,mesh,e57]==<version>.
ARG PYSOVIST_SPEC="pysovist[pointcloud,mesh,e57]==0.1.2"
COPY wheels/ /tmp/wheels/
RUN pip install --no-cache-dir --find-links /tmp/wheels "${PYSOVIST_SPEC}"

RUN mkdir -p /odtp/odtp-config /odtp/odtp-app /odtp/odtp-component-client /odtp/odtp-logs \
    /odtp/odtp-input /odtp/odtp-workdir /odtp/odtp-output
COPY odtp.yml /odtp/odtp-config/odtp.yml
COPY ./odtp-component-client /odtp/odtp-component-client
COPY ./app /odtp/odtp-app
WORKDIR /odtp
RUN find /odtp -type f -iname "*.sh" -exec sed -i 's/\r$//' {} \;

ENTRYPOINT ["bash", "/odtp/odtp-component-client/startup.sh"]
