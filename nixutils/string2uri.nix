{lib, runCommand, python311Packages}:
{str}:
builtins.readFile (runCommand "slug" {} ''echo "${str}" | ${python311Packages.python-slugify}/bin/slugify --stdin | tr -d '\n' > $out'')