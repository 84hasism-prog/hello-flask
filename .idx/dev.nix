# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.postgresql    # För lokal databashantering
    pkgs.openssl       # För att generera hemliga nycklar
  ];

  # Sets environment variables in the workspace
  env = {
    FLASK_APP = "app.py";
    FLASK_ENV = "development";
    DATABASE_URL = "sqlite:///newsflash.db";
  };

  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "ms-python.python"
      "google.gemini-cli-vscode-ide-companion"
    ];

    # Enable previews
    previews = {
      enable = true;
      previews = {
        web = {
          # Kör Flask på porten IDX förväntar sig
          command = ["python3" "-m" "flask" "run" "--port" "$PORT" "--host" "0.0.0.0"];
          manager = "web";
        };
      };
    };

    # Workspace lifecycle hooks
    workspace = {
      # Runs when a workspace is first created
      onCreate = {
        # Skapa virtuell miljö och installera paket automatiskt
        setup-venv = ''
          python -m venv .venv
          source .venv/bin/activate
          pip install flask flask-sqlalchemy flask-migrate python-dotenv gunicorn
        '';
      };
      # Runs when the workspace is (re)started
      onStart = {
        # Aktivera venv varje gång terminalen öppnas
        activate-venv = "source .venv/bin/activate";
      };
    };
  };
}