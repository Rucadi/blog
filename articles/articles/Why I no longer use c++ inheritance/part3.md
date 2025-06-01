
## 3. Non-polymorphic dynamic dispatch

C++17 introduced `std::variant`, a type‑safe discriminated union that can hold one of several compile‑time‑known alternatives. Its size equals that of a contiguous buffer large enough for the largest alternative, plus a small integral tag to indicate which type is currently active.

The standard also adds `std::visit`, an analog of the visitor pattern that requires no inheritance. Unlike traditional polymorphism—which depends on v‑tables, base‑class pointers and dynamic allocations to support new types—`std::variant` dispatches by inspecting its tag in O(1) time.

This design delivers stronger type safety, prevents "slicing" (where a derived object loses data when accessed via a base interface), and incurs zero per‑object heap allocations, resulting in improved cache locality and allowing it to be used in embedded environments.

- **Strong type safety**: Only the correct alternative can be accessed.  
- **No slicing**: You never lose derived‐class data by treating it as a base.  
- **Zero per‐object heap allocations**: Everything lives in the variant’s buffer (unless the type heap-allocates internal data).
- **Excellent cache locality**: Data is stored contiguously, improving performance.


## Exception Safety and Destruction

- **Strong guarantee**  
  When assigning a new alternative, `variant` performs the destruction of the old object and the construction of the new one without explicitly having to delete them.
- **No dangling references**  
  Because everything resides in one contiguous buffer, there is no indirection; you cannot accidentally have a dangling base‑class pointer into a freed object.

---

## Comparison Table

| Aspect                      | `std::variant`                            | Inheritance + Visitor Pattern                   |
|-----------------------------|-------------------------------------------|-----------------------------------------|
| **Extensibility**           | Closed set (recompile or open with std::any + dispatcher)          | Open set (can inherit new types)        |
| **Memory layout**           | Single buffer + tag (stack or embedded)   | Pointer to heap‑allocated object        |
| **Dispatch cost**           | Tag check + inline branch (O(1))          | Double virtual call     |
| **Type safety**             | Compile‑time checked (no cast needed)     | Requires downcasting or overloaded `Visit` methods |
| **Object size**             | Max(aligned size of alternatives) + tag   | Size of pointer per object + heap cost  |
| **Cache friendliness**      | Excellent (objects are contiguous)        | Poorer (pointer chasing)               |
| **Runtime overhead**        | Minimal (no allocation, no v‑table lookup)| Allocation and v‑table indirection     |
| **Exhaustiveness**    | Enforced by compiler        | Enforced by template instantiation  |
| **Type compatibility** | Does not require modification to types | Requires types that inherit from a common base and have an accept method|

# Inheritance with visitor pattern vs std::variant + std::visit


### 1. Inheritance + Visitor Pattern

