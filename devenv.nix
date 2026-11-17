{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  languages.terraform = {
    enable = true;
    version = "1.15.9";
  };

  enterTest = ''
    terraform init -backend=false -input=false
    terraform test
  '';
}
