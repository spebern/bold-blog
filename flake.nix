{
  description = "bold's blog";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, devshell }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };
      in
      {
        devShell = pkgs.devshell.mkShell {
          packages = with pkgs; [
            hugo
          ];
          commands = [
            {
              name = "build";
              category = "build";
              command = ''hugo'';
            }
            {
              name = "run";
              category = "build";
              command = "hugo server -D";
            }
            {
              name = "publish";
              category = "build";
              command = ''
                read -p "Are you sure? " -n 1 -r
                echo    # (optional) move to a new line
                if [[ $REPLY =~ ^[Yy]$ ]]
                then
                  hugo
                  cd public
                  git checkout main
                  git add .
                  git commit -a -m "publish"
                  git push
                fi
              '';
            }
          ];
          env = [];
        };
      });
}
