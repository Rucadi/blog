let 

  gen = x: ''
  <div class="skill padding-top-sm">
      <span></span>
      <div class="skill-name">${x}</div>
  </div>
  '';

  array_of_expertise = [
  "Modern C++ (C++20/23)"
  "Software Architecture"
  "Parallel Programming & HPC"
  "Performance Analysis & Optimization"
  "Monitoring, Profiling & Tracing"
  "Nix & Reproducible Builds"
  "CI/CD & DevOps"
  "Containerization (Docker)"
  "Embedded Systems"
  "Low-Level Programming & Assembly"
  "Driver Development"
  "Memory Management"
  "Processor Interfacing"
  "FPGA Development"
  "Xilinx Vivado"
  "CUDA"
  "RISC-V"
  "Reverse Engineering"
  "Agile Development"
  "SC18 Student Cluster Competition Participant"
  "Former Board Member, VGAFIB"
  ];


in
''
<div class="expertise padding-top-bg">
  <h1 class="heading-primary-white">Skills & Competencies</h1>
  ${builtins.concatStringsSep "" (map gen array_of_expertise)}
</div>
''