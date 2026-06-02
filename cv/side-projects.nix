let 

experiences = [

        {
        "year" = "2025";
        "project" = "toywithraylib";
        "url" = "https://toywithraylib.com/";
        # this is html
        "description" = ''
          Browser-native Raylib game platform built with WebAssembly and Emscripten to run interactive applications locally without a build server.
        '';
      }

      {
        "year" = "2025";
        "project" = "py-nixeval";
        "url" = "https://github.com/Rucadi/py-nixeval";
        # this is html
        "description" = ''
          Python wrapper for running Nix evaluations, enabling Nix as a dependable backend across Windows, Linux, and MacOS.
        '';
      }
        {
        "year" = "2025";
        "project" = "njq";
        "url" = "https://github.com/Rucadi/njq";
        # this is html
        "description" = ''
          Nix-powered query tool for JSON and Nix expressions, offering a declarative query experience.
        '';
      }
      {
        "year" = "2025";
        "project" = "cpp-match";
        "url" = "https://github.com/Rucadi/cpp-match";
        # this is html
        "description" = ''
          C++ extension enabling Rust-style match expressions and structured error handling with early returns.
        '';
    }
    {
        "year" = "2024";
        "project" = "LG Smart TV ports";
        "url" = "https://github.com/rucadi/webos-apps";
        # this is html
        "description" = ''
          Ported N64 Super Mario 64, PICO-8 Emulator FAKE8, and additional applications to LG Smart TV platforms.
          '';
    }
    {
        "year" = "2024";
        "project" = "Nixpkgs maintenance";
        "url" = "https://search.nixos.org/packages";
        # this is html
        "description" = ''
          Maintained several Nixpkgs packages, including devcontainer, flatito, construct, and smtp4dev.
          '';
    }
    {
      "year" = "2023";
      "project" = "Compiler Explorer Nix support";
      "url" = "https://github.com/Rucadi/compiler-explorer-nix";
      "description" = ''
        Added Nix evaluation support to Compiler Explorer, enabling live Nix workflows with assembly visualization.
      '';
    }
    {
      "year" = "2021";
      "project" = "Pokemon Fire Red multiplayer";
      "url" = "pokemon-project.mp4";
      "description" = ''
      Reverse-Engineering of Pokemon Fire Red using IDA Pro, adapting m-GBA emulator to support hooks on arbitrary memory addresses, reading memory related to the game and offering a simple web-interface to control the actions of the AI.
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