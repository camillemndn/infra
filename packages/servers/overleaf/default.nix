{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, nodejs
, nodePackages
, sqlite
, fetchYarnDeps
, python3
, jq
, yarn2nix-moretea
}:

let
  yarn2nix = yarn2nix-moretea //
    {
      mkYarnPackage.installPhase = let pname = yarn2nix-moretea.mkYarnPackage.pname; in
        ''
          runHook preInstall

          mkdir -p $out/{bin,libexec/${pname}}
          mv node_modules $out/libexec/${pname}/node_modules
          mv deps $out/libexec/${pname}/deps


          runHook postInstall
        '';
    };
  workspace = yarn2nix-moretea.mkYarnWorkspace
    {
      src = fetchFromGitHub {
        owner = "overleaf";
        repo = "overleaf";
        rev = "4f89588fb4195b1314155557d0497563acf4a1b4";
        sha256 = "sha256-Le+BaxKBKm4zYb9GIOxWkl8AezptqgRmJiu/2/tK0AI=";
      };
      version = "unstable";

      nativeBuildInputs = [ jq ];

      postPatch = ''
        #for i in $(find . -name "package.json")
        #do
        i="package.json"
        if [ -z $(jq '.version // empty' "$i") ]
          then
            cat <<< "$(jq '. + { version: "1.0.0" }' "$i")" > "$i"
        fi
        #done
        cat $i 
      '';

      yarnLock = ./yarn.lock;
    };
in
let
  work = workspace // {
    overleaf-ranges-tracker = workspace.overleaf-ranges-tracker.overrideAttrs (final: prev: {
      installPhase = ''
        runHook preInstall

        mkdir -p $out/{bin,libexec/@overleaf/ranges-tracker}
        mv node_modules $out/libexec/@overleaf/ranges-tracker/node_modules
        mv deps $out/libexec/@overleaf/ranges-tracker/deps

        runHook postInstall
      '';
    });
    overleaf-o-error = workspace.overleaf-o-error.overrideAttrs (final: prev: {
      installPhase = ''
        runHook preInstall

        mkdir -p $out/{bin,libexec/@overleaf/o-error}
        mv node_modules $out/libexec/@overleaf/o-error/node_modules
        mv deps $out/libexec/@overleaf/o-error/deps

        runHook postInstall
      '';
    });
  };

  overleaf-chat = work.overleaf-chat.overrideAttrs (final: prev: {
    doDist = false;
    pname = "overleaf-chat";
    buildInputs = [ nodejs makeWrapper ];
    postInstall = ''
      makeWrapper '${nodejs}/bin/node' "$out/bin/overleaf-chat" \
        --add-flags "$out/libexec/@overleaf/chat/deps/@overleaf/chat/app.js" \
        --set NODE_ENV production
    '';
  });
in

workspace.overleaf-web.overrideAttrs (final: prev: {
  doDist = false;
  nativeBuildInputs = [ nodePackages.webpack ];
  installPhase = ''
    cd deps/@overleaf/web
    yarn run webpack:production  
  '';
})
