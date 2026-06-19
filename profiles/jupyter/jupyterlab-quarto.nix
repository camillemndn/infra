{
  lib,
  buildPythonPackage,
  fetchPypi,
  jupyterlab,
}:

buildPythonPackage rec {
  pname = "jupyterlab-quarto";
  version = "0.3.5";
  format = "wheel";

  src = fetchPypi {
    pname = "jupyterlab_quarto";
    inherit version format;
    dist = "py3";
    python = "py3";
    sha256 = "114165409aaad2e68202374ab3d02b08015ed3898427d81bdb3fe9f995e151b9";
  };

  propagatedBuildInputs = [ jupyterlab ];

  # Pure JupyterLab extension: ships labextension assets under
  # share/jupyter/labextensions, no importable Python module.
  doCheck = false;
  dontUsePythonImportsCheck = true;

  meta = {
    description = "JupyterLab extension for Quarto: in-lab preview and chunk awareness";
    homepage = "https://github.com/quarto-dev/quarto";
    license = lib.licenses.mit;
  };
}
