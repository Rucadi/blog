{utils, images}:
let double'' = "''";
dollar = "$";
in
rec {
    name = "Minirun, a minimalistic task-based runtime";
    category = "parallelism";
    date = "2024-04-21";
    authors = ["ruben"];
    content = ''

Some years ago, I was working with runtimes like [OpenMP](https://www.openmp.org/) or [OmpSs-2](https://pm.bsc.es/ompss-2). 
These runtimes can run in what's called task-based mode, and they allow you to write parallel code in a very simple way. 

However, they both share something in common: They require compiler support in order to build the application, which is not very flexible.
I was wondering how difficult it would be to implement a task-based runtime that doesn't require compiler support, and that's how Minirun was born.

Minirun is a minimalistic task-based runtime that doesn't require compiler support. It's written in C++ and it's very simple to use and header-only,
which does not require any compiler extensions and could be used in any C++ project.

# Task based runtimes

Before we dive into Minirun, let's explain a little bit about task-based runtimes. 
Task-based runtimes are a way to write parallel code in a very simple way.

The idea is to write tasks, which are small pieces of code that can be executed in parallel.

Let's see the easiest example of a task using OpenMP taken from [here](https://hpc2n.github.io/Task-based-parallelism/branch/master/task-basics-1/):
```cpp
#include <stdio.h>

int main() 
{
    #pragma omp parallel
    {
        #pragma omp task
        printf("Hello world!\n");
    }
    return 0;
}
```

In this case, we are defining a "parallel region", which is a region of the code that has threads available to execute tasks,
and finally, we are defining the function printf as a task.

The parallel region ends when the program reaches the end of the parallel block between {}, and continues the execution only when all the tasks 
are finished, by default the number of tasks is the number of threads available in the system. So this will print "Hello world!" as many times as threads are available.


This is an easy example that does not use any dependencies nor data sharing between tasks, but it's a good starting point to understand the concept of tasks.

Let's complicate it a little bit, now, we want to modify the value of a variable in a task, and then print it in another task:

```cpp
#include <stdio.h>

int main() {
    int number = 1;
    #pragma omp parallel
    {
        #pragma omp task
        {
            printf("I think the number is %d.\n", number);
            number++;
        }
    }
    return 0;
}
```

Which is the output of this program?
The variable number is shared between tasks, so the output could be different depending on the order of execution of the tasks, 
and the number of threads available, the order in which tasks are executed is not guaranteed.


However, in this other example:

```cpp
#include <stdio.h>

int main() {
    #pragma omp parallel
    {
    int number = 1;
        #pragma omp task
        {
            printf("I think the number is %d.\n", number);
            number++;
        }
    }
    return 0;
}
```

Now that the variable number is defined inside the parallel region, it's private to each thread, so the output will always be "I think the number is 1.".


All these differences are managed by the compiler, which is in charge of generating the code that manages the dependencies between tasks, and the data sharing between them.
This automatic behavior differs of what c++ offers, and can make it very difficult to understand the code, and to debug it.


There are other construct like single, which forces to only create one task instead of one per thread, which makes it possible to create a task that creates tasks.


# Tasks dependencies

In OpenMP4.O, tasks can also have data dependencies. 

A data dependency is a relationship between two tasks that requires that one task waits for the other to finish before it can start, in the case of OpenMp, 
only the value of the pointer is used to determine the dependency.

Let's see an example of a task that depends on another task:

```cpp
#include <stdio.h>

int main() {
    int number;
    #pragma omp parallel
    #pragma omp single
    {
        #pragma omp task depend(out: number)
        {
            number = 0;
        }

        #pragma omp task depend(inout: number)
        {
            number++;
        }

        #pragma omp task depend(in: number)
        {
            printf("I think the number is %d.\n", number);
        }
    }
    return 0;
}
```

There are three types of dependency in OpenMP:

- out: The task writes the value of the variable.
- inout: The task reads and writes the value of the variable.
- in: The task reads the value of the variable.


In this case, the first task creates an output dependency on the variable number, it means that it doesn't  need the 
value of the variable number to start, but it will write the value of the variable number, so the next task can read it.

The second task creates an inout dependency on the variable number, it means that it needs to take the actual value of the variable number,
so now we have a dependency between the first and the second task.

Finally, the third task creates an input dependency on the variable number, it means that it needs the value of the variable number to start,
after the second task finishes, the third task can start.


# Minirun

MiniRun is meant to be small, debugable and easy to use, it does not transform the code,
it just manages the threads and tasks dependencies in less than 1000 lines of code, which is very small compared to other runtimes like OpenMP or OmpSs-2, but
that doesn't mean that it's less powerful, it's just simpler and more flexible.

In minirun only two types of dependency are supported, the output dependency and the input dependency, 
which are the most common dependencies in task-based runtimes. The "Inout" dependency is not supported, but in practice, 
it's not needed because the tasks share the lambda-capture semantics of c++.

# The MiniRun API

To add minirun into your project, you just need to include the header file "MiniRun.hpp" and you are ready to go.
```cpp
#include "MiniRun.hpp"
```


## MiniRun object
Then, before you start, you need to create a "Runtime" Object, which is the manager of the tasks and threads.

This can be done in a straigthforward way:

```cpp
#include "MiniRun.hpp"

MiniRun runtime();//Will use number_of_cpus-1 threads
MiniRun runtime2(2);//Will use 2 threads
```

As you can see, the constructor of the runtime object can take the number of threads that you want to use,
using the number of threads available in the system by default.

These runtime objects share c++ semantics, if this object is destroyed, it will wait for all the tasks to finish before destroying it,
making an implicit "taskwait".


## Task creation

To perform the task creation, there is a method called "createTask".

```cpp
[runtime_object].createTask( [std::function<void()>], [IN_DEPS], [OUT_DEPS], [GROUP]); 
```
- std::function<void()>: The lambda function that will be executed in parallel.
- IN_DEPS: A list of the variables that the task needs to start.
- OUT_DEPS: A list of the variables that the task will write.
- GROUP: An identifier of a group, used to use a single runtime object between unrelated tasks.

The dependencies need to be passed through method called  MiniRun::deps(...) that accepts a variable number of arguments.


Here is an example of the OpenMP code shown before, but using Minirun, [also available in godbolt](https://godbolt.org/z/nYTz1oh8q)
```cpp
#include "MiniRun.hpp"

int main() {
    int number=9999;
    MiniRun runtime;

    runtime.createTask(
        [&number]{number=0;},
        MiniRun::deps(),//in
        MiniRun::deps(number),//out
        1//group
        );
    runtime.createTask(
        [&number]{number++;},
        MiniRun::deps(),//in
        MiniRun::deps(number),//out
        1//group
        );
    runtime.createTask(
        [&number]{printf("I think the number is %d.\n", number);},
        MiniRun::deps(number),//in
        MiniRun::deps(),//out
        1//group
        );
}
```

In this case, MiniRun guarantees us to print "I think the number is 1." because the tasks are executed following the dependency order,
the group parameter was optional.

Also, we do not need to explicitly tell MiniRun to "wait until all tasks are finished", 
because the runtime object will wait for all the tasks to finish before being destroyed, no dangling tasks are allowed.

A more advanced example featuring a [Matrix Multiplication in MiniRun can be seen in godbolt](https://godbolt.org/z/WE1T7rhj9)


# Taskwait construct

In Minirun, there is no need to use a taskwait construct, because the runtime object will wait for all the tasks to finish before being destroyed, however
there are some cases where you may want to wait for a specific task to finish, in that case, you can use the method "waitTask".

```cpp
    [runtime_object].taskwait(); 
    [runtime_object].taskwait([GROUP]); 
```

The first method will wait for all tasks controlled by the runtime object to finish, and the second method will wait for all tasks in the group to finish.


# Cuda, or any other async API

Minirun is not limited to CPU tasks, you can use it with any async API, like Cuda.

To support this, I added support for "Task Finish Callbacks", which are functions that will be executed when the task finishes.

Here is an example of how to use it with Cuda, asume that some functions exists,
but [we can see the full example in github](https://github.com/Rucadi/MiniRun/blob/master/examples/cuda/main.cpp)


```
#include "MiniRun.hpp"
#include "cuda_interface.hpp"

void initialize(float* buffer, float val, int N)
{
    for (int i = 0; i < N; ++i) buffer[i] = val;
}

void check(bool& checkValid, float* buffer, float xv, float yv, float addVal, int N)
{
    const float expected = addVal * xv + yv;
    checkValid = false;
    printf("First %f expected: %f  addval %f xc %f yv %f \n", buffer[0], expected, addVal, xv, yv);
    for (int i = 0; i < N-1; ++i)
        if (std::abs(buffer[i] - expected) > 0.001)
        {
            printf("[%d] Fck %f %f %f \n", i, buffer[i], expected, std::abs(buffer[i] - expected));
            return;
        }

    checkValid = true;
}

int main()
{
    MiniRun run(5);

    int N = 1 << 10;

    int device = 0;
    float initXval = 2;
    float initYval = 2;
    float addVal = 2;
    setActive(device);
    void* stream = createStream();
    float* d_x = (float*)cMalloc(N * sizeof(float));
    float* d_y = (float*)cMalloc(N * sizeof(float));
    float* x = (float*)malloc(N * sizeof(float));
    float* y = (float*)malloc(N * sizeof(float));
    bool valid = true;



    run.createTask([&]() { initialize(x, initXval, N); }, {}, MiniRun::deps(x));
    run.createTask([&]() { initialize(y, initYval, N); }, {}, MiniRun::deps(y));
    run.createTask([&]() { setActive(device); copyToDevice(d_x, x, N*sizeof(float), stream); }, MiniRun::deps(x), MiniRun::deps(d_x));
    run.createTask([&]() { setActive(device); copyToDevice(d_y, y, N*sizeof(float), stream); }, MiniRun::deps(y), MiniRun::deps(d_y));
    run.createTask([&]() { setActive(device); saxpy(N, d_x, d_y, addVal, stream); }, MiniRun::deps(d_x), MiniRun::deps(d_y));

    run.createTask(
        [&]() {
            setActive(device);
            copyToHost(y, d_y, N * sizeof(float), stream);
        },
        [&]() {
            setActive(device);
            return streamEmpty(stream); //since we have enqueued all into a stream...
        }, MiniRun::deps(d_y), MiniRun::deps(y));

    run.createTask([&]() {check(valid, y, initXval, initYval, addVal, N); }, MiniRun::deps(y), MiniRun::deps(valid));
    run.taskwait();

    printf("The result is: %d\n", valid);

}
```

In this case, we use tasks in order to copy data to the GPU as soon as that data is ready, taking into account both, the dependencies over
the cuda memory and the host memory. 

We need to activate the CUDA device before using it, since the tasks can be executed in any thread. After this, we enqueue on the stream the operations

Finally, we create te task that will check the status of the execution of the saxpy cuda kernel. This createTask construct is as follows:

```cpp
[runtime_object].createTask(
[]{...}, //Code that is executed when the asynchronous operation is finished
[]{...}, //Code that checks that the previous operations are finished, returning true if they are, reexecuting the lambda if they are not
	{}, //in dependences
	{}; //out dependences
```
And then, we create a task that will check the result of the saxpy operation was performed correctly.


With this, we can use MiniRun to check the finalization of any asynchronous operation, not only CPU tasks, in a c++ way managing all the dependencies 
explicitly.


# Conclusion

I hope you find Minirun useful, it's a very simple and powerful tool that can help you to write parallel code in a very simple way,
I will be happy to hear your feedback, and if you want to contribute, you can do it in the [github repository](https://github.com/Rucadi/MiniRun).
I've not worked on it since some years ago, and it's not production-tested, but I think it's a good toy to play with :) 
If you want to see more examples, go to the MiniRun repo!

On another note, task-based runtimes are a very powerful way to write parallel code, since it's more "intuitive" than other parallel constructs like threads 
or mutexes, but it's not always the best way to write parallel code, it depends on the problem you are trying to solve, and the architecture you are using.
Analyzing the problem and the architecture is the key to write efficient parallel code.

Finally, I hope you enjoyed this post, and if you have any questions, feel free to ask!


'';


}