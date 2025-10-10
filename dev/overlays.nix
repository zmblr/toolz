{self, ...}: {
  flake.overlays.default = final: _prev: {
    toolz = self.packages.${final.system};
  };
}
