{utils, images}:
rec {
    name = "What is NIX";
    category = "nix";
    date = "2026-07-01";
    authors = ["ruben"];
    content = ''
    It is said that any language can used to write a web server backend, there is even people that dared to do it in javascript.
    However, is it possible to write a web server backend in [nix](https://nixos.org/)?

    # What is Nix
    Nix is a functional language designed around *derivations*, which are instructions on how create files from other files.
    These instructions instead of only being pieces of nix code, can also be shell scripts or any other kind of executable.
    
    For ensuring reproducibility, these derivations are built in a sandboxed environment, where only the inputs of the derivation are available,
    and any other dependency must be explicitly declared.

    There is a strong emphasis on immutability, which means that once a derivation is built, the result is stored in a *store* and it cannot be modified, and 
    futures builds of the same derivation should yield the same result.
    
    # Uses of Nix
    Nix is primarily used as a package manager (nixpkgs), where it is used to build packages from source code, and to manage dependencies between packages.
    
    From this package manager derives NixOs, a linux distribution where the whole system is described in nix code, and packages are taken from nixpkgs.
 
    # Nix language
    Altough nix is built around derivations, we can use it as a templating or configuration language.
    Code is usually called "expressions", and expressions can also evaluate into attribute sets (like a dictionary in python), lists, strings, numbers, functions.

    <pre><code class="language-javascript">
        "hello world" # expression that evaluates to a string
        { hello = "world"; } # expression that evaluates to an attribute set
        [ 1 2 "3" 4 ] # expression that evaluates to a list
        42 # expression that evaluates to a number
        hi = x: x + " world" # expression that evaluates to a function 
    </code></pre>

'';
}