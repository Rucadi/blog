

# Traditional Uses of Inheritance and Interfaces

In any language, an Interface (or API) is a contract which defines which methods can be called for specific functionality. In the case of C++, interfaces are often tied to a **class** which defines some data and methods to work with that data. However, in C++ it is also common to use this interfacing for polymorphism, which is achieved via inheritance.

When we talk about inheritance in c++, we can refer to Interfacing via inheritance or expanding via inheritance, which are two different concepts.

When we talk about interfacing via inheritance, we're referring to the practice of using pure virtual functions in a base class to define a set of operations that derived classes must implement. This is a key part of achieving polymorphism in C++. The base class acts as an interface, and derived classes provide the specific implementations.

However, we can also expand via inheritance, where a derived class builds upon the functionality provided by a base class. In this case, the base class is not necessarily abstract. It may contain implemented methods and data members that are shared among derived classes. The derived class can reuse, override, or extend these members to provide more specialized behavior.

In this post, I will explain why I think that either of this approaches shouldn't rely on inheritance at all, and you should only use inheritance for metaprogramming.

## Interfaces via Pure Virtual Classes

In C++, a common way to define an interface is with an **abstract base class** that has one or more *pure virtual* methods. For example:

```cpp
struct IRenderable {
    virtual ~IRenderable() = default;    // Ensure proper cleanup
    virtual void render() const = 0;      // Must be overridden
};
```

While the syntax may look a bit rough, `= 0` makes `render()` pure virtual, meaning that any subclass must provide its own implementation and making IRendereable not constructable.
It is also good practice to mark The  destructor as `virtual`, which makes deleting through an `IRenderable*` to invoke the correct derived destructor.

## Interfaces for dynamic dispatch

In many cases, when we inherit from a base class, we gain the ability to use polymorphism and dynamic dispatch. This allows us to write code that can work with objects of different derived classes through a base class pointer or reference, without knowing the exact type at compile time.

```cpp
void drawScene(const std::vector<std::unique_ptr<IRenderable>>& items) {
    for (const auto& item : items) {
        item->render();
    }
}
```

With this approach, we can store using the interface class as common type, different classess that implement the same interface in a container, and call the specific implementation of each derived class for an object at runtime.

## Inheritance for Data Composition

Inheritance is also sometimes used to compose objects that hold data, with this pattern, we are not directly defininf an interface, but adding methods and data to a class, provinent from another class.

**Example of Data Composition via Inheritance:**

```cpp
class EntityData {
protected:
    int health;
    int mana;
public:
    EntityData(int h, int m) : health(h), mana(m) {}
};

class EnemyData : public EntityData {
private:
    int threatLevel;
public:
    EnemyData(int h, int m, int threat) : EntityData(h, m), threatLevel(threat) {}
};
```


## Virtual Method Pitfalls

Overriding in C++ relies on exact signature matching for virtual functions:

- **Signature Sensitivity:** A typo or mismatched parameter list silently creates a new non‑virtual method rather than overriding the base version.
- **False Confidence:** Without the `override` specifier, developers may assume a method is virtual when it isn’t, leading to unexpected behavior at runtime.

```cpp
struct Base { virtual void update(int) = 0; };
struct Derived : Base {
    void update(float);      // Compiles, but does NOT override Base::update(int)
    void update(int) override; // Compiler error if signature mismatches
};
```

**Best Practice:** Always append `override` to virtual methods to let the compiler catch signature mismatches early.

## Non‑virtual Destructor Pitfall

If the base destructor isn’t declared `virtual`, deleting via a `Base*` only calls `Base::~Base()`, and the `Derived` destructor (and any of its cleanup) is never invoked—leading to resource leaks and undefined behavior.

```cpp
#include <print>

struct Base {
    Base()  { std::println("Base ctor"); }
    ~Base() { std::println("Base dtor"); }  // Not virtual!
};

struct Derived : Base {
    Derived()  { std::println("Derived ctor"); }
    ~Derived() { std::println("Derived dtor"); }
};

int main() {
    Base* obj = new Derived();
    delete obj;  
    // Output:
    //   Base ctor
    //   Derived ctor
    //   Base dtor       <-- Derived dtor never called!
    return 0;
}
```

