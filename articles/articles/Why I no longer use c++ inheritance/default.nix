{utils, images}:
let double'' = "''";
dollar = "$";

website_image = (utils.file2base64 ./graphic.png).htmlImage;
#In the post [what is nix](/what-is-nix.html) we explained a little bit of the key concepts of the nix language.

in
rec {
    name = "Why I no longer use c++ inheritance ";
    category = "C++";
    date = "2025-06-05";
    authors = ["ruben"];
    content = (builtins.readFile ./intro.md) + (builtins.readFile ./part1.md) + (builtins.readFile ./part2.md) + (builtins.readFile ./part3.md) + (builtins.readFile ./part4.md) + website_image;
}