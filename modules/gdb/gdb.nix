# gdb startup file: a vendored copy of gdb-dashboard
# (https://github.com/cyrus-and/gdb-dashboard, MIT). gdb itself comes from the
# host. nixpkgs' gdb-dashboard pins its own Python path, which may not match
# the host gdb's Python, so the plain file is kept instead.
{
  flake.modules.homeManager.gdb = {
    home.file.".gdbinit".source = ./gdbinit;
  };
}