**Best Practice:**
Always declare the base class destructor as `virtual` if the class is meant to be used polymorphically:

```cpp
struct Base {
    virtual ~Base() = default;  // Now delete obj properly calls Derived::~Derived()
};
```

This guarantees the full chain of destructors runs, ensuring proper cleanup of derived resources, this is one of the most common ways memory leak when using inheritance.

## Hidden Data Layout

Using inheritance to compose data can scatter an object’s state across multiple base classes:

- **Distributed State:** Member variables live in different levels of the hierarchy, often in separate files.
- **Maintenance Overhead:** Tracking total memory footprint or locating a specific field may require jumping between class definitions.
- **Testing & Serialization Complexity:** Gathering all data for unit tests or serializing an object graph becomes error‑prone when parts of its state are hidden deep in parent classes.

## Multiple Inheritance Challenges

Deriving from more than one class introduces method and state ambiguities:

- **Name Hiding:** When two base classes define members with the same name or signature, the derived class must disambiguate explicitly using qualified names. This includes method calls, member variables, and inherited types.

```cpp
struct A { void draw(); };
struct B { void draw(); };
struct C : A, B {
    void render() {
        A::draw();  // Must choose A or B explicitly
    }
};
```

---

## The Diamond Problem and Virtual Inheritance

The classic diamond occurs when two intermediate classes share the same ancestor:

```
    Base
   /    \
  A      B
   \    /
    Derived
```

`Derived` ends up with two separate `Base` subobjects. Accessing `Base` members becomes unclear, Base from which inherited class?, for this, we can use virtual inheritance by prefixing the intermediate bases with `virtual`. This ensures that a single shared `Base` instance is instantiated.

```cpp
struct Base { int id; };
struct A : virtual Base { };  
struct B : virtual Base { };
struct C : A, B { };  // C now has one Base subobject
```


## Slicing
When objects of derived types are passed or assigned by value to base class objects, the derived parts are lost.

```cpp
struct Base { int a; };
struct Derived : Base { int b; };

Base b = Derived(); // b.b is sliced off and lost
```


## Too many specific keywords and syntax for inheritance

C++ inheritance introduces a number of syntactic constructs that are rarely encountered outside of class hierarchies, this makes the language harder and adds little bits of information scattered around all the class that directly affect the behavior, which complicates the mental map of these classess.

- **Access-specifier on inheritance:**
  ```cpp
  struct Derived : public Base { /*…*/ };
  struct PrivateDerived : private Base { /*…*/ };
  ```
- **Virtual base specifier:**
  ```cpp
  struct V : virtual Base { };
  ```
- **Pure-specifier (`= 0`):** declares abstract methods
  ```cpp
  virtual void f() = 0;
  ```
- **Override and final:** enforce overriding rules
  ```cpp
  void f() override;
  void f() final;
  ```
- **Inheriting constructors:** import all constructors from the base
  ```cpp
  struct D : Base { using Base::Base; };
  ```
- **Using-declaration for overloads:** bring selected base overloads into scope
  ```cpp
    struct Base { void foo(int); void foo(double); };
    struct D : Base {
        using Base::foo;
        void foo(std::string);
    };
  ```
- **Dynamic casting** which only support inherited types
  ```cpp
  Base* b = new Derived();
  typeid(*b);        // RTTI required
  dynamic_cast<D*>(b);
  ```
- **Qualified lookup for disambiguation:** call a specific base’s member
  ```cpp
  D d;
  d.Base1::foo();
  ```
- **Covariant returns:** allow a derived type to refine the return
  ```cpp
  struct B { virtual B* clone(); };
  struct D : B { D* clone() override; };
  ```

- Explicitly defaulted or deleted special member functions
  The base class can influence derived class behavior in implicit and subtle ways, especially with rule-of-five and defaulting/deleting:
  ```cpp
  Edit
  struct Base {
      Base(const Base&) = delete;
  };
  struct D : Base {
      // Copy constructor deleted too
  };
  ```

