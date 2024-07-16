{
  testers,
  home-manager-module,
  omakix-module,
}:
testers.nixosTest {
  name = "omakix-basic";

  nodes.machine = {
    imports = [
      home-manager-module
      {home-manager.useGlobalPkgs = true;}
    ];

    programs.dconf.enable = true;

    users.users.fake = {
      createHome = true;
      isNormalUser = true;
    };

    home-manager.users.fake = {lib, ...}: {
      home.stateVersion = "24.05";
      imports = [omakix-module];
      omakix = {
        enable = true;
        theme = "everforest";
        font = "cascadia-mono";
        browser = "firefox";
      };
    };
  };

  testScript = ''
    # Boot:
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_unit("home-manager-fake.service")

    # Run tests:
    machine.succeed("test -e /home/fake/.config/alacritty/alacritty.toml")
    machine.succeed("test -e /home/fake/.config/git/config")
    machine.succeed("test -e /home/fake/.config/dconf/user")
    machine.succeed("test -e /home/fake/.XCompose")
    machine.succeed("test -e /home/fake/.config/mise/config.toml")
    machine.succeed("test -d /home/fake/.config/Typora/themes")
    machine.succeed("test -e /home/fake/.config/ulauncher/settings.json")
    machine.succeed("test -e /home/fake/.config/autostart/ulauncher.desktop")
    machine.succeed("test -e /home/fake/.config/zellij/config.kdl")
    machine.succeed("test -d /home/fake/.config/zellij/themes")
  '';
}
