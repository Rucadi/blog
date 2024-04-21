{utils, images}:
let double'' = "''";
dollar = "$";

website_image = (utils.file2base64 ./assets/website.jpg).htmlImage;
#In the post [what is nix](/what-is-nix.html) we explained a little bit of the key concepts of the nix language.

in
rec {
    name = "Make your bashscripting sane";
    category = "bash";
    date = "2024-04-21";
    authors = ["ruben"];
    content = ''

One of the most common tasks for a developer is to write bash scripts.
Bash scripts are a great way to automate tasks, but they can quickly become a nightmare to maintain.

In my experience, the worst-offending bash scripts are the ones that gain a complexity over a dependency tree of other bash scripts that may 
set or may not set some magic environment variables that are required for the script to work but nobody knows where they come from.

Sanitizing these environment variables is a good way to make your bash scripts more maintainable, and to make them more predictable.

One way to do this is to create some script that sanitizes the environment variables before running the main script.

For example, we could write something like this: (we will call it **sbash** for example)

```bash
# Store the environment variables
envars=()
envars+=("PATH")
envars+=("SHELL")

if [ $# != 1 ]; then
    for ((i=1; i<=$#; i++)); do
        envars+=("$1")
        shift
    done
fi


# Save the current environment variables
saved_envars=()
for envar in "${dollar}{envars[@]}"; do
    if [ -z "${dollar}{!envar}" ]; then
        echo "Error: Environment variable $envar is not set"
        exit 1
    fi
    saved_envars+=("$envar=${dollar}{!envar}")
done

# Unset all environment variables
unset $(env | cut -d= -f1)

# Set the saved environment variables
for saved_envar in "${dollar}{saved_envars[@]}"; do
    export "$saved_envar"
done
# Execute the command
exec $SHELL "$@"
```

Which could allow any script to implement the shebang:

```bash
!#/usr/bin/env -S sbash ENV1 ENV2 ENV3 ENV4
```
In which the script will remove all the environment variables and set only ENV1..4 and PATH, which are the ones we defined that the script needed to work.

This means that now, with this simple change, we are sure of the status of the envs when we execute the script,
and we also know that all the scripts that we call from here, will only have the env vars that we defined.

This simple change alone already create some kind of isolation between the scripts, and makes the scripts more predictable and easier to maintain.


However, this is just the tip of the iceberg, and there are many more things that we can do to make our bash scripts more maintainable and predictable.


# NixSH

One way to make our bash scripts more predictable is to use the nix language to define the environment that the script will run in.
[I created NixSH](https://github.com/Rucadi/nixsh) in order to make it easier to write maintainable and reproducible bash scripts.


The idea behind NixSH is the same as before, having a clear definition of the environment variables that the script will run in,
but instead of using a bash script to do this, we use the nix language.

For example, we could define a nix file like this:

```
#!/usr/bin/env nixsh
{PATH, TERM}:
${double''}
echo "Hello World"
${double''}
```

or 

```
#!/usr/bin/env nixsh
{PATH, TERM?"unknown"}:
${double''}
echo "Hello World"
${double''}
```

Which will force the script to have PATH and TERM defined, and if TERM is not defined, it will default

or like this

```nix
#!/usr/bin/env nixsh
{PATH, TERM}:
let 
  TERM="unknown"
in
${double''}
echo "${dollar}{TERM}"
${double''}
```

This script will force PATH and TERM to be defined, and will forcefully set TERM to "unknown" before executing the echo.


This way, we achieve something similar to the bash script, but that's not all, we also gain the NIX superpowers, which allows us to use
nix syntax to import other nix scripts, or use all the functionality of nix and nixpkgs.

# Example of parameter passing using NixSh

We can have one script called one.nixsh


```bash
#!/usr/bin/env nixsh
{PATH, TERM}:
${double''}
  # This includes the two.sh script into the current script as if it was directly written here.
  ${dollar}{import ./two.nixsh {inherit PATH TERM; PARAM="Hello From Another Script!";}}
  
  # This will call nixsh with the env var PARAM, which will be passed to the script.
  # If param is not set, two.nixsh will use the default value or in this case, fail.
  PARAM="Hello from dynamic call to nixsh!" ${dollar}{./two.nixsh}


  T=$(${dollar}{import ./two.nixsh {inherit PATH TERM; PARAM="Hello From Another Script!";}})
  echo "Obviously I can also get the result: "$T""

${double''}
```

and a second script called two.nixsh

```bash
#!/usr/bin/env nixsh
{PATH, TERM, PARAM}: 
${double''}
  echo "I like to receive params :) Received: ${dollar}{PARAM}"
${double''}
```


In the first example, we can see how we are calling the second script importing it from nix itself, which will cause a call
to the second script.

The second example shows how to call it "dynamicall", which means that we will only notice if we have an error when the first script 
arrives at this position of the code.

In the third example we can see how we can also get the result of the second script, no problems here :)


# Other interpreters

One nice thing of NixSH is that it's not limited to bash, we can also use other interpreters, like python, ruby, perl, etc.

For example, we could have a python script like this:

```python3
#!/usr/bin/env -S nixsh python3
{}:
let 
  Hello = "Hello World!";
in
${double''}
  import os
  print(os.environ)
  print("${dollar}{Hello}")
${double''}
```

Which also allows you to do the same thing, but with python.


# Conclusion

I worked on NixSh because I was tired of writing bash scripts that were hard to maintain, and I wanted to have a way to make them more predictable and easier to maintain.
However, I don't endorse its per se, I would prefer that you use it as a source of inspiration to create your own tools that make your life easier, and,
if possible, avoiding any global state in your scripts or avoiding bash scripts at all.

'';


}