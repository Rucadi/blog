compile.GET = let 
            pkgs = import <nixpkgs> {};
            code = pkgs.writeText "main.cpp" query.code;
            compile_command = "${pkgs.gcc}/bin/g++ ${code}";
            run_command = "${pkgs.uutils-coreutils-noprefix}/bin/timeout 10 ./a.out";
        in
        builtins.readFile (
        pkgs.runCommand "gccCompile" {} 
        ''
            ${compile_command} &> tmp || true
            ${run_command} &>> tmp || echo "Timeout" >> tmp
            ${pkgs.uutils-coreutils-noprefix}/bin/tail -c 4096 tmp > $out
        '');