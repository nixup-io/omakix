{
  testers,
  home-manager-module,
  omakix-module,
  writeShellScriptBin,
}: let
  script = writeShellScriptBin "omakix-basic-test" ''
    set -eu

    export XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}

    assert_eq() {
      want=$1
      shift
      actual=$@

      if [ "$actual" != "$want" ]; then
        echo >&2 "ERROR: $@: expected $want but got $actual"
        exit 1
      fi
    }

    assert_eq foo bar
  '';
in
  testers.nixosTest {
    name = "omakix-basic";

    nodes.machine = {
      environment.systemPackages = [script];
      imports = [home-manager-module];

      users.users.fake = {
        createHome = true;
        isNormalUser = true;
      };

      home-manager.users.fake = {lib, ...}: {
        home.stateVersion = "24.05";
        imports = [omakix-module];
        omakix = {
          enable = true;
          theme = "tokyo-night";
          font = "CaskaydiaMono Nerd Font";
        };
      };
    };

    testScript = ''
      # Boot:
      start_all()
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("home-manager-fake.service")

      # Run tests:
      machine.succeed("test -e /home/fake/.config/ulauncher/settings.json")
      machine.succeed("su - fake -c omakix-basic-test")
    '';
  }
