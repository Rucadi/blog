{utils, images}:
let double'' = "''";
dollar = "$";
in
rec {
    name = "HTMX+nix as backend";
    category = "nix";
    date = "2026-07-01";
    authors = ["ruben"];
    content = ''
In the post [what is nix](/what-is-nix) we explained a little bit of the key concepts of the nix language.

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
${double''}html code here${double''}
</code></pre>
```

Then we can pass the query to a nix attribute set thanks to the **builtins.fromJSON** function.

```{=html}
<pre><code class="language-c++">
{request_type, queryJson, path }:
let 
    query = builtins.fromJSON queryJson;
in
${double''}html code here${double''}
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
${double''}html code here${double''}
</code></pre>
```

# endpoint root/default.nix

We will define an endpoint as an attribute set of expressions that will be evaluated when the endpoint at the path is requested.

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

In this example, curl -X GET localhost:5000/test/my/hello will return "You are accessing /test/my/hello with a GET request".
Easy right?


# Returning the correct endpoint

Now, we need to return the correct endpoint based on the path requested.
As we mentioned, path is passed as a string, so we need to do some kind of string manipulation to get the correct endpoint.

Putting as an example the path "test/my/hello", we need to split the string by "/" and then recursively access the attribute set until we reach the correct endpoint.

Unfortunately, nix does not have a built-in function to split a string, but nixpkgs does! We can either import nixpkgs or copy the function to our code.


Once we have our splitstring function, we can create a function that we pass the endpoint example and the path "test/my/hello" and it will return the correct endpoint

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

Then we use the foldl' function to recursively access the attribute set until we reach the correct endpoint.

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

As nix mentions in their main webpage, nix tires to get reproducibility and determinism in the evaluations, this does not mean that the 
inputs to the evaluation cannot change, but that for a given input, nix will "always" produce the same output.

To fix this, we need to introduce a little bit of *impurity*.

While we usually cannot have a source of impurity in nix, some of the builtins functions are impure and allowed to be used in non-impure scenarios.
This is the case for: `builtins.fetchurl url` [documentation](https://nixos.org/manual/nix/unstable/language/builtins#builtins-fetchurl).
Usually, if we want to access the internet from nix, we need to know the hash of the result in advance, however, the builtin fetchurl function is 
special. It will download the file from the internet and store it in the nix store, and then return the path to the file.

Let's try it!

First of all we will find a simple API to talk to, for example, randomnumberapi, we can call this endpoint and we will get a random number inside an array of 1 element!

```
[nixos@nixos:~/demo/example2]$ curl https://www.randomnumberapi.com/api/v1.0/random
[63]
```

How could we read this number from nix?

```{=html}
<pre><code class="language-c++">
randomNumber = builtins.readFile (builtins.fetchurl http://www.randomnumberapi.com/api/v1.0/random);
</code></pre>
```

this snipper will download the file and store the content in the variable randomNumber. 
From here, we can pass it to nix using the `builtins.toJSON` function that will convert from a json string to nix.

```{=html}
<pre><code class="language-c++">
randomNumberList = builtins.fromJSON randomNumber;
</code></pre>
```
Finally, we can access the number using the list index with `builtins.elemAt` and pass it to string

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

Nix was really clever with the last request, once it downloads the file, it stores it in the nix store, and then it will always return the same file.
This means that we cannot call other services or APIs from nix, as we will only get the same result over and over again, and only the first time we will actually perform the request.

While this is a limitation, do you really think that not being allowed to perform two times the same request can stop us? 
We only need to be a little bit more clever!

Nix commands have a really useful flag that can be used to our advantage, and in fact, it is even preferable that we make use of it!
It is [--eval-store store-url  and --no-require-sigs](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-eval.html#common-evaluation-options)
What would happen if we use this flag and we pass a different store-url every time we evaluate the expression?

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

Absolute perfection. We are now able to call external services and APIs from nix, and we can get different results every time we call it.


'';
}