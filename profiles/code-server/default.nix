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

  # code-server refuses to enumerate a read-only extensions dir (it can't
  # write its `extensions.json` manifest there), so instead of building a
  # store-path extensions tree we hand it the raw VSIX files and let the
  # `--install-extension` codepath populate the writable user dir at startup.
  # Idempotent: re-installing an already-present same-version extension is a
  # no-op.
  extensionVsixs = [
    (vsixFromOpenVsx {
      publisher = "quarto";
      name = "quarto";
      version = "1.134.0";
      hash = "sha256-3ypPji5oSGqcfhCOvr4gMMCYiQvpSG2TDyMDOT9f++Q=";
    })
    # Peer-to-peer Live Share alternative (WebRTC, no relay server needed).
    (vsixFromOpenVsx {
      publisher = "kermanx";
      name = "p2p-live-share";
      version = "0.1.1";
      hash = "sha256-b5gaIRVLaUZPlgkidsZSdo1KksWkzFxFiB6TN9zYBNA=";
    })
    # Cell execution UI (Run Cell, kernel picker, inline output) — the
    # Quarto extension defers all notebook UI to ms-toolsai.jupyter.
    (vsixFromOpenVsx {
      publisher = "ms-toolsai";
      name = "jupyter";
      version = "2025.9.1";
      hash = "sha256-EQZgZWlExKsP9ofbSIwujFnGfsEh3PCbyqVLbt2c5x8=";
    })
    # Python LSP for chunks ```{python}```.
    (vsixFromOpenVsx {
      publisher = "ms-python";
      name = "python";
      version = "2026.4.0";
      hash = "sha256-Iyrq+wHwaYJP3ZLT5ijBxEK7z6HTzJRf+XB2NAuytKY=";
    })
    # R LSP for chunks ```{r}```. Open VSX preserves capital "R" in the
    # publisher slug.
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

lib.mkIf config.services.code-server.enable {
  services.code-server = {
    # Auth is enforced upstream by oauth2-proxy + Kanidm; expose no auth at
    # code-server itself, and bind to loopback so nothing else can reach it.
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

  systemd.services.code-server.serviceConfig.ExecStartPre = map (
    vsix: "${lib.getExe config.services.code-server.package} --install-extension ${vsix}"
  ) extensionVsixs;

  services.nginx.virtualHosts.${hostName} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString codePort}";
      proxyWebsockets = true;
    };
  };

  services.oauth2-proxy.nginx.virtualHosts.${hostName} = {
    # Kanidm emits groups as SPN (name@domain) in the `groups` claim.
    allowed_groups = [ "code_users@auth.mndn.fr" ];
  };

  services.kanidm.provision = {
    groups."code_users".members = [ "camille" ];
    persons.camille.groups = [
      "code_users"
      "sso_users"
    ];
  };
}
