# nix-shell — dev shell with the patch tooling
{ pkgs ? import <nixpkgs> {} }: pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    git
    gnupatch
    quilt
    diffutils
    coreutils
    bashInteractive
  ];
}
