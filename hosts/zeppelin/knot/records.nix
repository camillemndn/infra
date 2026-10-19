# Records no nginx virtual host implies, in dns.nix syntax.
{ hosts }:

{
  "camillemondon.com".TXT = [
    "google-site-verification=Odt_5IG_8vzpI3cXbsDTdIHD6s6Zvi_Yca8O8aaFIKE"
  ];

  "ceciliaflamenca.com".TXT = [
    "google-site-verification=CDech686xA5kFgUs_Ndh-QJY-HtkoJLjOvegsh5VHH0"
  ];

  # Minecraft servers are routed by hostname.
  "mndn.fr".subdomains."*.mc" = {
    A = [ hosts.zeppelin.ipv4.public ];
    AAAA = [ hosts.zeppelin.ipv6.public ];
  };

  # Mail is hosted on mail.luj.fr.
  "varanda.fr" = {
    MX = [
      {
        exchange = "mail.luj.fr.";
        preference = 10;
      }
    ];

    SRV = [
      {
        port = 443;
        proto = "tcp";
        service = "jmap";
        target = "mail.luj.fr.";
      }
      {
        port = 993;
        proto = "tcp";
        service = "imaps";
        target = "mail.luj.fr.";
      }
      {
        port = 143;
        proto = "tcp";
        service = "imap";
        target = "mail.luj.fr.";
      }
      {
        port = 465;
        proto = "tcp";
        service = "submissions";
        target = "mail.luj.fr.";
      }
      {
        port = 587;
        proto = "tcp";
        service = "submission";
        target = "mail.luj.fr.";
      }
    ];

    TXT = [ "v=spf1 mx ra=postmaster -all" ];

    subdomains = {
      "202409e._domainkey".TXT = [
        "v=DKIM1; k=ed25519; h=sha256; p=LjKXhF6Z9YjRg7uxu2xhrURZLNae4IWzMeDI7xuwkY4="
      ];

      "202409r._domainkey".TXT = [
        "v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7HbKz7lAiTkaC0BGWNKbly+LjZ7imX2aAOQmjpP9CBmGGYEWNmI5R7Zi1Mk+aUz0FMIPpbVB1FI+iuSUIRuArskZb8I5/zfR1zttgf2Ys/zuAbbGIM/pycUbLcrdCETVgi1A4/GWZ0oIcz7puaCH+Hvq1nfGNdwLJFPUaS5h86MEXqMOnU1ntANiSOARAA33p1MtAjDZZ6cLbPe1ZDOATOan5BhEUlgAvJ62l/O1cs52OXh1PWVDayZ4tfSvksi1uZqrb9dJv7gye0glrUDh1/As+fNgki06q/hCQlqb6UAYYIbkYHQlg8Ssn79gqAMbe3APLCgKxIGGx5FPii1sgwIDAQAB"
      ];

      "_dmarc".TXT = [
        "v=DMARC1; p=reject; rua=mailto:postmaster@varanda.fr; ruf=mailto:postmaster@varanda.fr"
      ];

      "_mta-sts".TXT = [ "v=STSv1; id=17428246908727558748" ];
      "_smtp._tls".TXT = [ "v=TLSRPTv1; rua=mailto:postmaster@varanda.fr" ];
      "autoconfig".CNAME = [ "mail.luj.fr." ];
      "autodiscover".CNAME = [ "mail.luj.fr." ];
      "mail".CNAME = [ "mail.luj.fr." ];
      "mta-sts".CNAME = [ "mail.luj.fr." ];
    };
  };
}
