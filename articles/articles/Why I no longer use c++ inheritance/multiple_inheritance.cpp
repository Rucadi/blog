
template <typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template <typename T>
concept Sequence =
    std::ranges::range<T> && (!std::same_as<std::decay_t<T>, std::string>);

int main() {
  using Var = std::variant<int, double, std::string, std::vector<int>>;
  std::vector<Var> items = {42, 3.14, std::string("Hello, Concepts!"), std::vector<int>{7, 8, 9}};

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