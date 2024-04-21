{utils, images}:
rec {
    name = "About";
    category = "me";
    date = "2024-04-16";
    authors = ["ruben"];
    content = ''

Welcome to my blog! I'm Ruben Cano, a software and hardware engineer from Spain. 
I'm passionate about programming, reverse engineering, and computer science in general. 
I'm currently working in the financial sector, but in my working experience I have developed some interesting and less frequent skills, such as

- High-performance systems development in C++
- Runtime development for FPGA systems
- RISC-V Linux driver development
- RISC-V processor interfacing inside ALVEO FPGA
- Accelerator-host communication
- QEMU virtualization of simulated accelerators

This means that I consider myself a versatile engineer, capable of adapting to different technologies and environments,
and I'm always looking for new challenges and opportunities to learn.

In my work experience, I've had the amazing opportunity to work with the following technologies:

- C++
- C
- Linux kernel development
- Verilog/SystemVerilog
- Python
- Nix/NixOS
- Docker (and more low-level api's)
- SQL
- CI/CD in Gitlab
- Full conteinarized cloud environments
- FPGA
- RISC-V assembly
- javascript 
- Bash scripting
- and more!

I'm always looking for new challenges and opportunities to learn, but I'm also very teachy and I love to share my knowledge with others.

As you can imagine, I see programming as a tool, so I don't feel like I'm tied to any specific language or technology,

My passion for technology started at 13, and I learned to program by modding video games in Python and Lua, 
which led me to develop some mods and hacks for that game, where I developed some reverse-engineering knowledge.
All of that sparkled the fire on me and eventually to study computer engineering and become a nerdy engineer :)

I hope you enjoy my blog, and if you have any questions or suggestions, feel free to contact me!

Also, if you want to request a training or a talk, I'm always open to new opportunities! 
So don't hesitate to contact me for commercial purposes. 

My two languages of preference are Spanish and English.

Before I finish, I want to thank you for visiting my blog, and I hope you enjoy the content I create!
I also love cats, I present you Kero and Mia, say hello!

${(utils.file2base64 ./gato.png).htmlImageWithStyle ""}

    '';

}