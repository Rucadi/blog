
---

# Error Handling Strategies in C++

Handling errors effectively is critical in C++ applications. Over time, several techniques have evolved, each with its own trade-offs in terms of clarity, performance, and robustness. This guide outlines the most common methods, along with their advantages and drawbacks.

## 1. Error Codes

### Description
Functions can return a special value (e.g., an integer, an enum, or a dedicated error code type) that signals whether an operation succeeded or failed.

### Advantages
- **Simplicity:** Easy to implement and understand.
- **Performance:** Minimal overhead compared to exceptions.
- **Portability:** Works on platforms or projects where exceptions are disabled.

### Drawbacks
- **Error Ignorance:** Callers might neglect to check return values, potentially ignoring errors, [[nodiscard]] helps with this.
- **Error propagation:** Propagating error codes through multiple function calls can lead to verbose and less readable code.
- **Limited Information:** Error codes often provide little context about the nature or source of the error.

## 1. Error Codes

### Code Snippet

```cpp
enum class ErrorCode {
    Success,
    NotFound,
    InvalidArgument
};

ErrorCode processData(int value) {
    if (value < 0)
        return ErrorCode::InvalidArgument;
    return ErrorCode::Success;
}

int main() {
    ErrorCode err = processData(-5);
    if (err != ErrorCode::Success) {
        std::puts("Error");
    }
    return 0;
}
```

---

## 2. Exceptions

### Description
C++ exceptions involve throwing objects that represent errors, which can then be caught and handled using try-catch blocks.

### Advantages
- **Separation of Concerns:** Normal code logic remains uncluttered by error-handling details.
- **Rich Information:** Exception objects can carry detailed error messages and additional data.
- **Automatic Propagation:** Exceptions automatically unwind the stack, invoking destructors and ensuring resource cleanup (with RAII).

### Drawbacks
- **Performance Overhead:** Exception handling mechanisms may incur runtime costs, especially in performance-critical code.
- **Inconsistent Support:** Some systems and coding guidelines discourage or disable exceptions.
- **Complexity:** Maintaining exception safety (basic, strong, or no-throw guarantees) can complicate design and implementation.
- **Risk of Unhandled Exceptions:** If exceptions are not caught, they can lead to program termination.
- **Lack of caller information:** When using exceptions, the caller must know that the function being called can throw, and all the ways the function (or functions called by that function) can throw. There is no typing help for that, and it easily can lead to unknown exceptions arriving to paths of code we don't expect them.


## 2. Exceptions

### Code Snippet

```cpp
int divide(int a, int b) {
    if (b == 0)
        throw std::invalid_argument("Division by zero");
    return a / b;
}

int main() {
    try {
        int result = divide(10, 0);
        std::cout << "Result: " << result << "\n";
    } catch (const std::invalid_argument &e) {
        std::cerr << "Caught exception: " << e.what() << "\n";
    }
    return 0;
}
```

---

## 3. `std::optional`

### Description
`std::optional<T>` (introduced in C++17) encapsulates an optional value: it either contains a valid result or no value at all, indicating a failure.

### Advantages
- **Expressiveness:** Clearly indicates that a function might not return a value.
- **No Exception Overhead:** Suitable for environments where exceptions are not preferred.
- **Simplicity:** Lightweight and easy to use when the error itself doesn’t need to carry extra information.

### Drawbacks
- **Lack of Error Detail:** An empty `std::optional` signals failure but doesn’t convey why the error occurred.
- **Limited Scope:** Best used when the absence of a value is sufficient to indicate an error, rather than needing detailed diagnostics.

## 3. `std::optional`

### Code Snippet

```cpp
// std::optional: Representing an optional result (requires C++17 or later).
#include <optional>
#include <iostream>

std::optional<int> findEvenNumber(bool condition) {
    if (condition)
        return 2;
    return std::nullopt;
}

int main() {
    auto result = findEvenNumber(false);
    if (result) {
        std::cout << "Found even number: " << *result << "\n";
    } else {
        std::cout << "No even number found.\n";
    }
    return 0;
}
```
---

