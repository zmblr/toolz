{
  perSystem = {
    pkgs,
    python,
    workspace,
    pythonSetEditable,
    ...
  }: let
    # Create a virtual environment with editable installs for development
    virtualenv = pythonSetEditable.mkVirtualEnv "PROJ_NAME-dev-env" workspace.deps.all;
  in {
    devShells = {
      # Default development shell with editable installs
      default = pkgs.mkShell {
        packages = [
          virtualenv
          pkgs.uv
        ];

        env = {
          UV_NO_SYNC = "1";
          UV_PYTHON = python.interpreter;
          UV_PYTHON_DOWNLOADS = "never";
        };

        shellHook = ''
          unset PYTHONPATH
          export REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
        '';
      };

      # Alternative shell without editable installs (for testing production builds)
      prod = pkgs.mkShell {
        packages = [
          pkgs.uv
        ];

        env = {
          UV_NO_SYNC = "1";
          UV_PYTHON = python.interpreter;
          UV_PYTHON_DOWNLOADS = "never";
        };

        shellHook = ''
          unset PYTHONPATH
          export REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
        '';
      };
    };
  };
}
