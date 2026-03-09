#!/bin/bash

docker-compose up -d

sleep 2

# For ollama:latest
CONTAINER_NAME=$(docker ps --filter "ancestor=ollama/ollama:latest" --format "{{.Names}}" | head -n 1)

# For ollama:rocm
# CONTAINER_NAME=$(docker ps --filter "ancestor=ollama/ollama:rocm" --format "{{.Names}}" | head -n 1)

if [ -z "$CONTAINER_NAME" ]; then
    echo "Error: No running Ollama ROCm container found."
    echo "Make sure to run 'docker-compose up -d' first."
    exit 1
fi

# 2. Get the list of models currently available inside that container
echo "Fetching models from $CONTAINER_NAME..."
MODELS=$(docker exec "$CONTAINER_NAME" ollama list | awk 'NR>1 {print $1}')

if [ -z "$MODELS" ]; then
    echo "No models found inside the container."
    echo "Try running: docker exec -it $CONTAINER_NAME ollama pull qwen3-coder"
    exit 1
fi

# 3. Interactive selection
echo "------------------------------------------"
echo "Select a model to run:"
PS3="Enter the number: "

select MODEL_NAME in $MODELS; do
    if [ -n "$MODEL_NAME" ]; then
        echo "Starting $MODEL_NAME on AMD GPU..."
        echo "------------------------------------------"
        # 4. Exec into the running container to start the model
        docker exec -it "$CONTAINER_NAME" ollama run "$MODEL_NAME"
        break
    else
        echo "Invalid selection."
    fi
done