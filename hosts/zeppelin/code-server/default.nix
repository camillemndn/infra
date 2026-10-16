{
  config,
  lib,
  pkgs,
  ...
}:

let
  hostName = "code.mndn.fr";
  codePort = 4444;
  vsixFromOpenVsx =
    {
      publisher,
      name,
      version,
      hash,
    }:
    pkgs.fetchurl {
      url = "https://open-vsx.org/api/${publisher}/${name}/${version}/file/${publisher}.${name}-${version}.vsix";
      inherit hash;
    };
  # code-server cannot use a read-only extensions dir: the VSIX files are
  # installed into the user dir at startup, which is a no-op when present.
  extensionVsixs = [
    (vsixFromOpenVsx {
      publisher = "quarto";
      name = "quarto";
      version = "1.134.0";
      hash = "sha256-3ypPji5oSGqcfhCOvr4gMMCYiQvpSG2TDyMDOT9f++Q=";
    })
    # Live Share alternative over WebRTC.
    (vsixFromOpenVsx {
      publisher = "kermanx";
      name = "p2p-live-share";
      version = "0.1.1";
      hash = "sha256-b5gaIRVLaUZPlgkidsZSdo1KksWkzFxFiB6TN9zYBNA=";
    })
    # Notebook UI, which the Quarto extension relies on.
    (vsixFromOpenVsx {
      publisher = "ms-toolsai";
      name = "jupyter";
      version = "2025.9.1";
      hash = "sha256-EQZgZWlExKsP9ofbSIwujFnGfsEh3PCbyqVLbt2c5x8=";
    })
    # Python LSP for Quarto chunks.
    (vsixFromOpenVsx {
      publisher = "ms-python";
      name = "python";
      version = "2026.4.0";
      hash = "sha256-Iyrq+wHwaYJP3ZLT5ijBxEK7z6HTzJRf+XB2NAuytKY=";
    })
    # R LSP for Quarto chunks; Open VSX keeps the capital R.
    (vsixFromOpenVsx {
      publisher = "REditorSupport";
      name = "r";
      version = "2.8.8";
      hash = "sha256-mt2bes7aHcAHLMngSLW/zI3kSIzNKALqX+g0UXo84uI=";
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
      host = "127.0.0.1";
      port = codePort;
      disableTelemetry = true;
      extraPackages = [
        pkgs.git
        pkgs.pandoc
        pkgs.quarto
        pkgs.texliveMedium
        pythonKernelEnv
        rKernelEnv
      ];
    };
    nginx.virtualHosts.${hostName} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString codePort}";
        proxyWebsockets = true;
      };
    };
    oauth2-proxy.nginx.virtualHosts.${hostName} = {
      # Kanidm sends groups as name@domain.
      allowed_groups = [ "code_users@auth.mndn.fr" ];
    };
    kanidm.provision = {
      groups."code_users".members = [ "camille" ];
      persons.camille.groups = [
        "code_users"
        "sso_users"
      ];
    };
  };

  systemd.services.code-server.serviceConfig.ExecStartPre = map (
    vsix: "${lib.getExe config.services.code-server.package} --install-extension ${vsix}"
  ) extensionVsixs;
}
