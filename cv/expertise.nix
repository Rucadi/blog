let 

  gen = x: ''
  <div class="skill padding-top-sm">
      <span></span>
      <div class="skill-name">${x}</div>
  </div>
  '';

  array_of_expertise = [
    "Participant in SC18 Student Cluster Competition"
    "ex-Board Member of video games development association (VGAFIB)"
    "Several Programming Languages"
    "FPGA"
    "CUDA"
    "C++23"
    "Nix Language"
    "Game Development"
    "Container Technologies"
    "Parallel Programming & HPC"
    "Embeded Systems"
    "RISC-V"
    "Low Level Programming & Assembly"
    "Processor Interfacing" 
    "Knowledege in Driver Development"
    "Memory Management"
    "Unix Systems"
    "CI/CD Pipelines"
    "Agile Methodologies"
    "Monitoring & Tracing"
    "Performance Analysis"
    "Software Architecture"
    "Reverse Engineering"
    "Reproducible Builds"
    "3D Printing"
    "Minimize Errors"
  ];
in
''
<div class="expertise padding-top-bg">
  <h1 class="heading-primary-white">Misc</h1>
  ${builtins.concatStringsSep "" (map gen array_of_expertise)}
</div>
''