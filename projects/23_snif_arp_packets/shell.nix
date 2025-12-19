{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.wireshark

  ];

  shellHook = ''
    echo "Wireshark is available in this shell."
  '';
}
