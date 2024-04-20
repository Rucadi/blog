{pandoc, runCommand}:
{markdown}:
builtins.readFile (runCommand "md2html" {} ''${pandoc}/bin/pandoc --wrap=none -f markdown-markdown_in_html_blocks+raw_html  ${builtins.toFile "md" markdown} > $out'')