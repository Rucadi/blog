{runCommand, coreutils-full}:
{uri}:
let 
    base64str = builtins.readFile (runCommand "base64" {} "${coreutils-full}/bin/base64 -w 0 ${uri} > $out") ;
in
{
    base64 = base64str;
    htmlImage = ''<img src="data:image/png;base64,${base64str}"/>'';
    htmlImageWithStyle = style: ''<img src="data:image/png;base64,${base64str}" style="${style}"/>'';
}