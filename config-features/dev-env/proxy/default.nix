{ ... }:
let
  proxyUrl = "http://localhost:5865";
in
{
  home.sessionVariables = {
    HTTP_PROXY = proxyUrl;
    HTTPS_PROXY = proxyUrl;
    YARN_HTTP_PROXY = proxyUrl;
    YARN_HTTPS_PROXY = proxyUrl;
    http_proxy = proxyUrl;
    https_proxy = proxyUrl;
    NO_PROXY = "systrans-gitlab.appli-services.com,localhost,127.0.0.1";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  };
}
