# AlphaFold3 Package Documentation

## Overview

AlphaFold3 predicts the structure and interactions of biological molecules with state-of-the-art accuracy. This package provides a reproducible Nix-based distribution with:

- **Build-time pickle generation**: CCD and chemical component sets generated during build
- **PDB snapshot reproducibility**: Hash-pinned components.cif from PDB version archives (2025-01-01)
- **CUDA 12.x support**: GPU acceleration with pre-built CUDA libraries
- **Integrated HMMER tools**: jackhmmer, nhmmer, etc. for sequence alignment
- **CLI wrapper**: Simple `alphafold3` command for structure prediction
- **Python library**: Full programmatic access via `import alphafold3`

## Package Structure

The AlphaFold3 package follows Nix best practices with clear separation of concerns:

### 1. Python Package (`python3Packages.alphafold3`)

**Location**: `packages/lib/python-packages.nix`

**Purpose**: Python library with all runtime dependencies

**Contains**:
- AlphaFold3 Python modules and C++ bindings
- Pre-generated pickle files (ccd.pickle, chemical_component_sets.pickle)
- Components.cif from PDB snapshots (2025-01-01, hash-pinned)
- JAX, JAXlib, and CUDA Python libraries
- All Python runtime dependencies

**Usage**: For importing AlphaFold3 in Python code

```python
import alphafold3
from alphafold3 import structure_prediction
```

### 2. CLI Package (`alphafold3`)

**Location**: `packages/by-name/al/alphafold3/package.nix`

**Purpose**: Command-line interface with integrated tools

**Contains**:
- `alphafold3` CLI wrapper (runs run_alphafold.py)
- HMMER tools (jackhmmer, nhmmer, etc.)
- Pre-configured GPU environment
- Shell hook for development

**Usage**: For running structure predictions from command line

