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
}
