{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = [
        pkgs.uv
      ];

      shellHook = ''
        export UV_PYTHON_DOWNLOADS=never

        if [[ ! -f "pyproject.toml" ]]; then
          uv init
        fi

        if [[ ! -d ".venv" ]]; then
          uv venv
        fi

        source .venv/bin/activate
      '';
    };
  };
}
