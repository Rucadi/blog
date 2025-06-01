{utils, images}:
let double'' = "''";
dollar = "$";

website_image = (utils.file2base64 ./assets/website.jpg).htmlImage;
#In the post [what is nix](/what-is-nix.html) we explained a little bit of the key concepts of the nix language.

in
rec {
    name = "Why I no longer use c++ inheritance ";
    category = "C++";
    date = "2025-04-13";
    authors = ["ruben"];
    content = (builtins.readFile ./part1.md) + (builtins.readFile ./part2.md) + (builtins.readFile ./part3.md);
}