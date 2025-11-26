# PROJ_NAME

A Python project managed with [uv](https://docs.astral.sh/uv/) and [Nix](https://nixos.org/) using [uv2nix](https://github.com/pyproject-nix/uv2nix).

## Getting Started

After initializing this template, run the init script to set your project name:

```bash
# Initialize with your project name
nix run github:zmblr/toolz#init-template -- my-project-name .

# Or if you cloned toolz locally
nix run .#init-template -- my-project-name .
```

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) (optional, for automatic environment activation)

## Quick Start

### Enter Development Shell

```bash
# Using nix develop
nix develop

# Or with direnv (if .envrc is set up)
direnv allow
```

### Using uv for Package Management

```bash
# Add a dependency
uv add requests

# Add a dev dependency
uv add --dev pytest

# Sync dependencies (regenerates uv.lock)
uv sync
```

> **Note**: After modifying `pyproject.toml` or `uv.lock`, you may need to re-enter the shell with `nix develop` to pick up the changes.

### Building the Package

```bash
# Build the default package (creates a virtual environment)
nix build

# Build with all optional dependencies
nix build .#full

# Run the package directly
nix run
```

### Running Tests

```bash
# In the development shell
pytest

# With coverage
pytest --cov=PROJ_NAME_SNAKE
```

### Formatting and Linting

```bash
# Format all code
nix fmt

# Run linters
ruff check src/
mypy src/
```

## Project Structure

```
.
├── flake.nix           # Nix flake definition
├── pyproject.toml      # Python project configuration
├── uv.lock             # uv lock file (auto-generated)
├── nix/
│   ├── uv2nix.nix      # uv2nix workspace configuration
│   ├── packages.nix    # Package outputs
│   ├── shell.nix       # Development shell configuration
│   └── formatter.nix   # Code formatting configuration
├── src/
│   └── PROJ_NAME_SNAKE/
│       └── __init__.py
└── tests/
    └── test_main.py
```

## Nix Flake Outputs

| Output | Description |
|--------|-------------|
| `packages.default` | Virtual environment with default dependencies |
| `packages.full` | Virtual environment with all dependencies |
| `devShells.default` | Development shell with editable installs |
| `devShells.prod` | Shell without editable installs (for testing) |

## How It Works

1. **uv** manages Python dependencies and generates `uv.lock`
2. **uv2nix** reads the lock file and generates Nix derivations
3. **pyproject-nix** provides build infrastructure
4. **flake-parts** organizes the flake into modular components

The development shell uses editable installs, so changes to source code are immediately reflected without rebuilding.

## Updating Dependencies

```bash
# Update a specific package
uv lock --upgrade-package requests

# Update all packages
uv lock --upgrade

# After updating, re-enter the shell
exit
nix develop
```

## License

MIT
