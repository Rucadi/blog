{utils, images}:
let double'' = "''";
dollar = "$";

website_image = (utils.file2base64 ./assets/website.jpg).htmlImage;

in
rec {
    name = "HTMX+nix as backend";
    category = "nix";
    date = "2024-04-20";
    authors = ["ruben"];
    content = ''
In the post [what is nix](/what-is-nix.html) we explained a little bit of the key concepts of the nix language.

But what if we try to push the boundaries of what we can do with nix? What if we use nix as a backend for a web application?
Ones may say that I'm crazy, but I'm not as crazy as the ones that suggested to use js as a backend language :)


For this demonstration, we will only use nix in pure evaluation mode and with sandbox.
This means that we have all the restrictions and limitations of the nix language applied.

So, let's start with the basics. We need the classic HTTP web server that will serve our application.
Just some small problems.

- Nix language is not designed to be a web server.
- Using internet inside Nix requires knowing the result in avance.
- We cannot have a persistent state in nix.
- We cannot have a dispatcher loop in nix.

Is all hope lost? Is it impossible to use nix as a backend?

The answer seems to be yes. Nix is not designed to be a backend, in the same way you can't write a cli tool using nix language.


# Glue Code to the rescue


Not all hope is lost! Let's at least try to use as much as nix as possible in our backend :) Sometimes, we have to admit defeat and just
go with the flow and use the right tool for the job. but if you continue reading, I promise you that I'll show you that sometimes, even 
**nix** as the backend **is the right tool for the job**.

So let's change the strategy and we will use any webserver (in this case, python flask!) to forward the requests to nix.

```{=html}
<pre><code class="language-python">
# Define a route that captures all paths
@app.route('/', defaults={'path': ''\},  methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'])
@app.route('/<path:path>',  methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'])
def catch_all(path):
    return nix_eval(request.args.to_dict(), request.method, path, 'process')
</code></pre>
```

This simple code will catch all methods, and we will process the following arguments from the request:

- path 
- method
- query

and forward them to nix evaluator (**nix eval**).

To do that, we can use python *subprocess* module to spawn the nix evaluator and pass the arguments to it.

```{=html}
<pre><code class="language-python">
def nix_eval(query, request_type, path, result_type):
    if len(path)>0 and path[0] == "/": path = path[1:]
    return subprocess.check_output(['nix', 'eval', '--raw',
        '--argstr', 'query_json', json.dumps(query), 
        '--argstr', 'request_type', request_type, 
        '--argstr', 'path', path, '-f', 'default.nix', 
        result_type], text=True)
</code></pre>
```

With this, we are spawning the command **nix eval** wih the arguments we need to process the request, and we expect to get back the HTML content of the performed request.
- error handling ommited for simplicity -

Now, we will be executing the nix evaluator in the expression default.nix, should we begin working on the nix part?

# Accepting parameters in nix
I'll assume that you are familiar with the nix language, so I'll skip the basics and go directly to the point.
We receive 3 parameters from the python code as **string**, so we define a function that receives three parameters.

```{=html}
<pre><code class="language-c++">
{ 
    request_type, 
    queryJson,
    path    
}:
${double''}parsing code for the path/request type here${double''}
</code></pre>
```

Then we can pass the query to a nix attribute set thanks to the **builtins.fromJSON** function.

```{=html}
<pre><code class="language-c++">
{request_type, queryJson, path }:
let 
    query = builtins.fromJSON queryJson;
in
${double''}parsing code for the path/request type here${double''}
</code></pre>
```

Then, we can define one *endpoint*, which will be the collection of all the possible paths that we can access in our application.

```{=html}
<pre><code class="language-c++">
{request_type, queryJson, path }:
let 
    query = builtins.fromJSON queryJson;
    main_endpoint = import ./root {inherit query;};
in
${double''}parsing code for the path/request type here${double''}
</code></pre>
```

# Endpoints and path selection

Now that we explained how to parse the parameters received from the python code, we need to define the endpoints that we will use in our application.

To do that, we will create a new file called default.nix inside a folder called root, this file will contain the endpoints that we will use in our application.

This, will receive as a parameter the query, so we can use it to modify the response of thee endpoint, and we will return an attribute set with the different endpoints and type of request.


