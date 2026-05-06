{ ... }:
{
  home.sessionVariables = {
    HTTP_PROXY = "http://localhost:5865";
    HTTPS_PROXY = "http://localhost:5865";
    http_proxy = "http://localhost:5865";
    https_proxy = "http://localhost:5865";
    NO_PROXY = "systrans-gitlab.appli-services.com,localhost,127.0.0.1";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  };
}
