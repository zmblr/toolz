# toolz

Bioinformatics packages for Nix

**[Package Search](https://zmblr.github.io/toolz/)**

## Usage

```bash
# Run directly
nix run github:zmblr/toolz#blast

# Enter shell with package
nix shell github:zmblr/toolz#cutadapt

# Use specific branch
nix run github:zmblr/toolz/release-25.11#blast
```

### As Flake Input

```nix
{
  toolz.url = "github:mulatta/toolz";
  toolz.inputs.flake-parts.follows = "flake-parts";
  toolz.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
  toolz.inputs.nixpkgs.follows = "nixpkgs";
  toolz.inputs.systems.follows = "systems";
  toolz.inputs.treefmt-nix.follows = "treefmt-nix";

  outputs = {nixpkgs, toolz, ...}: {
    # Use as overlay
    nixpkgs.overlays = [ toolz.overlays.default ];

    # Or direct package reference
    packages.default = toolz.packages.${system}.blast;
  };
}
```

### With flake-parts

```nix
{
  toolz.url = "github:mulatta/toolz";
  toolz.inputs.flake-parts.follows = "flake-parts";
  toolz.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
  toolz.inputs.nixpkgs.follows = "nixpkgs";
  toolz.inputs.systems.follows = "systems";
  toolz.inputs.treefmt-nix.follows = "treefmt-nix";

  outputs = {nixpkgs, toolz, ...}: {
    # Use as overlay
    nixpkgs.overlays = [ toolz.overlays.default ];

    # Or direct package reference
    packages.default = toolz.packages.${system}.blast;
  };
}
```

## Branches

| Branch          | Description                                |
| --------------- | ------------------------------------------ |
| `release-25.05` | Deprecated, based on nixpkgs 25.05         |
| `release-25.11` | Stable, based on nixpkgs 25.11             |
| `unstable`      | Latest packages, based on nixpkgs unstable |