## 4. `std::expected` (Proposed / C++23)

### Description
`std::expected<T, E>` is a proposed type (and part of C++23 in many implementations) designed to hold either a valid value (`T`) or an error value (`E`). It provides a standardized way to handle operations that might fail.

### Advantages
- **Rich Error Reporting:** Encapsulates both successful results and detailed error information.
- **Explicit Error Handling:** Forces the caller to handle both success and error cases, reducing the chance of unintentional neglect.
- **Enhanced Readability:** Code that uses `std::expected` clearly communicates its intent regarding error handling.

### Drawbacks
- **Verbosity:** Can result in more verbose code compared to simple error codes or exceptions, especially in straightforward scenarios.
- Acessing the value without checking the if it is valid will lead to ub and probably a crash.
- Cannot gather errros from other error realms without handling them first without parsing them first to inside the function logic.

## 4. `std::expected` (Proposed in C++23)

### Code Snippet

```cpp
// std::expected: Representing a result that could either be a value or an error (C++23 or library implementations).
#include <expected>
#include <iostream>
#include <string>

std::expected<int, std::string> safeDivide(int a, int b) {
    if (b == 0)
        return std::unexpected("Division by zero");
    return a / b;
}

int main() {
    auto result = safeDivide(10, 0);
    if (!result) {
        std::cerr << "Error: " << result.error() << "\n";
    } else {
        std::cout << "Result: " << *result << "\n";
    }
    return 0;
}
```

---

## 5. Other Approaches

### Global Error Variables
- **Description:** Use a global or thread-local variable to store error information.
- **Advantages:** Easy to access and modify from anywhere in the code.
- **Drawbacks:** 
  - Not thread-safe without extra measures.
  - Makes debugging and understanding code flow more difficult.
  - Introduces hidden state that can lead to side effects.


## 5. Global Error Variables

### Code Snippet

```cpp
// Global error variables: Setting a global variable to signal errors.
#include <iostream>
#include <string>

std::string globalError;

bool performOperation(bool fail) {
    if (fail) {
        globalError = "Operation failed due to bad input";
        return false;
    }
    return true;
}

int main() {
    if (!performOperation(true)) {
        std::cerr << "Error: " << globalError << "\n";
    }
    return 0;
}
```

### Out Parameters
- **Description:** Return error details via extra parameters (usually passed by reference) alongside the primary return value.
- **Advantages:** 
  - Can provide additional error context without changing the main return type.
  - Sometimes required when working with hardware
- **Drawbacks:** 
  - Clutters function signatures.
  - May be less intuitive as errors are handled via side effects rather than the return value.

## 6. Out Parameters

### Code Snippet

```cpp
// Out parameters: Returning error details through additional reference parameters.
#include <iostream>
#include <string>

bool parseInteger(const std::string &input, int &result) {
    try {
        result = std::stoi(input);
        return true;
    } catch (const std::exception &) {
        return false;
    }
}

int main() {
    int value;
    if (parseInteger("123", value)) {
        std::cout << "Parsed value: " << value << "\n";
    } else {
        std::cerr << "Failed to parse integer.\n";
    }
    return 0;
}
```

---

## Conclusion

No single error handling method is perfect for every scenario:

- **Error Codes** are straightforward and efficient but risk being ignored.
- **Exceptions** provide robust and rich error information, yet can complicate control flow and affect performance.
- **`std::optional`** offers a simple, lightweight way to represent absent values but lacks context about failures.
- **`std::expected`** aims to combine the benefits of both approaches by providing clear success/error semantics with detailed error reporting, though its adoption depends on compiler support and familiarity with the newer paradigm.

Choosing the right approach depends on your project's requirements, performance constraints, and coding style. Modern C++ increasingly favors types like `std::optional` and `std::expected` for their clarity and expressiveness, especially in codebases where error handling is a critical concern.

---