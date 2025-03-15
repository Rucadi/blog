In c++ there are multiple ways to handle errors, however, it seems like the language is not very friendly when it comes to error handling, and it is not very easy to write code that is both readable and maintainable.
It is not uncommon to see code use multiple strategies at once, which can make the code harder to read and maintain.

In this article, I'll briefly explain the most common ways to handle errors in c++, and I'll show you a new way to handle errors that is inspired by the Rust programming language.

## Error handling in c++

One of the best ways to know which types of error handling are popular in c++, is to just take a look at the oldest project made in c++, its own standard library (std).
Looking at this is like looking at the history of c++ itself, and it is a good way to understand how the language has evolved over time.

The c++ standard library in fact uses different strategies for this,

- [std::vector::at()](https://en.cppreference.com/w/cpp/container/vector/at) throw a [std::out_of_range](https://en.cppreference.com/w/cpp/error/out_of_range) exception when the index is out of bounds,
- [std::find()](https://en.cppreference.com/w/cpp/algorithm/find) return an iterator to the element if it is found, or the end iterator if it is not found.
- [std::filesystem::remove()](https://en.cppreference.com/w/cpp/filesystem/remove) returns a boolean value to indicate if the file was removed successfully or not.
- [std::log()](https://en.cppreference.com/w/cpp/numeric/math/log)  have its own error is stored in a global variable (**errno**)


And since c++20, we have [std::optional](https://en.cppreference.com/w/cpp/utility/optional)/[std::expected](https://en.cppreference.com/w/cpp/utility/expected) which can be used to return a value or an error, which I couldn't find any place in which these are used inside the standard library api itslef.


Wew can see that there are 5 competing ways of handling errors, and some of them cohexist in the same period of c++ history.

Each one has their advantages and dissadvantages,
- **exceptions** provide a powerful mechanism of "short-circuit" propagating an error through multiple function calls without requiring explicit checks at every level, this provides cleaner code without repetitive error checking. If there are no exceptions occurring, the cost of them is negligible, but they have a cost so they should only be used in **exceptional** cases. They also require special runtime support, which may not be available in all targets (embedded devices mainly), can cause memory allocation to occur, in RTC they take an undetermined ammount of time, calling throwable functions from FFI is possible and compiles without even a warning, and they remove some optimization opportunities, so it's common to see [**noexcept**](https://en.cppreference.com/w/cpp/language/noexcept_spec) being used. 
- **special return values** require the programmer to specifically check for the "error" returned value, which is not enforced by the language itself and can lead to multiple errors, from calling functions with invalid arguments to dereferencing null pointers, all of which will happen at runtime, there is no short-circuit mechansim so it must be handled in-line in the code.
- **boolean return value** It is similar to special returns values but harder to missuse, however, it also need to be handled in-line in the code when it happens.
- **global variable** This is one of the worst offenders, just don't do it.
- **std::optional** and **std::expected**, are new introductions to the standard library which aim to "unify" the error handling to be more type-explicit, making it know exactly which type of error a function can return, which it still has the same problems as special return values or boolean return values, and you can still dereference an invalid pointer or easily invoke undefined behavior, but it is a big improvement over using that other two methods.


how errors are handled in inspiring newly popular language projects:

---

### Error handling in Zig

Zig leverages error unions and the `try` keyword to propagate errors automatically through nested function calls.t.

```zig
const std = @import("std");

// Performs division of a by b, returning an error if b is zero.
fn safe_divide(a: f64, b: f64) !f64 {
    if (b == 0) return error.DivideByZero;
    return a / b;
}

// Computes the reciprocal (1/value), returning an error if value is zero.
fn reciprocal(value: f64) !f64 {
    return safe_divide(1.0, value);
}

// Computes 1/(a/b), propagating errors from division or reciprocal operations.
fn compute_expression(a: f64, b: f64) !f64 {
    const division = try safe_divide(a, b);
    return try reciprocal(division);
}

pub fn main() !void {
    // Attempt to compute the expression; errors are short-circuited.
    const result = compute_expression(10, 0) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return;
    };
    std.debug.print("Result: {}\n", .{result});
}
```

*In this Zig example, if the division fails (for instance, dividing by zero), the error is propagated through both `compute_expression` and `reciprocal`, reaching `main` where it’s handled.*

---

### Error handling in Rust

Rust's `Result` type and the `?` operator make it easy to propagate errors through multiple function calls. In the following example, an extra function computes the reciprocal of a division result, and errors are automatically forwarded.

```rust
fn safe_divide(a: f64, b: f64) -> Result<f64, String> {
    if b == 0.0 {
        Err("Divide by zero".to_string())
    } else {
        Ok(a / b)
    }
}

// Computes the reciprocal of a given value.
fn reciprocal(value: f64) -> Result<f64, String> {
    safe_divide(1.0, value)
}

// Computes an expression by first dividing and then taking the reciprocal of the result.
fn compute_expression(a: f64, b: f64) -> Result<f64, String> {
    let division = safe_divide(a, b)?;
    reciprocal(division)
}

fn main() {
    // The error propagates automatically to this match block.
    match compute_expression(10.0, 0.0) {
        Ok(result) => println!("Result: {}", result),
        Err(e) => println!("Error: {}", e),
    }
}
```

*Here, Rust’s use of the `?` operator in `compute_expression` ensures that if any function in the chain returns an error, it immediately propagates, allowing for concise error handling in `main`.*

---

Both examples show how modern error handling in Zig and Rust leverages short-circuiting to cleanly propagate errors through multiple layers of function calls, reducing boilerplate and making your code more robust and easier to maintain, in a way, is similar to how c++ with exceptions would work:

```cpp
#include <iostream>
#include <stdexcept>

// Performs division of a by b, throwing an exception if b is zero.
double safe_divide(double a, double b) {
    if (b == 0.0) {
        throw std::runtime_error("Divide by zero");
    }
    return a / b;
}

// Computes the reciprocal (1/value) by dividing 1.0 by value.
double reciprocal(double value) {
    // Propagate any exception from safe_divide.
    return safe_divide(1.0, value);
}

// Computes 1/(a/b), propagating errors from division or reciprocal operations.
double compute_expression(double a, double b) {
    // The exception from safe_divide automatically propagates if b is zero.
    double division = safe_divide(a, b);
    return reciprocal(division);
}

int main() {
    try {
        // Attempt to compute the expression; exceptions are short-circuited.
        double result = compute_expression(10, 0);
        std::cout << "Result: " << result << std::endl;
    } catch (const std::exception& err) {
        std::cerr << "Error: " << err.what() << std::endl;
    }
    return 0;
}

```

# A new way to handle exceptions in c++

Mandatory xkcd



In my last blog-post, I talked about how we could use std::variant to create a Rust-like enum in c++, which can be a benefit for readibility and maintainability of the code, 
and as a way to handle enum-associated data in a more elegant way.

While newer standards has [std::optional](https://en.cppreference.com/w/cpp/utility/optional)/[std::expected](https://en.cppreference.com/w/cpp/utility/expected) , I think that that probably the best way to handle errors are with  [std::variant](https://en.cppreference.com/w/cpp/utility/variant)

std::variant is just a type-safe union, its size will be the largest element inside the "union", plus an index to specify which is the content.
it also has an utility library function called [std::visit](https://en.cppreference.com/w/cpp/utility/variant/visit2), which allows to execute a callable that accepts all possibilities of the union, and execute the correct one that the variant contains.

This means that, copying Rust's Result type, we could understand a Result<OK_VALUE, ERR_VALUE> as std::variant<OK_VALUE, ERR_VALUE>, which is similar to what std::expected offers, but will show std::variant superpowers later!

We will borrow the **match** function created in the last blogpost for the example:

```cpp


// Define a custom error type for divide-by-zero errors.
struct DivideByZero {};

// safe_divide returns a double on success or a DivideByZero error on failure.
Result<double, DivideByZero> safe_divide(double a, double b) {
    if (b == 0.0) {
        return DivideByZero{};
    }
    return a / b;
}

// reciprocal computes the reciprocal (1/value) using safe_divide.
Result<double, DivideByZero> reciprocal(double value) {
    return safe_divide(1.0, value);
}

// compute_expression computes 1/(a/b) by first dividing a by b and then taking the reciprocal.
// If any step fails, the error is propagated.
Result<double, DivideByZero> compute_expression(double a, double b) {
    auto divisionResult = safe_divide(a, b);
    return match(divisionResult,
        [](const DivideByZero&) -> Result<double, DivideByZero> {
            // Propagate the error.
            return DivideByZero{};
        },
        [](double value) -> Result<double, DivideByZero> {
            // Call reciprocal on the valid result.
            return reciprocal(value);
        }
    );
}


int main() {
    // Attempt to compute the expression.
    auto result = compute_expression(10, 0);
    
    // Use the match function to handle both success and error cases.
    match(result,
          [](DivideByZero) {
              std::cerr << "Error: Divide by zero" << std::endl;
          },
          [](double value) {
              std::cout << "Result: " << value << std::endl;
          });
    
    return 0;
}

```

We can see that the code is relativly similar to Rust's code, however, there are major pain points with this solution.

First, there is no compiler support for non-exception error handling, in Rust, the question mark operator (?) short-circuits the code like an exception would do, returning the error from the function or assigning to the variable the un-errored value.

This means that, like in exception c++, we can treat all the values like if there were no errors, and the errors will be passed to the calling function automatically. 

If we try this solution, while it has the benefit that the error handling is explicit, it's too verbose and difficult to use, so we have to figure out a way to imitate the ? operator in C++.


# Operator ? in c++

It is clear that if we want to create a small framework for error-handling, we cannot create or modify an existing compiler to add this new operator, so we have to work with the tools we have at hand, so what we should do is to have something similar to a function that behaves like the operator ?.

## Impossibility of short-circuit without compiler support and without exceptions

One of the main problems when trying to implement the operator ? in c++, is that there is no short-circuit capabilties. 
Any function can only return from itself, and this includes to lambdas.

If we have:
```cpp

auto questionmark(auto expr); 
Result<double, MyError> compute();

Result<double, MyError> foo(){
    double result = questionmark(compute());
    std::puts("If error I can't reach here"); 
    return result;
}
```

there is no way that the function questionmark evaluates compute and returns foo altogether, questionark can only return from itself.

The same applies to lambdas:

```cpp

Result<double, MyError> compute();

Result<double, MyError> foo(){
    double result = []{
        auto res = compute();
        match(res,
        [](MyError) {
            -->shortcircuit foo to return directly!!
        },
        [](double value) {
            return value;
        });
    };
    std::puts("If error I can't reach here"); 
    return result;
}
```


this makes creating short-circuit logic impossible using these tools without invoking large ammounts of UB, asm and RAII breakage.


We could try to do somethin using c++ macros:
```cpp
Result<double, DivideByZero> compute_expression(double a, double b) {
    try_get(double, divisionResult, safe_divide(a,b));
    try_get(double, rec, reciprocal(divisonResult));
}
```

This however, is not so clear, verbose and doesn't even look like c++, to perform all the checking logic and short-circuiting necessary, we need to generate the assignment logic to the variable inside the own macro, we with these tools cannot do something like:

```cpp
Result<double, DivideByZero> compute_expression(double a, double b) {
    double divisionResult = try_get(safe_divide(a,b));
    return try_get(reciprocal(divisionResult));
}
```

## GCC C Extensions to the resque

Somehow, I arrived to this GCC man page while doing my research in how could I improve the error handling in C++:

[Statements and Declarations in Expressions](https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html)

This extension, supported at least in **GCC** and **CLANG** compilers, allow us to execute some code before assigning a value to a variable.

So it is possible that you have found this pattern in c++ code before:

```cpp
  const int my_value = [] {
        int sum = 0;
        for (int i = 1; i <= 10; ++i) {
            sum += i * i;  // Sum of squares of first 10 natural numbers
        }
        return sum;
    }();
```

This is used when we want to have a computed-value, and also want it to be const, so an immediate-lambda may be used just for that matter. 

With this C extension, however, we can do something similar.

```cpp
    const int my_value = ({
        int sum = 0;
        for (int i = 1; i <= 10; ++i) {
            sum += i * i;  // Sum of squares of first 10 natural numbers
        }
        sum;  // The last expression determines the value of the statement expression
    });
```

As you can see, the result is the same, this syntax in fact is similar to how rust can return from a function without an explicit return if it's the last expression from a function. So it helps deambiguate between the return from the expression and the return from the function.

Some of you already may have detected what's the point of all of this. While the lambda introduces a callable function expression where we cannot double-return from, what may happen if...

```cpp
void early_return(int value)
{
    int test = ({
        if (value < 100) return;
        value * 25;
    });

    std::print("Values was greater than 100! result is: {}\n", test);
}

int main()
{
    early_return(50);
    early_return(150);
    early_return(10);
}
```

```
ASM generation compiler returned: 0
Execution build compiler returned: 0
Program returned: 0
Values was greater than 100! result is: 3750
```
[godbolt link to the holy grail](https://mytest.godbolt.org/z/zdvWWM6za)

### HOLY MOLLY THIS ACTUALLY WORKS

with this, we have all the pieces in order to write the questionmark operator.

This operator must  opperate like a function but must not be a function, so we will need to relly on our lovely macros.


# Questionmark implementation

This implementation is unreasonably simple,

```cpp
#define try_get(expr) ({                                       \
    auto&& _result = (expr);                                   \
    if consteval {                                             \
        if (_result.index() != 0) {                           \
            throw "Compile-time Error result type!";          \
        }                                                     \
    } else {                                                  \
        if (_result.index() != 0) {                           \
            return std::get<1>(std::forward<decltype(_result)>(_result)); \
        }                                                     \
    }                                                         \
    std::get<0>(std::forward<decltype(_result)>(_result));    \
})
```

We define a macro that accepts an expression, this expression is meant to be any Result<OK_TYPE, ERR_TYPE>, 
If the index is 0, it means that the value is valid, if so, we return the extracted value, if the index is 1, we return from the whole function with the error type generated by expr.



