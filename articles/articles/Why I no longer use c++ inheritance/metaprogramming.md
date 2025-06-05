
<details>
<summary>
Additionally, of-of-scope of this article, inheritance can also be used for metaprogramming
</summary>

## Inheritance for Metaprogramming

Beyond runtime polymorphism, inheritance is a powerful tool in C++ metaprogramming. By leveraging template specialization and type traits through inheritance, developers can propagate compile-time information and resolve overloads—all without incurring runtime costs.

**Key Uses and Techniques:**

- **Type Traits:** Inheritance is widely used to define type traits, providing compile-time constants and properties for types. For example, inheriting from `std::true_type` or `std::false_type` can signal whether a type meets a particular condition:

  ```cpp
  #include <type_traits>

  template <typename T>
  struct is_pointer : std::false_type {};

  template <typename T>
  struct is_pointer<T*> : std::true_type {};

  // Usage:
  static_assert(is_pointer<int*>::value, "int* should be a pointer type");
  ```
- **Tag Dispatching:** Inheritance can facilitate overload resolution at compile time by using tag dispatch. Different tags (as types) guide function overloading, allowing the compiler to select the most appropriate implementation:

  ```cpp
  struct InputIteratorTag {};
  struct RandomAccessIteratorTag : public InputIteratorTag {};

  template <typename Iterator>
  void advance_impl(Iterator& it, int n, InputIteratorTag) {
      while (n--) { ++it; }
  }

  template <typename Iterator>
  void advance_impl(Iterator& it, int n, RandomAccessIteratorTag) {
      it += n;
  }

  template <typename Iterator>
  void advance(Iterator& it, int n) {
      // Assume we have a trait to determine the iterator category
      using Category = typename std::iterator_traits<Iterator>::iterator_category;
      advance_impl(it, n, Category());
  }
  ```
- **Overload Resolution:** Inheritance can be used to structure hierarchies that help the compiler select the correct function overload. This approach minimizes ambiguity by ensuring that derived types carry additional compile-time tags or information that can be used to resolve which overload is most appropriate.

These metaprogramming techniques make heavy use of inheritance to perform compile-time computation, eliminating overhead during execution while enabling more flexible and safe code generation.

</details>