# Records that no nginx virtual host implies, in dns.nix zone syntax.
{ machines }:

{
  "camillemondon.com".TXT = [
    "google-site-verification=Odt_5IG_8vzpI3cXbsDTdIHD6s6Zvi_Yca8O8aaFIKE"
  ];

  "ceciliaflamenca.com".TXT = [
    "google-site-verification=CDech686xA5kFgUs_Ndh-QJY-HtkoJLjOvegsh5VHH0"
  ];

  # Minecraft servers are routed by hostname.
  "mndn.fr".subdomains."*.mc" = {
    A = [ machines.zeppelin.ipv4.public ];
    AAAA = [ machines.zeppelin.ipv6.public ];
  };

  # Mail is hosted on mail.luj.fr.
  "varanda.fr" = {
    MX = [
      {
        preference = 10;
        exchange = "mail.luj.fr.";
      }
    ];
    SRV = [
      {
        service = "jmap";
        proto = "tcp";
        port = 443;
        target = "mail.luj.fr.";
      }
      {
        service = "imaps";
        proto = "tcp";
        port = 993;
        target = "mail.luj.fr.";
      }
      {
        service = "imap";
        proto = "tcp";
        port = 143;
        target = "mail.luj.fr.";
      }
      {
        service = "submissions";
        proto = "tcp";
        port = 465;
        target = "mail.luj.fr.";
      }
      {
        service = "submission";
        proto = "tcp";
        port = 587;
        target = "mail.luj.fr.";
      }
    ];
    TXT = [ "v=spf1 mx ra=postmaster -all" ];
    subdomains = {
      "mail".CNAME = [ "mail.luj.fr." ];
      "autoconfig".CNAME = [ "mail.luj.fr." ];
      "autodiscover".CNAME = [ "mail.luj.fr." ];
      "mta-sts".CNAME = [ "mail.luj.fr." ];
      "_mta-sts".TXT = [ "v=STSv1; id=17428246908727558748" ];
      "_dmarc".TXT = [
        "v=DMARC1; p=reject; rua=mailto:postmaster@varanda.fr; ruf=mailto:postmaster@varanda.fr"
      ];
      "_smtp._tls".TXT = [ "v=TLSRPTv1; rua=mailto:postmaster@varanda.fr" ];
      "202409e._domainkey".TXT = [
        "v=DKIM1; k=ed25519; h=sha256; p=LjKXhF6Z9YjRg7uxu2xhrURZLNae4IWzMeDI7xuwkY4="
      ];
      "202409r._domainkey".TXT = [
        "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7HbKz7lAiTkaC0BGWNKbly+LjZ7imX2aAOQmjpP9CBmGGYEWNmI5R7Zi1Mk+aUz0FMIPpbVB1FI+iuSUIRuArskZb8I5/zfR1zttgf2Ys/zuAbbGIM/pycUbLcrdCETVgi1A4/GWZ0oIcz7puaCH+Hvq1nfGNdwLJFPUaS5h86MEXqMOnU1ntANiSOARAA33p1MtAjDZZ6cLbPe1ZDOATOan5BhEUlgAvJ62l/O1cs52OXh1PWVDayZ4tfSvksi1uZqrb9dJv7gye0glrUDh1/As+fNgki06q/hCQlqb6UAYYIbkYHQlg8Ssn79gqAMbe3APLCgKxIGGx5FPii1sgwIDAQAB"
      ];
    };
  };
}
