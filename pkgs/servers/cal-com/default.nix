{ lib
, mkYarnPackage
, fetchFromGitHub
, fixup_yarn_lock
, nodejs-16_x
, git
, prisma-engines
, makeWrapper
, yarn
}:

mkYarnPackage rec {
  pname = "cal-com";
  version = "2.6.3";

  src = fetchFromGitHub {
    owner = "calcom";
    repo = "cal.com";
    rev = "v${version}";
    hash = "sha256-Yb5uj/CoYNvTRDL4wZ+jPRNu+TFHeHcocgWKo1EV69k=";
  };

  nativeBuildInputs = [ fixup_yarn_lock yarn git nodejs-16_x makeWrapper prisma-engines ];

  buildPhase = ''
    export PRISMA_MIGRATION_ENGINE_BINARY="${prisma-engines}/bin/migration-engine"
    export PRISMA_QUERY_ENGINE_BINARY="${prisma-engines}/bin/query-engine"
    export PRISMA_QUERY_ENGINE_LIBRARY="${prisma-engines}/lib/libquery_engine.node"
    export PRISMA_INTROSPECTION_ENGINE_BINARY="${prisma-engines}/bin/introspection-engine"
    export PRISMA_FMT_BINARY="${prisma-engines}/bin/prisma-fmt"

    export HOME=$(mktemp -d)
    cd deps/calcom-monorepo
    rm node_modules
    mv ../../node_modules .
    ls -all node_modules
    yarn build #--cache-dir="./.turbo"
    #yarn workspace "@calcom/web" run start --cache-dir="$HOME"
  '';

  postInstall = ''
    makeWrapper '${yarn}/bin/yarn' $out/bin/cal-com \
      --add-flags start \
      --chdir $out/libexec/cal-com/deps/cal-com \
      --set NODE_ENV production
  '';

  doDist = false;

  meta = with lib; {
    description = "Scheduling infrastructure for absolutely everyone";
    homepage = "https://github.com/calcom/cal.com";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
  };
}
