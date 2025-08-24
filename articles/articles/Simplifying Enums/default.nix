{utils, images}:
let double'' = "''";
dollar = "$";
in
rec {
    name = "Simplifying variant use";
    category = "C++";
    date = "2025-24-08";
    authors = ["ruben"];
    content = ''

This article assumes the reader is already familiar with std::variant and std::visit. If you are not, please refer to my other post: Rust enums in C++17,
In this post I will present a more expressive way of creating visitors for std::variant, which I believe makes the code cleaner and easier to read by using a small
header-only library that I created called vpp [check out on github! https://github.com/Rucadi/vpp](https://github.com/Rucadi/vpp)


# What the standard library gives us

The C++ standard library allows us to use std::variant together with std::visit. In this case, the visitor must be a functor with an operator() overload for each type contained in the variant.

This means that something like this is possible:

```cpp
struct WebEvent {
    struct PageLoad {};
    struct PageUnload {};
    struct KeyPress { char c; };
    struct Paste { std::string str; };
    struct Click { uint64_t x, y; };

    using Event = std::variant<PageLoad, PageUnload, KeyPress, Paste, Click>;
};


auto inspect(const WebEvent::Event& e) {
    struct {
        void operator()(WebEvent::PageLoad) const { std::cout << "PageLoad\n"; }
        void operator()(WebEvent::PageUnload) const { std::cout << "PageUnload\n"; }
        void operator()(WebEvent::KeyPress) const { std::cout << "KeyPress\n"; }
        void operator()(WebEvent::Paste) const { std::cout << "Paste\n"; }
        void operator()(const WebEvent::Click& click) const { 
            std::cout << "Clicked at x=" << click.x << ", y=" << click.y << "\n"; 
        }
    } visitor;

    return std::visit(visitor, e);
}
```

Which gets reduced to this when using overloaded pattern and lambdas (which also allow capturing the local context easily):

```cpp
auto inspect(const WebEvent::Event& e) {
    return std::visit(overloaded {
        [](WebEvent::PageLoad) { std::cout << "PageLoad\n"; },
        [](WebEvent::PageUnload) { std::cout << "PageUnload\n"; },
        [](WebEvent::KeyPress) { std::cout << "KeyPress\n"; },
        [](WebEvent::Paste) { std::cout << "Paste\n"; },
        [](const WebEvent::Click& click) { 
            std::cout << "Clicked at x=" << click.x << ", y=" << click.y << "\n"; 
        }
    }, e);
}
```


However, I still feel this to not be exactly what we want, we are using "support" functions for abstracting what it should be a function call.

I think that the intent of the overloaded pattern should be to create a callable object that can process the `variant` directly, without the need of an explicit std::visit.

# A more expressive visitor

The goal is to call the visitor directly as visitor(e) without explicitly invoking std::visit, and additionally be able to create the visitor in a less verbose way.

Let's go directly to the proposed pattern:

```cpp
int main()
{
    std::variant<int, double, std::string> v = 42;
    auto vis = vpp::visitor
             & [](int x) { return std::to_string(x); }
             & [](double d) { return std::to_string(d); }
             & [](const std::string& s) { return s; };

    std::cout << vis(v) << "\n"; // prints "42"
}

```

And a one-liner version of the same (slightly less readable):
```cpp
    std::variant<int, double, std::string> v = 42;
    std::cout << (vpp::visitor
             & [](int x) { return std::to_string(x); }
             & [](double d) { return std::to_string(d); }
             & [](const std::string& s) { return s; })(v) << "\n"; // prints "42"
```

In this case, the visitor is created using a series of & operators to chain lambda (or functions) together, then, the visitor can be called directly with the variant as argument.

For this, the first element of the chain must be a special object that overloads the & operator, which will return a new object with the functor stored inside, then, each subsequent & operator will add a new functor to the visitor.

Finally, the resultant callable object accepts any variant covered by the functors, which, in my opinions declares the intent more clearly.

This is also not limited to 1-variant visitors, this pattern works for N-variant visitors as well:

```cpp
    std::variant<int, std::string> a = 10;
    std::variant<int, std::string> b = 5;
        
    auto vis = vpp::visitor
            & [](int x, int y) -> std::string { return std::to_string(x + y); }
            & [](int x, const std::string& s) -> std::string { return std::to_string(x) + s; }
            & [](const std::string& s, int x) -> std::string { return std::to_string(x) + s; }
            & [](const std::string& s1, const std::string& s2) -> std::string { return s1 + s2; };

    std::cout << vis(a, b) << "\n";
```

The library that implements this pattern is called vpp (variant++), can be found in my github: [vpp](https://github.com/Rucadi/vpp)

And you can play with it in this godbolt link: [godbolt](https://cpp2.godbolt.org/z/7x3sf9KoW)

'';
}