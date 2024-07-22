{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.services.buildbot-nix.master.enable {

  services.buildbot-nix.master = {
    domain = "ci.mondon.xyz";
    workersFile = config.age.secrets.buildbot-nix-workers.path;
    admins = [ "camillemndn" ];
    buildSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    github = {
      authType.app = {
        id = 934127;
        secretKeyFile = config.age.secrets.github-app-secret.path;
      };
      oauthId = "Iv23lihsrM97J1A7Wv58";
      oauthSecretFile = config.age.secrets.github-oauth-secret.path;
      webhookSecretFile = config.age.secrets.github-webhook-secret.path;
      topic = "nix-ci";
    };
    evalWorkerCount = 10;
  };

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = config.age.secrets.buildbot-nix-worker-password.path;
  };

  systemd.services.buildbot-worker.path = lib.mkForce [
    pkgs.attic-client
    pkgs.git
    pkgs.openssh
    pkgs.gh
    pkgs.nix
    pkgs.nix-eval-jobs
    pkgs.coreutils
  ];

  services.nginx.virtualHosts."ci.mondon.xyz" = {
    forceSSL = true;
    enableACME = true;
  };

  age.secrets = {
    buildbot-nix-worker-password = {
      file = ./buildbot-nix-worker-password.age;
      owner = "buildbot-worker";
    };
    buildbot-nix-workers.file = ./buildbot-nix-workers.age;
    github-app-secret.file = ./github-app-secret.age;
    github-oauth-secret.file = ./github-oauth-secret.age;
    github-webhook-secret.file = ./github-webhook-secret.age;
  };

  services.buildbot-master = {
    pythonPackages = _: [
      pkgs.buildbot-plugins.badges
      pkgs.buildbot-plugins.www
    ];
    extraConfig = ''
      c["www"].update({"plugins": {"badges": {
        "left_pad"  : 5,
        "left_text": "Build Status",  # text on the left part of the image
        "left_color": "#555",  # color of the left part of the image
        "right_pad" : 5,
        "border_radius" : 5, # Border Radius on flat and plastic badges
        # style of the template availables are "flat", "flat-square", "plastic"
        "template_name": "flat.svg.j2",  # name of the template
        "font_face": "DejaVu Sans",
        "font_size": 11,
        "color_scheme": {  # color to be used for right part of the image
          "exception": "#007ec6", 
          "failure": "#e05d44",    
          "retry": "#007ec6",      
          "running": "#007ec6",   
          "skipped": "a4a61d",   
          "success": "#4c1",      
          "unknown": "#9f9f9f",   
          "warnings": "#dfb317"   
          } 
      }}})
    '';
  };
}
