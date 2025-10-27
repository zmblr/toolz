# toolz

Bioinformatics packages for Nix

## Packages

**CLI Tools:**
aptasuite, bbtools, blast, cutadapt, fastaptamer, flash, jellyfish, jellyfish-full, kmc, kmc-full, nextflow, viennarna-hpc, vsearch

**Python Libraries:**
cutadapt, dnaio, forgi, logging-exceptions, xopen, viennarna-hpc

## Usage

```nix
{
  inputs.toolz.url = "github:yourname/toolz";

  outputs = {nixpkgs, toolz, ...}: {
    # Use as overlay
    nixpkgs.overlays = [ toolz.overlays.default ];

    # Or direct package reference
    packages.default = toolz.packages.${system}.blast;
  };
}
```

```bash
# Run directly
nix run github:yourname/toolz#cutadapt

# Python packages
nix run github:yourname/toolz#python3Packages.dnaio
```
