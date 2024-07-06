{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.wlogout.enable {
  programs.wlogout = {
    style = ''
      @import url("${pkgs.wlogout}/etc/wlogout/style.css");
      window {
          font-family: "FiraCode Nerd Font Mono";
          font-weight: bold;
          font-size: 14pt;
          color: #cdd6f4;
          background-color: rgba(30, 30, 46, 0.85);
      }
      button {
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          border: none;
          background-color: rgba(30, 30, 46, 0);
          margin: 5px;
          transition: box-shadow 0.2s ease-in-out, background-color 0.2s ease-in-out;
      }
      button:hover {
          background-color: rgba(49, 50, 68, 0.1);
      }
      button:focus {
          background-color: #cba6f7;
          color: #1e1e2e;
      }
      #lock:focus {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/lock.svg"));
      }

      #logout:focus {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/logout.svg"));
      }

      #suspend:focus {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/suspend.svg"));
      }

      #hibernate:focus {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/hibernate.svg"));
      }

      #shutdown:focus {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/shutdown.svg"));
      }

      #reboot:focus {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/reboot.svg"));
      }
    '';
  };
}
