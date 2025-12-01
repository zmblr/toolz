// Website configuration - edit this file to customize branches and settings
const CONFIG = {
  // GitHub repository (owner/repo format)
  githubRepo: 'zmblr/toolz',

  // Available branches (first one is the default)
  branches: [
    'release-25.05',
    'release-25.11',
    'unstable'
  ],

  // Get default branch (first in the list)
  get defaultBranch() {
    return this.branches[0];
  },

  // Generate nix command for a package
  nixShellCmd(branch, pkgName) {
    return `nix shell github:${this.githubRepo}/${branch}#${pkgName}`;
  },

  nixRunCmd(branch, pkgName) {
    return `nix run github:${this.githubRepo}/${branch}#${pkgName}`;
  }
};
