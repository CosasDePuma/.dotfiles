#!/bin/sh

# Docker Hub Username
DOCKER_HUB="cosasdepuma"

# Get the script location
SCRIPT_DIR="$(dirname "$0")"
# Get the containers directory
CONTAINER_DIR="${SCRIPT_DIR}/../../containers"

# Log in the Docker Hub
docker login

# Get the containers
for container in "${CONTAINER_DIR}"/*
do
	# Get the name of the app
	name=$(basename "${container}")
	# Get the image name
	image="${DOCKER_HUB}/${name}:latest"
	# Build the container
	echo "[+] Publishing ${name} as ${image}..."
	docker push  "${image}" >/dev/null 2>&1
done

# Done
echo "[+] All containers published"
