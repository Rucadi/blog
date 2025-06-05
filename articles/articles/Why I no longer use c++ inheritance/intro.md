# introduction


I paved my way into the world of programming with Java and C++, It was almost mandatory to learn OOP and inheritance, when I first started programming, I was told that inheritance was the best way to reuse code and create a hierarchy of classes.
Nobody in my surroundings never questioned this, we were even encouraged and forced to use inheritance in multiple university assignments. It almost seemed obvious, when I was into game development, there were multiple layers of inheritance in
the enemies and items, each layer was inheriting for a different class, and it was easy to add new items and enemies by just inheriting from the base class.

But as I had more experience with C++ and I had to deal with projects which used inheritance extensively, I started to see the cracks in the system.

# <a name="blog-post-index"></a> [<a href="#blog-post-index">Blog Post Index</a>](#blog-post-index)

- <a name="introduction"></a> [<a href="#introduction">Introduction</a>](#introduction)
- <a name="traditional-uses-of-inheritance-and-interfaces"></a> [<a href="#traditional-uses-of-inheritance-and-interfaces">Traditional Uses of Inheritance and Interfaces</a>](#traditional-uses-of-inheritance-and-interfaces)
  - <a name="interfaces-via-pure-virtual-classes"></a> [<a href="#interfaces-via-pure-virtual-classes">Interfaces via Pure Virtual Classes</a>](#interfaces-via-pure-virtual-classes)
  - <a name="interfaces-for-dynamic-dispatch"></a> [<a href="#interfaces-for-dynamic-dispatch">Interfaces for Dynamic Dispatch</a>](#interfaces-for-dynamic-dispatch)
  - <a name="inheritance-for-data-composition"></a> [<a href="#inheritance-for-data-composition">Inheritance for Data Composition</a>](#inheritance-for-data-composition)
  - <a name="virtual-method-pitfalls"></a> [<a href="#virtual-method-pitfalls">Virtual Method Pitfalls</a>](#virtual-method-pitfalls)
    - Signature Sensitivity
    - False Confidence
  - <a name="non-virtual-destructor-pitfall"></a> [<a href="#non-virtual-destructor-pitfall">Non-virtual Destructor Pitfall</a>](#non-virtual-destructor-pitfall)
  - <a name="hidden-data-layout"></a> [<a href="#hidden-data-layout">Hidden Data Layout</a>](#hidden-data-layout)
    - Distributed State
    - Maintenance Overhead
    - Testing & Serialization Complexity
  - <a name="multiple-inheritance-challenges"></a> [<a href="#multiple-inheritance-challenges">Multiple Inheritance Challenges</a>](#multiple-inheritance-challenges)
    - <a name="name-hiding"></a> [<a href="#name-hiding">Name Hiding</a>](#name-hiding)
    - <a name="the-diamond-problem-and-virtual-inheritance"></a> [<a href="#the-diamond-problem-and-virtual-inheritance">The Diamond Problem and Virtual Inheritance</a>](#the-diamond-problem-and-virtual-inheritance)
  - <a name="slicing"></a> [<a href="#slicing">Slicing</a>](#slicing)
  - <a name="too-many-specific-keywords-and-syntax-for-inheritance"></a> [<a href="#too-many-specific-keywords-and-syntax-for-inheritance">Too Many Specific Keywords and Syntax for Inheritance</a>](#too-many-specific-keywords-and-syntax-for-inheritance)
  - <a name="pointers-and-allocations"></a> [<a href="#pointers-and-allocations">Pointers and Allocations</a>](#pointers-and-allocations)
    - Double Allocation & Indirection
    - Heap Fragmentation & Performance
    - Pointer Safety & Lifetime Management
    - Lose of Cache Locality
  - <a name="misleading-access-modifier-gotchas"></a> [<a href="#misleading-access-modifier-gotchas">Misleading Access-Modifier Gotchas</a>](#misleading-access-modifier-gotchas)
    - Overriding Is Independent of Inheritance Specifier
    - Re-Exposing Hidden Base Methods
    - Constructor Visibility
  - <a name="visitor-pattern-boilerplate-and-double-dispatch"></a> [<a href="#visitor-pattern-boilerplate-and-double-dispatch">Visitor Pattern Boilerplate and Double Dispatch</a>](#visitor-pattern-boilerplate-and-double-dispatch)
- <a name="composition-over-inheritance-for-data-composition"></a> [<a href="#composition-over-inheritance-for-data-composition">Composition Over Inheritance for Data Composition</a>](#composition-over-inheritance-for-data-composition)
  - <a name="composition-and-interfaces"></a> [<a href="#composition-and-interfaces">Composition and Interfaces</a>](#composition-and-interfaces)
- <a name="non-virtual-interfaces-with-concepts"></a> [<a href="#non-virtual-interfaces-with-concepts">Non-virtual Interfaces with Concepts</a>](#non-virtual-interfaces-with-concepts)
  - <a name="out-of-class-interface"></a> [<a href="#out-of-class-interface">Out-of-Class Interface</a>](#out-of-class-interface)
    - Enhancing Flexibility with C++20 Concepts
- <a name="non-polymorphic-dynamic-dispatch"></a> [<a href="#non-polymorphic-dynamic-dispatch">Non-polymorphic Dynamic Dispatch</a>](#non-polymorphic-dynamic-dispatch)
  - <a name="approach-1-classic-visitor-pattern-via-inheritance"></a> [<a href="#approach-1-classic-visitor-pattern-via-inheritance">Approach 1: Classic Visitor Pattern via Inheritance</a>](#approach-1-classic-visitor-pattern-via-inheritance)
  - <a name="approach-2-variant-visit"></a> [<a href="#approach-2-variant-visit">Approach 2: std::variant + std::visit (Modern, No Inheritance)</a>](#approach-2-variant-visit)
  - <a name="overloaded-pattern-and-in-place-visitors-with-lambdas"></a> [<a href="#overloaded-pattern-and-in-place-visitors-with-lambdas">Overloaded Pattern and In-Place Visitors with Lambdas</a>](#overloaded-pattern-and-in-place-visitors-with-lambdas)
    - Overloaded Pattern Implementation
  - <a name="visit-variant-helper"></a> [<a href="#visit-variant-helper">visit_variant Helper</a>](#visit-variant-helper)
  - <a name="my-thoughts"></a> [<a href="#my-thoughts">My Thoughts</a>](#my-thoughts)
- <a name="performance"></a> [<a href="#performance">Performance</a>](#performance)
  - Comparison Table
- <a name="conclusion"></a> [<a href="#conclusion">Conclusion</a>](#conclusion)