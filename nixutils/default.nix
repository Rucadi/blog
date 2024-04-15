{pkgs}:
{
    file2base64 = pkgs.callPackage ./file2base64.nix {  };
    fixedString = pkgs.callPackage ./fixedString.nix {  };
    string2uri = pkgs.callPackage ./string2uri.nix {  };
}