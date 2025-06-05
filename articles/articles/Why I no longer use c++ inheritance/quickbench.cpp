//https://quick-bench.com/q/H89EQlnQUAw7Ev-rTku5SZVchMc
#include <benchmark/benchmark.h>

#include <vector>
#include <variant>
#include <cstdint>

// Base class with a pure virtual function.
class Base {
public:
    virtual void update() = 0;
    virtual ~Base() = default;
};

// Derived class that increments an internal counter.
class Derived1 : public Base {
public:
    Derived1() : counter(0) {}
    void update() override {
        counter++;
    }
private:
    int counter;
};

// Derived class that performs another operation on an internal counter.
class Derived2 : public Base {
public:
    Derived2() : counter(1) {}
    void update() override {
        counter *= 2;
    }
private:
    int counter;
};

//------------------------------------------------------
// Inheritance-based benchmarks
//------------------------------------------------------
static void InheritanceCreation(benchmark::State& state) {
    const int numObjects = state.range(0);
    for (auto _ : state) {
        std::vector<Base*> objects;
        objects.reserve(numObjects);
        for (int i = 0; i < numObjects; ++i) {
            if (i % 2 == 0)
                objects.push_back(new Derived1());
            else
                objects.push_back(new Derived2());
        }
        benchmark::DoNotOptimize(objects);
        for (auto obj : objects)
            delete obj;
    }
}
BENCHMARK(InheritanceCreation)->Arg(1000000);

static void InheritanceUpdate(benchmark::State& state) {
    const int numObjects = state.range(0);
    std::vector<Base*> objects;
    objects.reserve(numObjects);
    for (int i = 0; i < numObjects; ++i) {
        if (i % 2 == 0)
            objects.push_back(new Derived1());
        else
            objects.push_back(new Derived2());
    }
    const int iterations = 1000;
    for (auto _ : state) {
        for (int iter = 0; iter < iterations; ++iter)
            for (auto obj : objects)
                obj->update();
    }
    benchmark::DoNotOptimize(objects);
    for (auto obj : objects)
        delete obj;
}
BENCHMARK(InheritanceUpdate)->Arg(1000000);

//------------------------------------------------------
// std::variant–based benchmarks with inheritance types
//------------------------------------------------------
static void VariantCreation(benchmark::State& state) {
    const int numObjects = state.range(0);
    for (auto _ : state) {
        std::vector<std::variant<Derived1, Derived2>> v_objects;
        v_objects.reserve(numObjects);
        for (int i = 0; i < numObjects; ++i) {
            if (i % 2 == 0)
                v_objects.emplace_back(Derived1());
            else
                v_objects.emplace_back(Derived2());
        }
        benchmark::DoNotOptimize(v_objects);
    }
}
BENCHMARK(VariantCreation)->Arg(1000000);

static void VariantUpdate(benchmark::State& state) {
    const int numObjects = state.range(0);
    std::vector<std::variant<Derived1, Derived2>> v_objects;
    v_objects.reserve(numObjects);
    for (int i = 0; i < numObjects; ++i) {
        if (i % 2 == 0)
            v_objects.emplace_back(Derived1());
        else
            v_objects.emplace_back(Derived2());
    }
    const int iterations = 1000;
    for (auto _ : state) {
        for (int iter = 0; iter < iterations; ++iter) {
            for (auto &var : v_objects) {
                std::visit([](auto &obj) { obj.update(); }, var);
            }
        }
    }
    benchmark::DoNotOptimize(v_objects);
}
BENCHMARK(VariantUpdate)->Arg(1000000);

//------------------------------------------------------
// New benchmarks: std::variant with plain structs (no inheritance)
//------------------------------------------------------
struct SDerived1 {
    SDerived1() : counter(0) {}
    void update() { counter++; }
    int counter;
};

struct SDerived2 {
    SDerived2() : counter(1) {}
    void update() { counter *= 2; }
    int counter;
};

static void StructVariantCreation(benchmark::State& state) {
    const int numObjects = state.range(0);
    for (auto _ : state) {
        std::vector<std::variant<SDerived1, SDerived2>> v_objects;
        v_objects.reserve(numObjects);
        for (int i = 0; i < numObjects; ++i) {
            if (i % 2 == 0)
                v_objects.emplace_back(SDerived1());
            else
                v_objects.emplace_back(SDerived2());
        }
        benchmark::DoNotOptimize(v_objects);
    }
}
BENCHMARK(StructVariantCreation)->Arg(1000000);

static void StructVariantUpdate(benchmark::State& state) {
    const int numObjects = state.range(0);
    std::vector<std::variant<SDerived1, SDerived2>> v_objects;
    v_objects.reserve(numObjects);
    for (int i = 0; i < numObjects; ++i) {
        if (i % 2 == 0)
            v_objects.emplace_back(SDerived1());
        else
            v_objects.emplace_back(SDerived2());
    }
    const int iterations = 1000;
    for (auto _ : state) {
        for (int iter = 0; iter < iterations; ++iter) {
            for (auto &var : v_objects) {
                std::visit([](auto &obj) { obj.update(); }, var);
            }
        }
    }
    benchmark::DoNotOptimize(v_objects);
}
BENCHMARK(StructVariantUpdate)->Arg(1000000);

