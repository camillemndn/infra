{ lib, pkgs, ... }:

{
  services.mysql = {
    enable = true;
    package = lib.mkForce pkgs.mariadb;

    settings = {
      mysql.pager = "${pkgs.less}/bin/less -SFX";
      mysqld.init-connect = "'SET NAMES utf8mb4'";
    };
  };
}
