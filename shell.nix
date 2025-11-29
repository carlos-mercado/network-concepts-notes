{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {

  # Packages you want available in the shell
  packages = with pkgs; [
    typst-live
  ];

}
