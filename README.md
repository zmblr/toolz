# toolz

Bioinformatics packages for Nix

**[Package Search](https://zmblr.github.io/toolz/)** | [GitHub](https://github.com/zmblr/toolz)

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
  inputs.toolz.url = "github:zmblr/toolz";

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
| `release-25.11` | Stable, based on nixpkgs 25.05             |
| `unstable`      | Latest packages, based on nixpkgs unstable |
