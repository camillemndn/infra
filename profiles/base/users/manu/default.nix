_:

{
  users.users.manu = {
    isNormalUser = true;
  };

  services.openssh.extraConfig = ''
    PasswordAuthentication no
    Match User manu
    PasswordAuthentication yes
  '';
}