```cpp
#include <print>
#include <memory>
#include <vector>

// Forward‑declare concrete types
class DerivedA;
class DerivedB;

// 1. Visitor interface
class Visitor {
public:
    virtual void visit(DerivedA& a) = 0;
    virtual void visit(DerivedB& b) = 0;
    virtual ~Visitor() = default;
};

// 2. Base class with accept()
class Base {
public:
    virtual void accept(Visitor& v) = 0;
    virtual ~Base() = default;
};

// 3. Concrete classes override accept()
class DerivedA : public Base {
public:
    void accept(Visitor& v) override { v.visit(*this); }
    void actionA() { std::println("Action in A"); }
};

class DerivedB : public Base {
public:
    void accept(Visitor& v) override { v.visit(*this); }
    void actionB() { std::println("Action in B"); }
};

// 4. ConcreteVisitor implements Visitor
class ConcreteVisitor : public Visitor {
public:
    void visit(DerivedA& a) override {
        std::println("Visiting A");
        a.actionA();
    }
    void visit(DerivedB& b) override {
        std::println("Visiting B");
        b.actionB();
    }
};

int main() {
    std::vector<std::unique_ptr<Base>> objects;
    objects.emplace_back(std::make_unique<DerivedA>());
    objects.emplace_back(std::make_unique<DerivedB>());

    ConcreteVisitor vis;
    for (auto& obj : objects) {
        obj->accept(vis);   // double‑dispatch via virtual calls
    }
}

```
[Try in compiler-explorer](https://visitor2.godbolt.org/z/W4hY7Eodj)
- **Dispatch**: `obj->accept(vis)` → virtual `visit(*)` → concrete `visit(DerivedX&)`.  
- **Boilerplate**: `Base`, `Visitor` interface, concrete classes, visitor implementation.

---

### 2. `std::variant` + `std::visit` 

```cpp
#include <print>
#include <variant>
#include <vector>

// 1. Plain structs
struct A {
    void action() const { std::println("Action in A"); }
};
struct B {
    void action() const { std::println("Action in B"); }
};

// 2. Visitor functor
struct VariantVisitor {
    void operator()(A const& a) const {
        std::println("Visiting A");
        a.action();
    }
    void operator()(B const& b) const {
        std::println("Visiting B");
        b.action();
    }
};

int main() {
    // 3. Heterogeneous collection via variant
    std::vector<std::variant<A,B>> objects;
    objects.emplace_back(A{});
    objects.emplace_back(B{});

    // 4. Single dispatch via std::visit
    for (auto const& obj : objects) {
        std::visit(VariantVisitor{}, obj);
    }
}
```
[Try in compiler-explorer](https://visitor2.godbolt.org/z/8dcP55Kcx)

As we can see, the intent of the code is much clearer, we have less boilerplate and we don't have to deal with pointer usage nor extra heap allocations.

However, this is not all, with some C++ metaprogramming following the ["overloaded pattern" shown in the examples of cppreference ](https://en.cppreference.com/w/cpp/utility/variant/visit2) and explain in other posts in this blog, we can create in-place visitors using lambdas.

```cpp
#include <variant>
#include <utility>

template<class... Ts>
struct overloaded : Ts... {
    using Ts::operator()...;
};


template<typename Variant, typename... Fs>
decltype(auto) visit_variant(Variant&& var, Fs&&... fs) {
    return std::visit(overloaded<Fs...>{std::forward<Fs>(fs)...}, std::forward<Variant>(var));
}

```

which allows us to change the code to:

```cpp
#include <print>
#include <variant>
#include <vector>

struct A {
  void action() const { std::println("Action in A"); }
};
struct B {
  void action() const { std::println("Action in B"); }
};

int main() {
  std::vector<std::variant<A, B>> objects;
  objects.emplace_back(A{});
  objects.emplace_back(B{});

  for (auto const &obj : objects) {
    visit_variant(
        obj,
        [](A const &a) {
          std::println("Visiting A");
          a.action();
        },
        [](B const &b) {
          std::println("Visiting B");
          b.action();
        });
  }
}
```

std::visit in this case, requires a struct that overlaods the operator () for all possible types of the variant, this means that if we fail to provide one, there will be a compile-time error, so we must be exhaustive. It will also always pick the method that better adheres to a type if an implicit conersion where to happen for simple types.

However, that's not all, now we can also group common functionality using "auto".

```cpp
#include <print>
#include <variant>
#include <vector>

struct A {
  void action() const { std::println("Action in A"); }
};
struct B {
  void action() const { std::println("Action in B"); }
};

int main() {
  std::vector<std::variant<A, B>> objects;
  objects.emplace_back(A{});
  objects.emplace_back(B{});

  for (auto const &obj : objects) {
    visit_variant(
        obj,
        [](auto const &val) {
          val.action();
        });
  }
}
```

When using auto this way, what will happens under-the-hood is that two functions will be instantiated, one for A and other for B, but auto will create them for us, auto in this case is useful since we have some common behavior, we can also use auto as the "base-case".

Another interesting thing we can do now is use concepts in order to discern over our visitor functions, for example:

```cpp
template <typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template <typename T>
concept Sequence =
    std::ranges::range<T> && (!std::same_as<std::decay_t<T>, std::string>);

int main() {
  using Var = std::variant<int, double, std::string, std::vector<int>>;
  std::vector<Var> items = {
        42, 
        3.14, 
        std::string("Hello, Concepts!"),
        std::vector<int>{7, 8, 9}
  };

  for (auto const &item : items) {
    visit_variant(
        item,
        // inline lambdas, constrained by concepts:
        [](Numeric auto n) { std::println("Numeric: {}", n); },
        [](Sequence auto const &seq) {
          std::println("Sequence of elements:");
          for (auto const &x : seq) {
            std::println("  {}", x);
          }
        },
        // catch std::string exactly:
        [](std::string const &s) { std::println("String: {}", s); });
  }

  return 0;
}

```
[Toy with it on compiler-explorer](https://visitor2.godbolt.org/z/5GrzWdPqj)


Making this pattern the most modern c++ compatible way of dealing with dynamic dispatch.