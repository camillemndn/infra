{
  config,
  lib,
  pkgs,
  ...
}:

let
  hostName = "jupyter.mndn.fr";
  jupyterPort = 8888;

  pythonKernelEnv = pkgs.python3.withPackages (
    ps: with ps; [
      ipykernel
      matplotlib
      numpy
      pandas
    ]
  );

  rKernelEnv = pkgs.rWrapper.override {
    packages = with pkgs.rPackages; [
      IRkernel
      knitr
      rmarkdown
    ];
  };
in

lib.mkIf config.services.jupyter.enable {
  services.jupyter = {
    command = "jupyter-lab";
    ip = "127.0.0.1";
    port = jupyterPort;
    password = "argon2:$argon2id$v=19$m=10240,t=10,p=8$N6CLP6dzJ0Qefdw/tsthGw$r6DV2XrZQd9cAABQFZo5PCMHtYpMxAPqiIzsiCkbxI4";

    package = pkgs.python3.pkgs.jupyterlab;
    extraPackages =
      let
        ps = pkgs.python3.pkgs;
        simpervisor = ps.callPackage ./simpervisor.nix { };
      in
      [
        ps.jupyter-collaboration
        ps.jupyterlab-git
        ps.jupytext
        ps.notebook
        simpervisor
        (ps.callPackage ./jupyter-server-proxy.nix { inherit simpervisor; })
        (ps.callPackage ./jupyterlab-quarto.nix { })
      ];

    kernels = {
      python3 = {
        displayName = "Python 3";
        language = "python";
        argv = [
          "${pythonKernelEnv}/bin/python"
          "-m"
          "ipykernel_launcher"
          "-f"
          "{connection_file}"
        ];
      };
      ir = {
        displayName = "R";
        language = "R";
        argv = [
          "${rKernelEnv}/bin/R"
          "--slave"
          "-e"
          "IRkernel::main()"
          "--args"
          "{connection_file}"
        ];
      };
    };

    notebookConfig = ''
      c.ServerApp.token = ""
      c.ServerApp.password = ""
      c.ServerApp.trust_xheaders = True
      c.ServerApp.allow_remote_access = True
      c.ServerApp.allow_origin = "https://${hostName}"
      c.IdentityProvider.token = ""

      # Open .qmd / .py / .md / .Rmd as notebooks via jupytext.
      c.ServerApp.contents_manager_class = "jupytext.TextFileContentsManager"
    '';
  };

  systemd.services.jupyter.path = with pkgs; [
    quarto
    pandoc
    texliveMedium
    git
  ];

  services.nginx.virtualHosts.${hostName} = {
    port = jupyterPort;
    websockets = true;
  };

  services.oauth2-proxy.nginx.virtualHosts.${hostName} = {
    # Kanidm emits groups as SPN (name@domain) in the `groups` claim.
    allowed_groups = [ "jupyter_users@auth.mndn.fr" ];
  };

  services.kanidm.provision = {
    groups."jupyter_users".members = [ "camille" ];
    persons.camille.groups = [
      "jupyter_users"
      "sso_users"
    ];
  };
}