```bash
alphafold3 --help
alphafold3 --json_path=input.json --model_dir=params --output_dir=output
```

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ alphafold3 (CLI Package - symlinkJoin)                      │
│ ├─ bin/alphafold3 (wrapper → run_alphafold.py)             │
│ ├─ bin/jackhmmer, nhmmer (HMMER tools)                      │
│ └─ passthru.mkShellHook (GPU environment setup)             │
└─────────────────────────────────────────────────────────────┘
                           │
                           ├─ Uses internally
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ python3Packages.alphafold3 (Python Package)                 │
│ ├─ lib/python3.12/site-packages/alphafold3/                │
│ │  ├─ Python modules and C++ bindings (alphafold3.cpp)     │
│ │  └─ constants/converters/*.pickle (build-time generated) │
│ └─ share/libcifpp/components.cif (PDB snapshot 2025-01-01) │
└─────────────────────────────────────────────────────────────┘
```

## Usage Patterns

### Pattern 1: Python Library Only

**Use case**: Importing AlphaFold3 in your Python code

```nix
# flake.nix or shell.nix
{
  python = pkgs.python312.withPackages (ps: [
    ps.alphafold3
    ps.numpy
    ps.pandas
  ]);
}
```

**Result**:
- `import alphafold3` works
- `alphafold3` CLI command NOT available
- HMMER tools NOT in PATH

### Pattern 2: CLI Only

**Use case**: Running structure predictions with CLI

```nix
# flake.nix
{
  environment.systemPackages = [
    pkgs.alphafold3
  ];
}
```

**Result**:
- `alphafold3` CLI command available
- HMMER tools in PATH
- `import alphafold3` NOT available (outside Python environment)

### Pattern 3: Development Environment (Both)

**Use case**: Interactive development with Python library and CLI

```nix
# dev/shell.nix
{
  devShells.alphafold3 = let
    alphafold3Pkg = config.packages.alphafold3;
    python = config.packages.python312.withPackages (ps: [
      ps.alphafold3
      ps.ipython
      ps.jupyter
    ]);
  in pkgs.mkShellNoCC {
    buildInputs = [
      alphafold3Pkg  # CLI + HMMER
      python         # Python library
    ];
    shellHook = alphafold3Pkg.mkShellHook python;
  };
}
```

**Result**:
- `import alphafold3` works
- `alphafold3` CLI command available
- HMMER tools in PATH
- GPU environment configured via shell hook

**Activate**:
```bash
nix develop .#alphafold3
```

### Pattern 4: One-off CLI Runs

**Use case**: Quick structure predictions without installing

```bash
nix run .#alphafold3 -- --json_path=input.json --model_dir=params --output_dir=output
```

**Result**: Runs prediction in isolated environment

## Shell Hook for GPU Environment

The CLI package provides a shell hook that configures the GPU environment:

```nix
shellHook = alphafold3Pkg.mkShellHook python;
```

**What it does**:
- Sets `LD_LIBRARY_PATH` for NVIDIA driver and CUDA libraries
- Sets `LIBCIFPP_DATA_DIR` for components.cif location
- Displays GPU environment information on shell startup

**Example output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AlphaFold3 GPU Environment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Python: Python 3.12.11
AlphaFold3: v3.0.1
✓ Driver: /run/opengl-driver/lib
✓ CUDA: 9 libraries
GPU: NVIDIA RTX A6000
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Extending Shell Hook

To add custom shell setup while preserving the GPU environment:

```nix
shellHook = alphafold3Pkg.mkShellHook python + ''
  # Your additional setup
  export MY_VAR="value"
  echo "Custom setup complete"
'';
```

## Reproducibility via PDB Snapshots

### Problem with Live PDB Data

The Protein Data Bank (PDB) updates `components.cif` weekly, breaking reproducibility:

```
❌ https://files.wwpdb.org/pub/pdb/data/monomers/components.cif.gz
   → Updates every Wednesday
   → Different content = different builds
```

### Solution: PDB Version Archives

We use hash-pinned snapshots from PDB's archival server:

```nix
# packages/by-name/al/alphafold3/base.nix
componentsCif = fetchurl {
  url = "https://pdbsnapshots.s3-us-west-2.amazonaws.com/20250101/pub/pdb/data/monomers/components.cif.gz";
  hash = "sha256-2bJpHBYaZiKF13HXKWZen6YqA4tJeBy31zu+HrlC+Fw=";
};
```

**Benefits**:
- ✅ Reproducible builds (hash verification)
- ✅ No external updates breaking builds
- ✅ Explicit version management (date-based)

**Updating to newer snapshot**:
1. Find snapshot at https://pdbsnapshots.s3-us-west-2.amazonaws.com/
2. Update URL with new date (e.g., `20250201`)
3. Get hash: `nix-prefetch-url <url>`
4. Update `base.nix` with new URL and hash

## Build-time Pickle Generation

AlphaFold3 requires two pickle files generated from components.cif:

### 1. ccd.pickle

**Purpose**: Parsed Chemical Component Dictionary

**Generation**: `alphafold3.constants.converters.ccd_pickle_gen`

**Size**: ~465 MB (components.cif) → ~15 MB (pickle)

### 2. chemical_component_sets.pickle

**Purpose**: Categorized chemical components (glycans, ions)

**Generation**: Python script using regex on ccd.pickle

**Size**: <1 MB

### Build Process

```nix
# packages/lib/python-packages.nix
pickle-data = pySelf.pkgs.runCommand "alphafold3-pickle-data" {
  nativeBuildInputs = [pythonEnv pySelf.pkgs.gzip];
} ''
  # Decompress components.cif.gz
  gunzip -c ${componentsCif} > $out/components.cif.tmp

  # Generate ccd.pickle (~2-3 minutes)
  python3 -m alphafold3.constants.converters.ccd_pickle_gen \
    $out/components.cif.tmp $out/ccd.pickle

  # Generate chemical_component_sets.pickle
  python3 <<EOF
  import pickle, re
  with open('$out/ccd.pickle', 'rb') as f:
      ccd = pickle.load(f)

  glycans_linking, glycans_other, ions = [], [], []
  for name, comp in ccd.items():
      if name == 'UNX': continue
      comp_type = comp['_chem_comp.type'][0].lower()
      if re.findall(r'\bsaccharide\b', comp_type):
          (glycans_linking if 'linking' in comp_type else glycans_other).append(name)
      if re.findall(r'\bion\b', comp['_chem_comp.name'][0].lower()):
          ions.append(name)

  with open('$out/chemical_component_sets.pickle', 'wb') as f:
      pickle.dump({
          'glycans_linking': frozenset(glycans_linking),
          'glycans_other': frozenset(glycans_other),
          'ions': frozenset(ions),
      }, f)
  EOF
'';
```

**Why build-time generation?**

AlphaFold3's C++ module requires components.cif during initialization, but the installation directory is not in Python's `site-packages` during Nix build. By generating pickles in a separate derivation, we work around this chicken-and-egg problem.

## Technical Details

### C++ Module Initialization

AlphaFold3 uses pybind11 to expose C++ functionality. The C++ module searches for components.cif:

1. **Check `LIBCIFPP_DATA_DIR` environment variable first** (our patch)
   - Allows `python.withPackages` environments to work
   - Set by shell hook: `$python_env/lib/python3.12/site-packages/share/libcifpp`

2. **Fallback to `site.getsitepackages()`** (upstream default)
   - Works for `pip install` or direct package installation
   - Doesn't work for `python.withPackages` (not in site-packages list yet)

**Patch**: `libcifpp-env-var-first.patch`

```cpp
// Check LIBCIFPP_DATA_DIR environment variable first
const char* env_data_dir = std::getenv("LIBCIFPP_DATA_DIR");
if (env_data_dir != nullptr) {
  auto env_path = std::filesystem::path(env_data_dir) / "components.cif";
  if (std::filesystem::exists(env_path)) {
    setenv("LIBCIFPP_DATA_DIR", env_data_dir, 0);
    return;  // Environment variable is already set correctly
  }
}

// Fallback to site.getsitepackages()
py::module site = py::module::import("site");
py::list paths = py::cast<py::list>(site.attr("getsitepackages")());
// ...
```

### Dependency Management

**Pure Nix Build**: All dependencies from nixpkgs, no CMake FetchContent

```nix
# packages/by-name/al/alphafold3/base.nix
postPatch = ''
  substituteInPlace CMakeLists.txt \
    --replace-fail 'FetchContent_Declare(...)' \
    '# Use system-provided dependencies (pure Nix build)
    find_package(absl REQUIRED)
    find_package(pybind11 REQUIRED)
    find_package(cifpp REQUIRED)
    find_package(dssp REQUIRED)
    # pybind11_abseil from system
    include_directories(${pybind11-abseil}/include)
    link_directories(${pybind11-abseil}/lib)'
'';
```

**Runtime Dependencies**:
- **Python**: JAX, JAXlib, NumPy, SciPy, RDKit, etc.
- **CUDA**: nvidia-{cuda-runtime,cublas,cudnn,cusparse,cusolver,cufft,cupti,nccl,nvjitlink}-cu12
- **C++ Libraries**: abseil-cpp, libcifpp, dssp, boost, zlib

**Binary Dependencies**:
- **HMMER**: jackhmmer, nhmmer, hmmsearch, etc.

## Installation Patterns

### NixOS System

```nix
# configuration.nix
{
  environment.systemPackages = [
    pkgs.alphafold3
  ];
}
```

### Home Manager

```nix
# home.nix
{
  home.packages = [
    pkgs.alphafold3
  ];
}
```

### Development Flake

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    toolz.url = "github:yourusername/toolz";
  };

  outputs = { self, nixpkgs, toolz }: {
    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ toolz.overlays.default ];
        config.allowUnfree = true;
      };

      python = pkgs.python312.withPackages (ps: [
        ps.alphafold3
        ps.ipython
        ps.jupyter
      ]);
    in pkgs.mkShellNoCC {
      buildInputs = [
        pkgs.alphafold3
        python
      ];
      shellHook = pkgs.alphafold3.mkShellHook python;
    };
  };
}
```

## Troubleshooting

### Import Error: No module named 'alphafold3'

**Cause**: `alphafold3Pkg` (CLI) in buildInputs, but not in Python environment

**Solution**: Use `python.withPackages (ps: [ps.alphafold3])`

```nix
# ❌ Wrong
buildInputs = [ pkgs.alphafold3 ];

# ✅ Correct
python = pkgs.python312.withPackages (ps: [ps.alphafold3]);
buildInputs = [ python ];
```

### Error: components.cif not found

**Cause**: `LIBCIFPP_DATA_DIR` not set correctly

**Solution**: Use shell hook from CLI package

```nix
shellHook = pkgs.alphafold3.mkShellHook python;
```

### HMMER tools not in PATH

**Cause**: Only Python package installed, CLI package needed

**Solution**: Include CLI package in buildInputs

```nix
buildInputs = [
  pkgs.alphafold3  # Provides HMMER tools
  python
];
```

### CUDA errors at runtime

**Cause**: GPU environment not configured

**Solution**: Ensure shell hook is applied

```nix
shellHook = pkgs.alphafold3.mkShellHook python;
```

Or run with wrapper:
```bash
nix run .#alphafold3
```

### Build fails with "hash mismatch"

**Cause**: components.cif.gz changed on PDB server (shouldn't happen with snapshots)

**Solution**: Verify URL and update hash

```bash
# Get new hash
nix-prefetch-url https://pdbsnapshots.s3-us-west-2.amazonaws.com/20250101/pub/pdb/data/monomers/components.cif.gz

# Update base.nix with new hash
```

## Model Parameters

AlphaFold3 model parameters must be obtained separately from Google DeepMind:

1. Request access: https://github.com/google-deepmind/alphafold3
2. Download parameters (subject to terms of use)
3. Extract to a directory (e.g., `~/alphafold3-params/`)
4. Pass path via `--model_dir` flag:

```bash
alphafold3 --json_path=input.json --model_dir=~/alphafold3-params --output_dir=output
```

**Note**: Model parameters are NOT included in this package due to licensing restrictions.

## Performance Notes

- **Build time**: ~30-45 minutes (includes pickle generation)
- **Pickle generation**: ~2-3 minutes during build
- **Disk usage**: ~2.5 GB (package + dependencies)
- **Runtime memory**: 10-20 GB GPU VRAM (depending on input size)

## License

- **AlphaFold3 source code**: CC BY-NC-SA 4.0 (non-commercial use only)
- **Model parameters**: Subject to separate terms of use from Google DeepMind
- **This package**: MIT (Nix packaging only)

## References

- AlphaFold3: https://github.com/google-deepmind/alphafold3
- PDB Snapshots: https://pdbsnapshots.s3-us-west-2.amazonaws.com/
- Chemical Component Dictionary: https://www.wwpdb.org/data/ccd
- HMMER: http://hmmer.org/

## Version History

- **v3.0.1**: Initial Nix package
  - PDB snapshot-based reproducibility (2025-01-01)
  - Build-time pickle generation
  - Integrated HMMER tools
  - Python library and CLI wrapper
  - GPU environment shell hook
