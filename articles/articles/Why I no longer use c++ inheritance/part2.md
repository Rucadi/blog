
## 2. Composition Over Inheritance for data composition

There have been discussions [for decades](https://stackoverflow.com/questions/49002/prefer-composition-over-inheritance) about composition or inheritance, and since this article talks about how to ditch (as much as possible) inheritance, it only makes sense to recommend and prefer to use composition over inheritance.

What this really means is that, instead of inheriting data members from a base class (which also brings all the methods), composition involves including an instance of another class as a member within your class. This keeps all data localized, avoiding the pitfalls of inheritance-based data composition.

```cpp
struct EntityData {
    int health;
    int mana;
    EntityData(int h, int m) : health(h), mana(m) {}
};

class EnemyData {
private:
    EntityData entity;
    int threatLevel;
public:
    EnemyData(int h, int m, int threat) : entity(h, m), threatLevel(threat) {}
};
```

Here, `EnemyData` contains an `EntityData` object as a member. All data (`health`, `mana`, and `threatLevel`) is encapsulated within `EnemyData`, making the class’s state explicit and easier to manage.

You could even take it a step further and "un-generalize" the code if the hierarchy isn’t truly necessary:

```cpp
struct EnemyData {
    int health;
    int mana;
    int threatLevel;
};
```

## Composition and interfaces

Composition does not mean to not have interfaces, interfaces are a powerful abstraction tool that allows us to specify the minimum set of functionality that a class must provide.

Consider the following interface:

```cpp
class IRenderable {
public:
    virtual ~IRenderable() = default;
    virtual void render() const = 0;
};

class Sprite : public IRenderable {
public:
    void render() const override {
        // Render the sprite
    }
};
```

Here, `IRenderable` uses inheritance to define a behavioral contract: any class implementing it must provide a `render` method. This is a legitimate and powerful use of inheritance, enabling polymorphism without imposing data requirements.

Now, imagine combining this with composition for data:

```cpp
struct RenderData {
    Texture texture;
    Position pos;
};

class Sprite : public IRenderable {
private:
    RenderData data;  // Composed data
public:
    Sprite(const Texture& tex, Position p) : data{tex, p} {}
    void render() const final override {
        // Use data.texture and data.pos to render
    }
};
```

In this design:

- **Inheritance** handles the interface (`IRenderable`), ensuring `Sprite` adheres to the `render` contract, final keyword is used to tell the compiler that this method cannot be overriden, and since the base class had it virtual, it will probably devirtualize it to avoid performance penalty.
- **Composition** manages the data (`RenderData`), keeping it self-contained within `Sprite`.

This separation of concerns leverages the strengths of both approaches: inheritance for behavior, composition for data.

## 2.  Non-virtual interfaces with Concepts

Introduced in C++20, **concepts** offer a powerful way to define requirements on types—both behavior *and* data—without relying on inheritance. Unlike pure virtual interfaces, in a way, a concept is making questions to the compiler, and returning true or false from the requires expression depending if the compiler can compile the code or agrees with your statements.

Here’s an example of a concept that refines `Renderable`, notice that, unlike with virtual interfaces, here we not only can ask questions about
the methods that exits, but also about the internal data representation or any question we have about the type.

```cpp
template <typename T>
concept Renderable = requires(T t) {
    { t.render() } -> std::same_as<void>;      // Must have a render method
    { t.texture } -> std::same_as<Texture&>;   // Must have a texture member
};
```

This concept ensures that any type used with it has:

- A `render` method returning `void`.
- A `texture` member of type `Texture&`.

You can then use it in a template:

```cpp
template <Renderable R>
void draw(const R& renderable) {
    // Access renderable.texture and call renderable.render()
}
```

or with auto:

```cpp
void draw(Rendereable auto& rendereable){
    // Access renderable.texture and call renderable.render()
}
```

This way, we are specifying an "untied-contract", any type that implements the method render() and has an attribute texture can call this draw function.

A class satisfying this might look like:

```cpp
class Sprite {
public:
    Texture& texture;
    Sprite(Texture& tex) : texture(tex) {}
    void render() const {
        // Render using texture
    }
};
```

Notice that we don't require to specify anything, if we were to use this in code that calls the Rendereable method.

**Advantages of Concepts Over Virtual Interfaces:**

- **Data Requirements:** Unlike pure virtual classes, concepts can mandate specific data members (e.g., `texture`), not just methods.
- **No Inheritance:** Types don’t need to derive from a base class—any class meeting the requirements works, reducing coupling and hierarchy complexity.
- **No virtualization:** There is no runtime vtable overhead, you don't need to mark functions as "final".
- **Concept composition and metaprogramming:** Concepts can be composed and used in more ways than inheritance, we can create concepts that include other concepts or use them to conditionally-call different code.

# Out-of-class interface

In c++, the language-way to expand the functionality of a class is to create new methods or adding new data inside the class, However, there are times when you need to extend a class's functionality but cannot modify its source code directly.

A common solution is to create a proxy object. This could involve:

- Wrapping the original class, exposing its methods through proxy methods while introducing new functionality.
- Inheriting from the original class and adding new methods.

This, however, is a problem, since when creating these proxy objects, we are changing the type of underlying object, meaning that code that expects an specific type does not work with our new type.

In c++, when we wanted common functionality not-dependent on the object, we usually relied on namespaces and function overloads, this way, we could use free-functions to provide functionality that accepts any type.

```cpp

namespace mylib::serialize {

    void serialize(const TYPE& obj) {
        // Serialization logic here
    }
}

```

The good thing about namespaces, is that, in contrast to structs, we can define parts of a namespace in any place in a non-contiguous manner, this means that, if we want to introduce support for a new type on our serialize function, we can do so in a new header, by just adding the correct signature

```cpp
namespace mylib::serialize {

    void serialize(const NEW_TYPE& obj) {
        // Serialization logic here
    }
}
```

One of the drawbacks of this approach, pre C++20 is that we ahd to be very careful with implicit conversions and objects that satisfied more than one method. However, concepts fixes the previous issues we had with these by allowing us to create concepts to restrict better the typing.

## Enhancing Flexibility with C++20 Concepts

When defining interfaces wth concepts, we improve the readibility and the ease-of-programming of these overloads, now, we can for example, define a concept that checks for a type (that can be any custom type) if it is able to perform an action, and this concept could check if exists a function inside a namespace, for example, for serialization that accept this overload.

This way, we can create functions that conscript objects that are able to perform an action, and get the exact error in case it doesn't fit the constraint.

Consider defining a concept to check if a type is serializable based on the existence of a serialize function in the mylib::serialize namespace:

```cpp
template <typename T>
concept Serializable = requires(const T& obj) {
    mylib::serialize::serialize(obj);
};

template <Serializable T>
void process_and_serialize(const T& obj) {
    // Process the object
    mylib::serialize::serialize(obj);
}
```

If you attempt to pass a type lacking a corresponding serialize function, the compiler will produce a clear error message, such as:

```
error: constraint 'Serializable' not satisfied
```

But introducing serializable for our object would be as easy as implementing it in our namespace as shown before.

These out-of-class and not relying on class methods are a good way to separate data and code, and is the prefered way to work with languages like rust, and, while not being required for it, it also fits well with the next topic of non-polymorphic dynamic dispatch.
