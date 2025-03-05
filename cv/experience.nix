let 

experiences = [
    {
        "year" = "2018-2022";
        "company" = "Barcelona Supercomputing Center (BSC) | Jordi Girona, 29, 08034 Barcelona";
        "position" = "R&D Engineer";
        # this is html
        "description" = ''
        <h4>OmpSs@FPGA + CUDA + CL (public):</h4>
        - Coherency layer between any number of virtual or physical memory spaces.
        - Framework that allows to execute the asynchronous-tasks once the data is ready on the device.
        - Baremetal RISC-V tasks protocol and integration with OmpSs-2 runtime. 
        - Support for execution of tasks in FPGA accelerators for OmpSs-2 runtime. 
        - Support for CUDA and OpenCL CUDA Kernels for both, discrete and unified memory.
        - Runtime CUDA-Loader that self-reads the elf file and loads the CUDA kernels into the device. 

        <h4>European MEEP project (public): </h4>
        - Experience with Alveo U280 and U55C cards using vivado software.
        - QEMU remote pci-forwarder device and AXI bridge for verilator.
        - Simulated UART over PCIe bar and baremetal UART-Lite drivers.
        - 1st-stage bootloader for RISC-V which with a memory viewer/editor.
        - U-BOOT Port to our custom RISC-V core.
        - Linux-boot on our custom RISC-V core.
        - Linux Kernel dma-api implementation for our RISC-V architecture
        - Shared memory between PCIe host and RISC-V core residing in FPGA.
        - Ethernet over shared memory host/riscv-fpga.
        - PCIe ethernet device driver for "verilog-ethernet" IP.
        - Interfacing of RISC-V cores with interconnects/devices and DRAM/HBM memory on FPGA.

        <h4>European Legato project (public):</h4>
        - VSCode/Eclipse plugin for OmpSs autocomplete.
        - Cloud-Based integrated IDE based on Eclipse Che. 

          '';
    }
    {
        "year" = "2022-2025";
        "company" = "Wordline Iberia SAU | PERE IV, 291, 08020 Barcelona";
        "position" = "Software Engineer";
        "description" = ''
            - Modernize C++20 codebase by using modern C++ features and best practices.
            - Modernize and unify scripts using Python to replace legacy bash scripts.
            - Analyze performance bottlenecks and create traces to identify the root cause.
            - Introduce new tools and methodologies to improve the development process.
            - Create and maintain CI/CD pipelines for the projects.
            - Lead a team to develop a development environment for (~400 developers) using Nix language and containerization technologies.
            - Perform code mentoring and training sessions on Container Technologies, Nix and C++20.
            - Work in client-related projects to develop new features in a financial application.
        '';
    }
];

gen = x: ''
<div class="xp-box padding-top-sm">
    <p class="xp-year">${x.year}</p>
    <p class="xp-company">${x.company}</p>
    <p class="xp-position">${x.position}</p>
    <pre class="description">${x.description}</pre>
</div>
'';
in
''
<div class="experience padding-top-bg">
    <h1 class="heading-primary-black">Experience</h1>
    ${builtins.concatStringsSep "" (map gen experiences)}
</div>
''