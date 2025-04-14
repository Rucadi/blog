{utils, images}:
let double'' = "''";
dollar = "$";

website_image = (utils.file2base64 ./assets/website.jpg).htmlImage;
#In the post [what is nix](/what-is-nix.html) we explained a little bit of the key concepts of the nix language.

in
rec {
    name = "New era for error-handling in c++";
    category = "C++";
    date = "2025-03-15";
    authors = ["ruben"];
    content = builtins.readFile ./aaa.md;
}