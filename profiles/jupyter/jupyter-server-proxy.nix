{
  lib,
  buildPythonPackage,
  fetchPypi,
  aiohttp,
  jupyter-server,
  simpervisor,
  tornado,
  traitlets,
}:

buildPythonPackage rec {
  pname = "jupyter-server-proxy";
  version = "4.5.0";
  format = "wheel";

  src = fetchPypi {
    pname = "jupyter_server_proxy";
    inherit version format;
    dist = "py3";
    python = "py3";
    hash = "sha256-PjN2+N5iqoZiPmHYQHb+r8qnMbXK9t618N1fem50/SQ=";
  };

  propagatedBuildInputs = [
    aiohttp
    jupyter-server
    simpervisor
    tornado
    traitlets
  ];

  pythonImportsCheck = [ "jupyter_server_proxy" ];

  meta = {
    description = "Jupyter Server extension to supervise and proxy web services";
    homepage = "https://github.com/jupyterhub/jupyter-server-proxy";
    license = lib.licenses.bsd3;
  };
}
