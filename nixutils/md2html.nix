{pandoc, runCommand}:
{markdown}:
builtins.readFile (runCommand "md2html" {} ''${pandoc}/bin/pandoc -f markdown  ${builtins.toFile "md" markdown} > $out'')