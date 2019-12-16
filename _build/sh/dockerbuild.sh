#!/bin/sh

# Docker Hub Username
DOCKER_HUB="cosasdepuma"

# Get the script location
SCRIPT_DIR="$(dirname "$0")"
# Get the containers directory
CONTAINER_DIR="${SCRIPT_DIR}/../../containers"

# Get the containers
for container in "${CONTAINER_DIR}"/*
do
	# Get the name of the app
	name=$(basename "${container}")
	# Get the image name
	image="${DOCKER_HUB}/${name}:latest"
	# Build the container
	echo "[+] Building ${name} as ${image}..."
	docker build -t "${image}" "${container}" >/dev/null 2>&1
done

# Done
echo "[+] All containers built"
