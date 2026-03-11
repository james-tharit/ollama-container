#!/bin/bash

podman-compose up -d

podman exec -it ollama-amd sh

podman-compose down