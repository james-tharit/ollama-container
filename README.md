# Ollama Container - Run with AMD GPU(RX-6600)

Run [Ollama](https://ollama.com) on an AMD GPU (ROCm) in a Podman container.

## Requirements

- Linux with an AMD GPU (`/dev/kfd` and `/dev/dri` present)
- `podman` and `podman-compose`
- User in the `render` and `video` groups

## Usage

Start the container in the background:

```sh
podman-compose up -d
```

Pull and run a model:

```sh
podman exec -it ollama-amd ollama run llama3.2
```

Call the API from the host (port `11434`):

```sh
curl http://localhost:11434/api/generate -d '{"model": "llama3.2", "prompt": "hi"}'
```

Stop:

```sh
podman-compose down
```

`./start.sh` does a one-shot session: starts the container, opens a shell inside it, and tears it down when you exit the shell.

## Configuration

Edit `docker-compose.yaml`:

| Setting | Purpose |
|---|---|
| `image: ollama/ollama:rocm` | AMD build. Use `ollama/ollama` for CPU/NVIDIA (and drop the `devices` block). |
| `HSA_OVERRIDE_GFX_VERSION=10.3.0` | Spoof GPU arch for cards ROCm doesn't officially support. Set for RX 6600; change or remove for other GPUs. |
| `OLLAMA_KEEP_ALIVE=0` | Unload model and free VRAM right after each request. Raise (e.g. `5m`) to keep models warm. |
| `OLLAMA_HOST=0.0.0.0` | Listen on all interfaces inside the container. |
| `group_add: keep-groups`, `label=disable` | Podman-specific: keep host GPU group access, avoid SELinux blocking `/dev/kfd`. |

## Data

Models and config persist in `./ollama_data` (mounted at `/root/.ollama`, git-ignored). Delete it to reclaim disk space.