```{=html}
<pre><code class="language-c++">
{query}:
{
    GET = "You are accessing / with a GET request";
    POST = "You are accessing / with a POST request";
    
    test.GET = "You are accessing /test with a GET request";
    test.my.hello.GET = "You are accessing /test/my/hello with a GET request";
}
</code></pre>
```

Once we implement the path-selection logic in nix, this endpoints file for this request:
`curl -X GET localhost:5000/test/my/hello` would return `"You are accessing /test/my/hello with a GET request"`

Easy right?


# Path selection for the endpoints

Now we return to the entrypoint of our nix expression, we received the 3 parameters `{request_type, queryJson, path}` and from that we 
have to access the correct endpoint defined in root/default.nix

To select the endpoint, we use the path, and since the path is string, 
we need to manipulate it to pinpoint the exact endpoint.

Unfortunately, nix does not have a built-in function to split a string, 
but nixpkgs does! We can either import nixpkgs or copy the function to our code.

In nix as a functional language, the way to do it is:

- Split the string into a list of strings
- Pick the beginning of the attribute set (can be seen as a tree)
- Access the attribute set recursively until we reach the correct endpoint.

The following code tries to do exactly that:
```{=html}
<pre><code class="language-c++">
adquireNixObjectByPath = endpoint: pathToSearch: 
                        if pathToSearch == "" then endpoint 
                        else builtins.foldl' (a: b: a."${dollar}{b}") endpoint (lib.splitString "/" pathToSearch);
</code></pre>
```

Let's break down this:

first we get a list of the path passed, for exmaple, test/my/hello will be transformed to ["test" "my" "hello"] using the splitString function.

```{=html}
<pre><code class="language-c++">lib.splitString "/" pathToSearch</code></pre>
```

Then we use the [foldl'](https://nixos.org/manual/nix/stable/language/builtins.html#builtins-foldl') function to recursively access the attribute set until we reach the correct endpoint.

```{=html}
<pre><code class="language-c++">builtins.foldl' (a: b: a."${dollar}{b}") endpoint (lib.splitString "/" pathToSearch);</code></pre>
```

The if statement is just to handle the case when the path is empty, and endpoint: pathToSearch: are the arguments passed to the function. adquireNixObjectByPath.


All together the code can look something like:


```{=html}
<pre><code class="language-c++">
{ request_type, queryJson, path }:
let
query = builtins.fromJSON queryJson; 
endpoints = import ./root {inherit query;};
lib = (import &ltnipkgs&gt{}).lib;

adquireNixObjectByPath = endpoint: pathToSearch: 
                        if pathToSearch == "" then endpoint 
                        else builtins.foldl' (a: b: a."${dollar}{b}") endpoint (lib.splitString "/" pathToSearch);

in 
{
    process = (adquireNixObjectByPath endpoints path).${dollar}{request_type};
}
</code></pre>
```


Notice now that we are returning the correct endpoint based on the path requested and the request type.
If we access /test/my/hello with a GET request, we will get "You are accessing /test/my/hello with a GET request".
If the endpoint doesn't define the method is accessed or doesn't exist, we will get an evaluation error from nix.

With this, we are ready to test our first nix backend application!
Let's try return different values depending on the path and the request type.

${images.htmx_nix_as_bacend_1_example_1.htmlImage}

All together, doing this requieres no more than 50 lines of code :) Not bad at all!

With this, now, we could return HTML code already, and have a different static page depending on the path, not that this 
is really useful, but it's a good start.


# Making it more dynamic

As nix mentions in their main webpage, nix focus is to achieve reproducibility and determinism in the evaluations, this does not mean that the 
inputs to the evaluation cannot change, but that for a given input, nix will "always" produce the same output.

