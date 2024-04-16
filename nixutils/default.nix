{pkgs}:
{
    file2base64 = uri: (pkgs.callPackage ./file2base64.nix { }) {inherit uri;};
    fixedString = pkgs.callPackage ./fixedString.nix {  };
    string2uri = str : (pkgs.callPackage ./string2uri.nix {  }) {inherit str;};
    md2html = markdown : (pkgs.callPackage ./md2html.nix {  }) {inherit markdown;};
}