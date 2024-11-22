{ lib
, callPackage
, fetchFromGitHub
, python3Packages
}:
/*
** To customize the enabled beets plugins, use the pluginOverrides input to the
** derivation.
** Examples:
**
** Disabling a builtin plugin:
** beets.override { pluginOverrides = { beatport.enable = false; }; }
**
** Enabling an external plugin:
** beets.override { pluginOverrides = {
**   alternatives = { enable = true; propagatedBuildInputs = [ beetsPackages.alternatives ]; };
** }; }
*/
lib.makeExtensible (self: {
  beets = self.beets-stable;

  beets-stable = callPackage ./common.nix rec {
    inherit python3Packages;
    version = "2.1.0";
    src = fetchFromGitHub {
      owner = "beetbox";
      repo = "beets";
      rev = "v${version}";
      hash = "sha256-XBNWPchIrWnS0gXDbTspxY+KjHPjkSinvYcW8xBFGAE=";
    };
    extraPatches = [
      # Bash completion fix for Nix
      ./patches/bash-completion-always-print.patch
    ];
  };

  beets-minimal = self.beets.override { disableAllPlugins = true; };

  beets-unstable = callPackage ./common.nix {
    inherit python3Packages;
    version = "2.1.0-unstable-2024-11-22";
    src = fetchFromGitHub {
      owner = "beetbox";
      repo = "beets";
      rev = "ef328ed7404544bcc5d82c4d5d448823b097fc23";
      hash = "sha256-K5NE1bMdFw19/mAEO+klfebtUJ9GS2xnbRisqdVm9Vs=";
    };
    extraPatches = [
      # Bash completion fix for Nix
      ./patches/bash-completion-always-print.patch
    ];
  };

  alternatives = callPackage ./plugins/alternatives.nix { beets = self.beets-minimal; };
  copyartifacts = callPackage ./plugins/copyartifacts.nix { beets = self.beets-minimal; };

  extrafiles = throw "extrafiles is unmaintained since 2020 and broken since beets 2.0.0";
})
