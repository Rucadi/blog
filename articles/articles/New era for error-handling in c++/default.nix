{utils, images}:
let double'' = "''";
dollar = "$";

website_image = (utils.file2base64 ./assets/website.jpg).htmlImage;
#In the post [what is nix](/what-is-nix.html) we explained a little bit of the key concepts of the nix language.

in
rec {
    name = "New era for error-handling in c++";
    category = "C++";
    date = "2024-10-05";
    authors = ["ruben"];
    content = ''

In c++ there are multiple ways to handle errors, however, it seems like the language is not very friendly when it comes to error handling, and it is not very easy to write code that is both readable and maintainable.
It is not uncommon to see code use multiple strategies at once, which can make the code harder to read and maintain.

In this article, I'll briefly explain the most common ways to handle errors in c++, and I'll show you a new way to handle errors that is inspired by the Rust programming language.

## Error handling in c++

One of the best ways to know which types of error handling are popular in c++, is to just take a look at the most old project made in c++, this is its own standard library.
Looking at this is like looking at the history of c++ itself, and it is a good way to understand how the language has evolved over time.

The c++ standard library in fact uses different strategies for this, 
for example,
functions like [std::vector::at()](https://en.cppreference.com/w/cpp/container/vector/at) and std::map::at() throw an exception when the index is out of bounds,
while functions like std::find() return an iterator to the element if it is found, or the end iterator if it is not found.
std::filesystem::remove() returns a boolean value to indicate if the file was removed successfully or not.
Some legacy C functions like std::log() return an error code, and the error is stored in a global variable (errno)
And since c++20, we have std::optional/std::expected which can be used to return a value or an error.



In my last blog-post, I talked about how we could use std::variant to create a Rust-like enum in c++, which can be a benefit for readibility and maintainability of the code, 
and as a way to handle enum-associated data in a more elegant way. 

However, in rust, match operator is often used for error handling, functions in rust must return a Result type, which can be either Ok or Err, and the match operator is used to handle the error.

Rust have the operator `?` which is used to propagate errors, and it is a very powerful feature, which makes the code more readable and maintainable.


Error handling in c++:

Exceptions:

'';
}