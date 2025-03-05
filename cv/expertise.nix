let 

  gen = x: ''
  <div class="skill padding-top-sm">
      <span></span>
      <div class="skill-name">${x}</div>
  </div>
  '';

  array_of_expertise = [
    "Participant in SC18 Student Cluster Competition"
    "Parallel Programming & HPC"
    "Performance Analysis"
    "CUDA"
    "C++23"
    "Software Architecture"
    "Embedded Systems"
    "FPGA"
    "Xilinx Vivado"
    "Low Level Programming & Assembly"
    "RISC-V"
    "Familiar with Driver Development"
    "Processor Interfacing"
    "Memory Management"
    "Unix Systems"
    "Container Technologies"
    "Docker"
    "CI/CD Pipelines"
    "Reproducible Builds"
    "Agile Methodologies"
    "Monitoring & Tracing"
    "Nix Language"
    "Reverse Engineering"
    "ex-Board Member of video games development association (VGAFIB)"
    "Game Development"
];

in
''
<div class="expertise padding-top-bg">
  <h1 class="heading-primary-white">Misc</h1>
  ${builtins.concatStringsSep "" (map gen array_of_expertise)}
</div>
''