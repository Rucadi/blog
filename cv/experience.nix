let 

experiences = [
    {
        "year" = "2018-2022";
        "company" = "Barcelona Supercomputing Center (BSC) | Jordi Girona, 29, 08034 Barcelona";
        "position" = "R&D Engineer";
        # this is html
        "description" = ''
        <h4>OmpSs@FPGA + CUDA + OpenCL:</h4>
        - Designed and implemented a robust memory coherence layer for virtual and physical memory across heterogeneous computing devices.
        - Architected an asynchronous task execution framework for optimized, dependency-aware workload scheduling.
        - Integrated bare-metal RISC-V task support and FPGA accelerator execution capabilities directly into the OmpSs-2 runtime environment.
        - Engineered comprehensive CUDA and OpenCL kernel support, bridging discrete and unified memory architectures.
        - Developed a custom runtime CUDA loader capable of dynamically parsing ELF files and deploying kernels to edge devices.

        <h4>European MEEP project:</h4>
        - Led FPGA hardware/software co-design on Alveo U280/U55C platforms utilizing Vivado and advanced simulation toolchains.
        - Implemented QEMU PCIe forwarding and engineered a Verilator AXI bridge for rigorous system emulation.
        - Developed critical low-level communication infrastructure, including UART over PCIe and bare-metal UART-Lite drivers.
        - Delivered a first-stage RISC-V bootloader featuring advanced memory introspection and real-time editing capabilities.
        - Successfully ported U-Boot and facilitated complete Linux boot sequences on a custom RISC-V microarchitecture.
        - Implemented Linux kernel DMA API support tailored specifically to the custom hardware architecture.
        - Architected low-latency shared memory and PCIe communication channels between host systems and FPGA accelerators.
        - Developed a high-performance PCIe Ethernet device driver interfacing seamlessly with a custom Verilog Ethernet IP.

        <h4>European Legato project:</h4>
        - Engineered custom editor extensions providing seamless OmpSs autocomplete functionalities for VSCode and Eclipse.
        - Contributed core infrastructure features to a cloud-native integrated development environment (IDE) built on Eclipse Che.
        '';
    }
    {
        "year" = "2022-2026";
        "company" = "Wordline Iberia SAU | PERE IV, 291, 08020 Barcelona";
        "position" = "Software Engineer - Innovation Champion";
        "description" = ''
        - Developed and maintained features for a front-office payment authorization platform, enabling transaction processing for fleet customers across multi-merchant fuel networks.
        - Designed and integrated payment authorization workflows using IFSF and related forecourt communication protocols, ensuring reliable interoperability between payment systems, POS infrastructure, and fuel dispensers.
        - Led modernization of enterprise software platforms, migrating critical systems to C++20 and improving maintainability, performance, and long-term sustainability.
        - Re-architected legacy scripting and automation workflows, increasing operational reliability and reducing maintenance overhead.
        - Performed advanced performance profiling and execution tracing to identify and eliminate critical system bottlenecks.
        - Designed and maintained scalable CI/CD infrastructure supporting multiple high-availability projects and development teams.
        - Architected a centralized Nix-based development platform adopted by approximately 400 engineers, standardizing environments and improving build reproducibility.
        - Developed a distribution-independent deployment strategy using Nix, enabling modern toolchains to coexist seamlessly with legacy production infrastructure.
        - Championed engineering excellence through automated static analysis, pre-commit validation, and reproducible development environments, improving code quality and developer productivity.
        - Provided technical leadership, training, and mentorship on modern C++, containerization, Nix ecosystems, and software engineering best practices.
        - Drove organization-wide modernization initiatives that improved software resilience, developer experience (DX), and engineering efficiency across the platform.
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