While we usually cannot have a source of impurity in nix, some of the builtins functions are impure and allowed to be used in non-impure scenarios.
This is the case for: `builtins.fetchurl url` [documentation](https://nixos.org/manual/nix/unstable/language/builtins#builtins-fetchurl).

Usually, if we want to access the internet from nix, 
we need to know the hash of the result in advance. This is because nix doesn't can't trust that it receives the same object when performing
the same request to the same url. This is a security and error-prevention measure, that ensures the reproducibility of the evaluations.

However, the [builtins.fetchurl function](https://nixos.org/manual/nix/stable/language/builtins#builtins-fetchurl) is special. 
It will download the file from the internet and store it in the nix store, finally, it will return the path to the file. No hash is needed.

Let's try it!

First of all we will find a simple API to talk to, for example, [randomnumberapi](https://www.randomnumberapi.com), we can call this endpoint and we will get a random number inside an array of 1 element!

```
[nixos@nixos:~/demo/example2]$ curl https://www.randomnumberapi.com/api/v1.0/random
[63]
```

How could we read this number from nix?

The result of builtins.fetchurl is a path to the file, so we can use the builtins.readFile function to read the content of the file.

```{=html}
<pre><code class="language-c++">
randomNumber = builtins.readFile (builtins.fetchurl http://www.randomnumberapi.com/api/v1.0/random);
</code></pre>
```

this snippet will download the file and store the content in the variable randomNumber. 
From here, we can pass it to nix using the [`builtins.toJSON`](https://nixos.org/manual/nix/stable/language/builtins#builtins-toJSON) function that will convert from a json string to nix.

```{=html}
<pre><code class="language-c++">
randomNumberList = builtins.fromJSON randomNumber;
</code></pre>
```
Finally, we can access the number using the list index with [`builtins.elemAt`](https://nixos.org/manual/nix/stable/language/builtins#builtins-elemAt) and pass it to string

```{=html}
randomNumberStr = toString (builtins.elemAt randomNumberList 0);
```

Let's try return this number and see what happens!
Our endpoints look like this:

```{=html}
<pre><code class="language-c++">
{query}:
let
    randomNumber =  builtins.readFile (builtins.fetchurl http://www.randomnumberapi.com/api/v1.0/random);
    randomNumberList = builtins.fromJSON randomNumber;
    randomNumberStr = toString (builtins.elemAt randomNumberList 0);
in
{
    random.GET = randomNumberStr;
}
</code></pre>
```

And now, if we access /random with a GET request, we will get a random number!

```
[nixos@nixos:~/demo/example2]$ curl -X GET localhost:5000/random
23
````

And if we execute it again and again...

```
[nixos@nixos:~/demo/example2]$ curl -X GET localhost:5000/random
23
````

Wait? Why is it always returning 23?

# The nix Store and sources of impurity

As Nix is meant for reproducibility, unless we explicitly remove the file from the nix store, the same GET request to a service will always return the same cached result. 
This means that we cannot call other services or APIs from nix, 
as we will only get the same result over and over again.

While this is a limitation, do you really think that not being allowed to perform two times the same request can stop us? 
We only need to be a little bit more clever!

Nix commands have a really useful flag that can be used to our advantage, [--eval-store store-url  and --no-require-sigs](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-eval.html#common-evaluation-options)
These flags will allow us to perform the evaluation in a different store, which means that we can safely perform a request and remove the result later!

Let's try it!

We will modify our nix_eval code to include the flag --eval-store and we will pass a temporary folder to it, which 
will be deleted after the evaluation is done.

```{=html}
<pre><code class="language-python">
def nix_eval(query, request_type, path, request_switch="process"):
    print(query, request_type, path, request_switch)
    if len(path)>0 and path[0] == "/": path = path[1:]
    with tempfile.TemporaryDirectory() as tmpdirname:
        try:
            output = subprocess.check_output(['nix', 'eval', '--raw',
            '--eval-store', tmpdirname, '--no-require-sigs',
            '--argstr', 'queryJson', json.dumps(query), 
            '--argstr', 'request_type', request_type, 
            '--argstr', 'path', path, '-f', 'default.nix', 
            request_switch], text=True, stderr=subprocess.PIPE)
        except subprocess.CalledProcessError as e:
            print(e.output)
            print(e.stderr)

        print(f"Contents of {tmpdirname}")
        print(subprocess.check_output(['ls', '-l', tmpdirname], text=True))
    return output
</code></pre>
```

Now, let's try it again...


```
[nixos@nixos:~/demo/example2]$ curl -X GET localhost:5000/random
71
[nixos@nixos:~/demo/example2]$ curl -X GET localhost:5000/random
37
[nixos@nixos:~/demo/example2]$ curl -X GET localhost:5000/random
92
```

Absolute perfection. We are now able to call external services and APIs from nix, and we can get different results every time we call it, with this we created the 
first step into outside-world impurity when working with "pure" nix.

While this seems like a really obvious thing, being able to call external services, for nix is not that obvious, and allowing GET requests opens a whole new world of possibilities.

- Nix has builtin json-to-nix and nix-to-json functions, so we can easily parse and create json objects.
- Json objects are suitable to API requests, so we can easily create a request and parse the response.
- We can now conditionally from a request execute different code paths.
- We can now implement an http api in any other language in order to insert/delete/update/select data from a database.

So we unlocked a lot of possibilities for using nix as a backend, with the only limitation being only using one exact same request per evaluation.


As a bonus, the use of a temporary-folder for the nix store, makes it so each request is isolated from the others and all generated files are deleted after the evaluation is done.


# Practical example, "godbolt" in HTMX+nix

Now it comes what I promised you, a real example of using nix as a backend, where using nix is the right tool for the job.

We all know [godbolt](https://godbolt.org/), a website where you can write code and see the assembly code generated by the compiler. 
Many developers don't really use the website in order to take a look at the assembly code, but to share code snippets with others or just to test some code.

In this case, we will write a full backend in nix that will:

- Have a website where you can write code in a textarea
- Have a button to run the code
- Have a div where the assembly code will be displayed

We will use HTMX to make the request with the code to the backend, and return the result into a div.

Doing this in HTML, is no different than using any other html template library, take a look at this code:

```
${builtins.readFile ./assets/monaco_editor_cpp.nix}
```

Here, we just do the same that in the previous examples, but we will return the full website with the code editor.
Between the let..in, we bind some data to variables, that we can then use on the returned string (As Python's f"" strings or any string templating in any language)

After that, we just use string substitution to return the full html code, nothing really fancy here.

If we take a look at the button called "runcode", we can see what happens when we click it:

- We get the code from the editor
- We perform a GET request to the backend with a json object containing the code to the endpoint /compile
- We swap the innerHTML of the div "output" with the result of the request


# Compiling code and returning the result from NIX.

Nix has a really powerful feature, if you already use nix, you for sure know about nixpkgs, which is a collection of programs that have been packaged for nix.
This means that we can use any program that is in nixpkgs in our nix expressions, and we can build new derivations with them as inputs.

In this case, we will create a derivation that will compile the code, run it and return the result as its output. 
Then, we will use IFD [Import from derivation](https://fzakaria.com/2020/10/21/nix-parallelism-import-from-derivation.html), to get the output of the built derivation and return it as the result of the evaluation.


You may think that is inherintly unsafe to run code from the internet, but we are using nix, with pure evaluation mode and [sandbox enabled](https://nixos.wiki/wiki/Nix_package_manager#Sandboxing)
This means that the code will be run in a sandbox, and it will not be able to access the internet nor any other file in the system.
Also, since we are using a temporary folder, any output generated will be removed after the evaluation is done,
so we are limiting any possible damage to the system.

In the following example, we are writing the compile.GET endpoint, that will receive the code, compile it and return the result.
Notice that we use nixpkgs extensively, and also take some steps to ensure that we don't return too much data.
```
${builtins.readFile ./assets/compile.get.nix}
```

Going into details, here's how it works: we simply write the code into a file called main.cpp, 
specify the compile and run commands, and ensure with timeout that the code won't run for more than 10 seconds.

Then, we grab the output of the command along with any warnings or errors the compiler might throw our way. And voila, we're done!


From this, we are all done, 150 lines of code and we have a full backend that will compile and run code from the user,
and return the result to the user in a safe way.


Ready to give it a test? Just fire up your terminal and run this command:

```
docker run -it --rm -p 5555:5555 rucadi/blog:nix_as_web_backend
```

${website_image}

Could the next step be to do a todo app?


# Conclusions

Writing this post was a blast, and I hope you had as much fun reading it as I did creating it! Thanks a bunch for checking it out! 🫡

Nix is seriously powerful and can surprise you with its versatility. While I started this post as a bit of a joke, 
it turned into a cool proof of concept that could actually be pretty handy in real-world situations.

The complexity required to reach this solution was not that high,
and I feel like writing this in any other language could have been more complex and error-prone.

Plus, the cool thing is how seamlessly you can integrate different software stacks with Nix. 
In this case, we mixed in GCC, timeout, and more, all from within the Nix code. Pretty neat, huh?

I'm not exactly pushing for using Nix exclusively for building the entire backend, but I do think it's pretty great for static websites 
(like this blog, which I whipped up using Nix!). 
However, there's definitely room for improvement. 

If Nix had better error handling and smoother ways to handle storage and network requests, it could really step up its game as a serious option.
'';
}