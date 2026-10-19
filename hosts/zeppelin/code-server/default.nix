{
  config,
  lib,
  pkgs,
  ...
}:

let
  hostName = "code.mndn.fr";

  vsixFromOpenVsx =
    {
      publisher,
      name,
      version,
      hash,
    }:
    pkgs.fetchurl {
      inherit hash;
      url = "https://open-vsx.org/api/${publisher}/${name}/${version}/file/${publisher}.${name}-${version}.vsix";
    };

  # code-server cannot use a read-only extensions dir: the VSIX files are
  # installed into the user dir at startup, which is a no-op when present.
  extensionVsixs = [
    (vsixFromOpenVsx {
      hash = "sha256-3ypPji5oSGqcfhCOvr4gMMCYiQvpSG2TDyMDOT9f++Q=";
      name = "quarto";
      publisher = "quarto";
      version = "1.134.0";
    })
    # Live Share alternative over WebRTC.
    (vsixFromOpenVsx {
      hash = "sha256-b5gaIRVLaUZPlgkidsZSdo1KksWkzFxFiB6TN9zYBNA=";
      name = "p2p-live-share";
      publisher = "kermanx";
      version = "0.1.1";
    })
    # Notebook UI, which the Quarto extension relies on.
    (vsixFromOpenVsx {
      hash = "sha256-EQZgZWlExKsP9ofbSIwujFnGfsEh3PCbyqVLbt2c5x8=";
      name = "jupyter";
      publisher = "ms-toolsai";
      version = "2025.9.1";
    })
    # Python LSP for Quarto chunks.
    (vsixFromOpenVsx {
      hash = "sha256-Iyrq+wHwaYJP3ZLT5ijBxEK7z6HTzJRf+XB2NAuytKY=";
      name = "python";
      publisher = "ms-python";
      version = "2026.4.0";
    })
    # R LSP for Quarto chunks; Open VSX keeps the capital R.
    (vsixFromOpenVsx {
      hash = "sha256-mt2bes7aHcAHLMngSLW/zI3kSIzNKALqX+g0UXo84uI=";
      name = "r";
      publisher = "REditorSupport";
      version = "2.8.8";
    })
  ];

  pythonKernelEnv = pkgs.python3.withPackages (
    ps: with ps; [
      ipykernel
      jupyter
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

{
  services = {
    code-server = {
      enable = true;
      # oauth2-proxy and Kanidm authenticate; listen on loopback only.
      auth = "none";
      disableTelemetry = true;

      extraPackages = [
        pkgs.git
        pkgs.pandoc
        pkgs.quarto
        pkgs.texliveMedium
        pythonKernelEnv
        rKernelEnv
      ];

      host = "127.0.0.1";
    };

    kanidm.provision = {
      groups."code_users".members = [ "camille" ];

      persons.camille.groups = [
        "code_users"
        "sso_users"
      ];
    };

    nginx.virtualHosts.${hostName} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.code-server.port}";
        proxyWebsockets = true;
      };
    };

    oauth2-proxy.nginx.virtualHosts.${hostName} = {
      # Kanidm sends groups as name@domain.
      allowed_groups = [ "code_users@auth.mndn.fr" ];
    };
  };

  systemd.services.code-server.serviceConfig.ExecStartPre = map (
    vsix: "${lib.getExe config.services.code-server.package} --install-extension ${vsix}"
  ) extensionVsixs;
}
