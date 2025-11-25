{
  flake.templates = {
    rust = {
      path = ./rust;
      description = "Basic toolz rust project template";
    };
    pixi = {
      path = ./pixi;
      description = "Basic toolz pixi project template";
    };
    uv2nix = {
      path = ./uv2nix;
      description = "Python project template using uv2nix and flake-parts";
    };
  };

  perSystem = {pkgs, ...}: {
    # Template initialization app
    # Usage: nix run .#init-template -- <project-name> [directory]
    apps.init-template = {
      type = "app";
      program = "${pkgs.writeShellApplication {
        name = "init-template";
        runtimeInputs = with pkgs; [coreutils gnused findutils file gnugrep];
        text = builtins.readFile ./lib/init-template.sh;
      }}/bin/init-template";
    };
  };
}
