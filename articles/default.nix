{
    writeTextDir,
    buildEnv,
    callPackage,
    utils,
    lib
}:
let 
    articlesList = (builtins.attrNames (builtins.readDir ./articles));
in
lib.lists.sort (a: b: a.date > b.date ) (map (x : (callPackage (./. +"/articles/${x}") {inherit utils;})) articlesList)
