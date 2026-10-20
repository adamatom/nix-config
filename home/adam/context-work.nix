{
  pkgs,
  lib,
  wrapGL,
  ...
}:

{
  home.packages = lib.mkAfter [
    (wrapGL pkgs.slack)
  ];

}
