{
    writeTextDir,
    writeText,
    buildEnv,
    callPackage,
    htmlGenerator,
    images,
    utils,
    lib
}:
let 
    importedArticlesList = map (x : (callPackage (./. +"/articles/${x}") {inherit utils images;})) (builtins.attrNames (builtins.readDir ./articles));
    sortedArticles = lib.lists.sort (a: b: a.date > b.date ) importedArticlesList;
   
    articles = map (article: article // rec {
        uri = "${utils.string2uri article.name}.html";
        contentHtml = utils.md2html article.content;
        shortContentHtml = utils.fixedString {str = contentHtml; len = 300;};
        file = writeTextDir "site/${uri}" (htmlGenerator ''
        <article class="single">
        <header>
            <h1 id="${utils.string2uri article.name}">${article.name}</h1>
            <p>
            Posted on ${article.date} in category ${article.category}
            </p>
        </header>
        <div>
        ${contentHtml};
        </div>
        </article>
        
        '');
        }) sortedArticles;
in
map (article: article // {
    shortArticle = import ./shortArticle.nix.html {inherit article;};
}) articles