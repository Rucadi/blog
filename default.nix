let 
    pkgs = import <nixpkgs> {};
    utils = import ./nixutils {inherit pkgs;};
    images = import ./images {inherit utils;};

    htmlGenerator = articleHtml : (import ./template.nix.html {inherit articleHtml; inherit images;});

    articles = pkgs.callPackage ./articles {inherit utils images htmlGenerator;};
    shortArticleHtmlList = pkgs.lib.foldl (acc: article: acc + article.shortArticle) '''' articles;

    index.html = pkgs.writeTextDir "site/index.html" (htmlGenerator shortArticleHtmlList);
in
pkgs.buildEnv {
    name = "site";
    paths = [
        index.html
        ./embed
        ] ++ map 
        (article: article.file) articles;
}
