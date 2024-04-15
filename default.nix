let 
    pkgs = import <nixpkgs> {};
    utils = import ./nixutils {inherit pkgs;};
    articles = pkgs.callPackage ./articles {inherit utils;};
    #######################atricles##########################
    articlesWithExtras = map (article: article // {
            shortContent = utils.fixedString { str=article.content; len=300;};
            uri = "${utils.string2uri { str=article.name; }}.html";
        }) articles;
    articleToShortHtml = article: import ./articledesc.nix.html {inherit article;};
    ############################################################
    articleHtml = pkgs.lib.foldl (acc: article: acc + articleToShortHtml article) '''' articlesWithExtras;
in
pkgs.writeText "index.html" (import ./template.nix.html {inherit articleHtml; socialHtml = "social";})
#(builtins.head articles).shortContent