- **CRTP (Curiously Recurring Template Pattern):** static polymorphism via inheritance
  CRTP can be hard to read and maintain, as the recursive inheritance pattern is non-intuitive and tightly couples the base to the derived class, but it offers zero-cost abstraction (which is good! 🎉), however it is also another case of inheritance-specific constructs.
  ```cpp
  template<typename T>
  struct Base { /*…*/ };
  struct Derived : Base<Derived> { /*…*/ };
  ```

# Pointers and allocations

When you use inheritance with standard containers, you almost always end up storing pointers to the base class and dynamically allocating each derived object. Since the compiler only knows the size of the base type at compile time—not the maximum size of all possible derived classes—you cannot place actual objects into the container directly:

```cpp
std::list<BaseClass*> list;
list.push_back(new DerivedA(/*...*/));  // allocates list node + DerivedA instance
```

- **Double Allocation & Indirection:**
  Each `push_back` allocates a list node and separately allocates the derived object on the heap, then stores a pointer—resulting in two allocations and an extra pointer dereference on access.
- **Heap Fragmentation & Performance:**
  Frequent insertions and removals of variably sized objects can fragment the heap, hurting cache locality and increasing allocation latency.
- **Pointer Safety & Lifetime Management:**Raw pointers may be `nullptr`, dangling, or leak memory if `delete` is forgotten. You must ensure:

  - A **virtual destructor** in `BaseClass` for proper cleanup.
  - A clear ownership discipline or use smart pointers (`std::unique_ptr<BaseClass>`, `std::shared_ptr<BaseClass>`)—though these add some overhead in storage or reference counting.

Additionally, consider the use of an array:

```cpp
std::array<BaseClass*, 5> list;
```

- **Lose of cache locality:**
  Each element inside the array is potentially non-contiguous in memory, meaning that we lose all cache-locality when traversing this array.

## Misleading Access-Modifier Gotchas

---

Developers sometimes conflate member access modifiers (`public`/`protected`/`private`) with the effects of inheritance specifiers, leading to subtle bugs and misunderstandings. Here are a few common pitfalls—and how to avoid them:

1. **Overriding Is Independent of Inheritance Specifier**

   - You can override any `virtual` member that is visible in the derived class, regardless of whether you inherit with `public`, `protected`, or `private` access. The inheritance specifier only affects how base members and conversions are exposed, not override semantics.
2. **Re‑Exposing Hidden Base Methods**

   - When you inherit privately or protectedly, base-class members lose their original access in the derived class (e.g., public methods become non-public). To make specific methods public again, use a `using` declaration:

   ```cpp
   struct Base { void api(); };
   struct Derived : private Base {
       using Base::api;  // exposes api() as public in Derived
   };
   ```
3. **Constructor Visibility**

   - Base constructors are not accessible to clients of a privately inherited class unless you explicitly import them with `using Base::Base;`. Without this, you cannot construct `Derived` with the same signature as `Base` unless you write forwarding constructors yourself.

# Visitor Pattern Boilerplate and Double Dispatch

- C++ only supports *single dispatch*—method resolution based on the dynamic type of one object. The visitor pattern enables *double dispatch*, selecting behavior based on both the element and the visitor type.
- This requires every derived class to implement an `accept()` method that calls back into the visitor with `*this`, allowing the correct overload of `visit()` to be invoked based on the actual derived type.

```cpp
class Base {
public:
    virtual void accept(Visitor& v) = 0;
};

class DerivedA : public Base {
public:
    void accept(Visitor& v) override {
        v.visit(*this);
    }
};

class DerivedB : public Base {
public:
    void accept(Visitor& v) override {
        v.visit(*this);
    }
};

class Visitor {
public:
    virtual void visit(DerivedA& a) = 0;
    virtual void visit(DerivedB& b) = 0;
};

class ConcreteVisitor : public Visitor {
public:
    void visit(DerivedA& a) override {
        // Handle DerivedA
    }
    void visit(DerivedB& b) override {
        // Handle DerivedB
    }
};
```

This pattern is verbose and requires predefining all combinations of visitors and visitable types, limiting flexibility and increasing maintenance cost. It also contradicts the open/closed principle, since adding a new type requires modifying every visitor class. 

This should make you think: **At this point, why use virtual polymorphic dispath at all?**
