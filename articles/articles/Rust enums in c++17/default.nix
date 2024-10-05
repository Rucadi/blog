{utils, images}:
let double'' = "''";
dollar = "$";

website_image = (utils.file2base64 ./assets/website.jpg).htmlImage;
#In the post [what is nix](/what-is-nix.html) we explained a little bit of the key concepts of the nix language.

in
rec {
    name = "Rust enums in c++17";
    category = "C++";
    date = "2024-05-10";
    authors = ["ruben"];
    content = ''

# Comparing Rust and C++: Enum Patterns and Variant Types

While on my journey to learning Rust, I was following the [Rust by Example](https://doc.rust-lang.org/stable/rust-by-example), and one standout feature was [Rust's enums](https://doc.rust-lang.org/stable/rust-by-example/custom_types/enum.html), which seemed more powerful compared to their C++ counterparts. 
However, I wasn't completely amazed. 

While Rust has the `match` keyword, which ensures all cases are handled, and in c++, using "switch" with enums has a lot of pitfalls, C++ has something quite similar in the form of `std::variant`, introduced in C++17.

In fact, many of the patterns I saw in Rust could be replicated in C++. This post isn't about memory safety, but rather about the language features people often praise in Rust.

While Rust is innovative, most of its constructs can be replicated in other languages. However, C++ has a lot of legacy baggage and multiple ways to achieve the same task, which can obscure simpler patterns.

Let's dive into a Rust enum example, as provided by the rust-by-example documentation, and see how we can replicate it in C++.

## Rust Enum Example

```rust
enum WebEvent {
    // An `enum` may either be `unit-like`,
    PageLoad,
    PageUnload,
    // like tuple structs,
    KeyPress(char),
    Paste(String),
    // or c-like structures.
    Click { x: i64, y: i64 },
}
```
In this enum, we can see three different constructs:

- Members without any data attached (PageLoad, PageUnload).
- Members with unnamed data (KeyPress(char), Paste(String)).
- Members with named data (Click { x: i64, y: i64 }).

Unfortunately, C++ does not offer such flexibility natively. The closest we can get is using a combination of struct or namespace to group these types together.

Here's how we can replicate the Rust enum in C++:

```cpp
struct WebEvent {
    struct PageLoad {};
    struct PageUnload {};
    struct KeyPress { char c; };
    struct Paste { std::string str; };
    struct Click { uint64_t x, y; };
};
```

While this is equivalent in structure, Rust offers a built-in mechanism for pattern matching and destructuring enums, allowing for more elegant handling of different types.

```rust
fn inspect(event: WebEvent) {
    match event {
        WebEvent::PageLoad => println!("Page loaded"),
        WebEvent::PageUnload => println!("Page unloaded"),
        WebEvent::KeyPress(c) => println!("Pressed '{}'.", c),
        WebEvent::Paste(s) => println!("Pasted \"{}\".", s),
        WebEvent::Click { x, y } => {
            println!("Clicked at x={}, y={}.", x, y);
        },
    }
}
```

In this example, we can see that we can decompose the variants of the enum in a very clean way, while also allowing us to get access to the data associated with each variant,
enforcing that all cases are handled.

This would be equivalent to having an enum in C++ and using a switch statement to handle each case, however, in c++ enums can't have associated data, so we would need to use a struct or class that holds the data and
an enum to differentiate between the different types.

However, we can achieve most of the same type-guarantees in C++.
For that, we need an aggregator type [std::variant](https://en.cppreference.com/w/cpp/utility/variant).

`std::variant` is a type-safe union that stores one of several types, the size of the variant usually is the size of the largest type it holds, plus some additional bytes for the index of the active type.

So at a logical level, these  would be equivalent:

```cpp
union union_type {
    union {
        int a;
        char b;
        double c;
    };
    uint8_t index;
};

std::variant<int, char, double> variant_type;
```

However, `std::variant` provides library support and some strong guarantees that unions don't have, so it's recommended to use `std::variant` instead of unions.


Now, returning to the rust example, we can replicate the same behavior in C++ using `std::variant`:
```cpp
struct WebEvent {
    struct PageLoad {};
    struct PageUnload {};
    struct KeyPress { char c; };
    struct Paste { std::string str; };
    struct Click { uint64_t x, y; };

    std::variant<PageLoad, PageUnload, KeyPress, Paste, Click> webEvent;
};
```

This is not as clean as Rust enum, since we need to define the variant types separately, but it's the closest we can get in C++ without preprocessor magic or code generation.


C++17 Introduced [std::visit](https://en.cppreference.com/w/cpp/utility/variant/visit) to interact with `std::variant`, which is similar to Rust's match keyword.

`std::visit` is a helper function that, given a variant and a "Visitor" (A callable type which must implement the operator() at least for all the methods of the variant), will call the operator() for the method that the variant holds,
this is great, because if we are missing one type of the variant, we get a compile-time error, which means that we must contemplate all the cases or the program will not compile.

This is a great improvement over the switch statement or a chain of if-else statements, which can be error-prone and hard to maintain, just imagine adding a new type to the variant, 
you would need to add a new case to the switch statement, 
and if you forget, the program will compile and run, but it will not handle the new type.


So in the end, we can understand a Visitor as a structure that overloads the operator() accepting as a parameter the different types of the variant, then `std::visit` will invoke the operator() for the type that the variant holds.
```cpp
auto inspect(const WebEvent& e) {
    struct {
        void operator()(WebEvent::PageLoad) const { std::cout << "PageLoad\n"; }
        void operator()(WebEvent::PageUnload) const { std::cout << "PageUnload\n"; }
        void operator()(WebEvent::KeyPress) const { std::cout << "KeyPress\n"; }
        void operator()(WebEvent::Paste) const { std::cout << "Paste\n"; }
        void operator()(const WebEvent::Click& click) const { 
            std::cout << "Clicked at x=" << click.x << ", y=" << click.y << "\n"; 
        }
    } visitor;

    return std::visit(visitor, e.webEvent);
}
```

In this example, we are defining an anonymous struct that overloads operator() for each possible type in the variant, this is the equivalent of the rust's version.



## Reducing Boilerplate with Variadic Templates

One of the downsides so far that we have seen in this approach is the boilerplate needed,
Using C++ variadic templates and inheritance, we can greately simplify this pattern, while keeping the type-safety guarantees, and adding more flexibility.

If we follow to the example's section of the [std::visit](https://en.cppreference.com/w/cpp/utility/variant/visit) documentation, we see the use of a variadic template to define the visitor:

```cpp
template<class... Ts>
struct overloaded : Ts... { using Ts::operator()...; };
```

```cpp

struct pageVisitor {
            void operator()(WebEvent::PageLoad) const { std::cout << "PageLoad\n"; };
            void operator()(WebEvent::PageUnload) const { std::cout << "PageUnload\n"; }
};

struct actionVisitor {
        void operator()(WebEvent::KeyPress) const { std::cout << "KeyPress\n"; }
        void operator()(const WebEvent::Click& click) const { std::cout << "click "<<click.x<<" "<<click.y<<"\n"; }
        void operator()(WebEvent::Paste) const { std::cout << "Paste\n"; }
};


auto inspect(WebEvent::webEvent const& e)
{
    return std::visit(overloaded<pageVisitor, actionVisitor>{}, e.webEvent);
}
```

With this approach, we can define the visitors in a more modular way, and "tie" them together using the overloaded struct.
However, there is an alternative way to define the overloaded struct:

```cpp
auto inspect(WebEvent::webEvent const& e)
{
    return std::visit(overloaded{pageVisitor{}, actionVisitor{}},  e);
}
```

For the untrained eye, this might look wrong, in fact, we are calling the constructor of the overloaded struct, without defining the types it holds nor the constructor,
however, this is thanks to  [C++17's class template argument deduction (CTAD)](https://en.cppreference.com/w/cpp/language/class_template_argument_deduction),
which allows the compiler to deduce the types of the template.

This works because when using variadic inheritance (in the overlodaded struct) the compiler is able to deduce the overloaded struct type from the constructor, 
and will generate a default constructor that accepts all the parameters passed to it, and forward the parameters to the base classes. Notice that we are also exposing the operator() of the base classes.

While this seems more difficult or less readable, combining this with the use of lambdas, we can greatly simplify the code:

```cpp

template<class... Ts>
struct overloaded : Ts... { using Ts::operator()...; };

auto inspect(const WebEvent& e) {
    return std::visit(overloaded{
        [](WebEvent::PageLoad) { std::cout << "PageLoad\n"; },
        [](WebEvent::PageUnload) { std::cout << "PageUnload\n"; },
        [](WebEvent::KeyPress) { std::cout << "KeyPress\n"; },
        [](WebEvent::Paste) { std::cout << "Paste\n"; },
        [](const WebEvent::Click& click) { 
            std::cout << "Clicked at x=" << click.x << ", y=" << click.y << "\n"; 
        }
    }, e.webEvent);
}
```

This looks much better!

A lambda is a type that implements the operator() method, so we can use it as a base class for our overloaded struct. This makes it possible to define this struct using lambdas.
A lambda, however, has also a thing called a closure, which is a way to capture variables from the outer scope, this is very useful when we need to use variables from the outer scope in the operator() method.

The use of lambdas also make the definition of default cases easier, since we can define a lambda that ignores the type, and we can use it as a default case.

Imagine that we only expect to receive "click" events, and we must ignore everyting else, then we could rewrite the inspect method as:

```cpp
auto inspect(const WebEvent& e) {
    return std::visit(overloaded{
        [](const auto&) { /* Ignore other events */ },
        [](const WebEvent::Click& click) { 
            std::cout << "Clicked at x=" << click.x << ", y=" << click.y << "\n"; 
        }
    }, e.webEvent);
}
```
With this, the compiler then will generate an operator() for all types inside the variant minus the already explicitly defined ones, this means that we can make use of auto to make default case.


## Creating a match Function for Cleaner Code

Now, writing "overloaded" all the time can be a little bit annoying, we could create a function that make it easier for us to remember and better match the rust counterpart.

We can create using c++ metaprogramming, a function called "match" with the following signature:

```cpp

template<class... Ts>
struct overloaded : Ts... { using Ts::operator()...; };

template<class T, class... Ts>
auto match(const T& event, Ts&&... args) {
    return std::visit(overloaded{std::forward<Ts>(args)...}, event);
}
```

The match function will take as a first parameter the `std::variant` and will perfectly-forward the event to the `std::visit` function, and will create the overloaded struct from the variadic arguments passed.

this means that we, in any place of the code, use the match function to handle the `std::variant`, and we can pass lambdas to handle the different types.

```cpp
match(e.webEvent,
     [](const WebEvent::Click& click) { 
         std::cout << "Clicked at x=" << click.x << ", y=" << click.y << "\n"; 
     },
     [](const auto&) { /* Ignore other events */ });
```

This approach provides a clean, type-safe way to interact with `std::variant` in C++.

## Conclusion

For me this is the best way to interact with variants in c++.

As we can see, using this methods, we are able to replicate the same functionality as in rust enums in a clean way, the only midly-annoying thing is to have to define the `std::variant` over already-existing structs instead of having a language construct that does that for you. 

Also, notice that we are always returning the value of `std::visit`. This is because, in fact, the operator() can return a value, and if we call the match function or the `std::visit` function, if all the operators return the same type, 
it will return the value, if not it will simply not compile, but if you want to return different types, nothing is stopping you from returning a new variant, right?

You can play with the final code in the [compiler explorer](https://blog.godbolt.org/z/xjaEM4oEz).

And here is the full code for the final example: (Compile with `g++ -std=c++20`), c++20 is required because of the improved CTAD rules, 
but you could use c++17 if you define the template deduction guides for the overloaded struct as shown in the cppreference examples.

```cpp
#include <iostream>
#include <variant>
#include <string>
#include <cstdint>

struct WebEvent
{
    struct PageLoad{};
    struct PageUnload{};
    struct KeyPress{char c;};
    struct Paste{std::string str;};
    struct Click{uint64_t x,y;};
    using webEvent = std::variant<PageLoad, PageUnload, KeyPress, Paste, Click>;
};

template<class... Ts>
struct overloaded : Ts... { using Ts::operator()...; };

template<class T, class... Ts>
auto match(const T& event, Ts&&... args) {
    return std::visit(overloaded{std::forward<Ts>(args)...}, event);
}

int main()
{
    WebEvent::webEvent event(WebEvent::Click{.x=32,.y=64});
    match(event,
        [](const WebEvent::Click& click) { 
            std::cout << "Clicked at x=" << click.x << ", y=" << click.y << "\n"; 
        },
        [](const auto&) { /* Ignore other events */ });   
    
     return 0;
}
```
'';
}