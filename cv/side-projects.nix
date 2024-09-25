let 

experiences = [
    {
        "year" = "2024";
        "project" = "Port Super Mario 64 and other apps to LG Smart TV";
        "url" = "https://github.com/rucadi/webos-apps";
        # this is html
        "description" = ''
        Port N64 Super Mario 64 decompilation project, PICO-8 Emulator FAKE8 and some web-apps to LG Smart TV.
          '';
    }
    {
        "year" = "2024";
        "project" = "Maintain several packages on Nixpkgs";
        "url" = "https://search.nixos.org/packages";
        # this is html
        "description" = ''
        I maintain several packages on nixpkgs of my interest, some of them are:
        - devcontainer
        - valkey
        - flatito
        - construct
        - smtp4dev
          '';
    }
    {
      "year" = "2023";
      "project" = "Port Nix Language to compiler-explorer";
      "url" = "https://github.com/Rucadi/compiler-explorer-nix";
      "description" = ''
        Allows to run Nix evaluations on compiler-explorer, a web-based compiler that allows to see the assembly code generated by the compiler.
      '';
    }
    {
      "year" = "2021";
      "project" = "Pokemon Fire Red multiplayer";
      "url" = "pokemon-project.mp4";
      "description" = ''
      Reverse-Engineering of Pokemon Fire Red using IDA Pro, adapting m-GBA emulator to support hooks on arbitrary memory addresses,
      reading memory related to the game and offering a simple web-interface to control the actions of the AI.
      '';
    }
    {
      "year" = "2021";
      "project" = "Barebones MMORPG server";
      "url" = "https://gitlab.com/ruben.cano96/servermmo21";
      "description" = ''
        Unfinished MMORPG server written in C++ using postgresql and redis for the backend and ENet for the networking following the principles of 
        the articles written by <a href="http://ithare.com/category/dnd-of-mogs-vol1-1st-beta">It Hare</a>
      '';
    }
    {
      "year" = "2020";
      "project" = "MiniRun runtime";
      "url" = "https://rucadi.eu/minirun-a-minimalistic-task-based-runtime.html";
      "description" = ''
        Minirun is a minimalistic task-based runtime that doesn't require compiler support. 
        It's written in C++ and it's very simple to use and header-only, which does not require any compiler extensions and could be used in any C++ project.
        Supports tasks dependencies with sentinels and etherogeneous devices like CUDA, OpenCL, etc.
      '';
    }
    {
      "year" = "2019";
      "project" = "WSLD";
      "url" = "https://github.com/Rucadi/wsld";
      "description" = ''
        WSLD is a simple tool to manage WSL distributions, it allows to import/export, backup and restore WSL distributions using docker images as the base.
        '';
    }
    {
      "year" = "2010-2024";
      "project" = "Several small projects";
      "url" = "";
      "description" = ''
          Designed new quests and systems for MMORPG private-servers, in both, server and client.
          Created new systems for MMORPG private-servers
          Cheat-detection systems on MMORPGs
          Reverse-engineering and cheat development
          Maintenance of MySQL databases 
          FreeBSD sysadmin
          Personal programming professor
          Telegram bots
          Chromium web extensions development

          And many more...
      '';
    }
];

gen = x: ''
<div class="xp-box padding-top-sm">
    <p class="xp-year">${x.year}</p>
    <p class="xp-position">${x.project}</p>
    ${if x.url != "" then
      ''<a href="${x.url}" class="xp-link">view more</a>''
    else ""}
    <pre class="description">${x.description}</pre>
</div>
'';
in
''
<div class="sides padding-top-bg">
    <h1 class="heading-primary-black">Side Projects</h1>
    ${builtins.concatStringsSep "" (map gen experiences)}
</div>
''