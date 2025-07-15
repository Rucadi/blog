let 

  gen = x: ''
  <div class="skill padding-top-sm">
      <span></span>
      <div class="skill-name">${x}</div>
  </div>
  '';

  array_of_expertise = [
    "Participant in SC18 Student Cluster Competition"
    "Nix Language"
    "Parallel Programming & HPC"
    "Performance Analysis"
    "Monitoring & Tracing"
    "C++23"
    "Software Architecture"
    "Embedded Systems"
    "Low Level Programming & Assembly"
    "Xilinx Vivado"
    "FPGA"
    "CUDA"
    "RISC-V"
    "Driver Development"
    "Processor Interfacing"
    "Memory Management"
    "Container Technologies"
    "Docker"
    "CI/CD Pipelines"
    "Reproducible Builds"
    "Reverse Engineering"
    "ex-Board Member of video games development association (VGAFIB)"
    "Agile Methodologies"
];

in
''
<div class="expertise padding-top-bg">
  <h1 class="heading-primary-white">Misc</h1>
  ${builtins.concatStringsSep "" (map gen array_of_expertise)}
</div>
''