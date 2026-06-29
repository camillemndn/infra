{
  config,
  lib,
  pkgs,
  ...
}:

let
  hostName = "code.mndn.fr";
  codePort = 4444;

  # nixpkgs' buildVscodeMarketplaceExtension defaults to the MS Marketplace,
  # but accepts a `vsix` override — we pipe the VSIX from Open VSX so we stay
  # on the open registry (and pick up the typefox/quarto/kermanx publishers
  # who don't publish to MS).
  openVsxExt =
    {
      publisher,
      name,
      version,
      hash,
    }:
    pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = { inherit publisher name version; };
      vsix = pkgs.fetchurl {
        url = "https://open-vsx.org/api/${publisher}/${name}/${version}/file/${publisher}.${name}-${version}.vsix";
        inherit hash;
      };
    };

  extensionsDir = pkgs.symlinkJoin {
    name = "code-server-extensions";
    paths = [
      (openVsxExt {
        publisher = "quarto";
        name = "quarto";
        version = "1.134.0";
        hash = "sha256-3ypPji5oSGqcfhCOvr4gMMCYiQvpSG2TDyMDOT9f++Q=";
      })
      # Peer-to-peer Live Share alternative (WebRTC, no relay server needed).
      (openVsxExt {
        publisher = "kermanx";
        name = "p2p-live-share";
        version = "0.1.1";
        hash = "sha256-b5gaIRVLaUZPlgkidsZSdo1KksWkzFxFiB6TN9zYBNA=";
      })
    ];
  };

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
    extensionsDir = "${extensionsDir}/share/vscode/extensions";
    extraPackages = [
      pkgs.git
      pkgs.pandoc
      pkgs.quarto
      pkgs.texliveMedium
      pythonKernelEnv
      rKernelEnv
    ];
  };

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
