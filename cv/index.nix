let

    profile = import ./profile.nix;
    contact = import ./contact.nix;
    education = import ./education.nix;
    expertise = import ./expertise.nix;
    languages = import ./languages.nix;
    about = import ./about.nix;
    experience = import ./experience.nix;
    side-projects = import ./side-projects.nix;
in
''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CV - Ruben Cano Diaz</title>
    <style>
    ${builtins.readFile ./style.css}
    </style>
</head>
<body>
<div class="resume"  id="resume" >

    <!-- left-side -->

    <div class="left-side">
        ${profile}
        ${contact}
        ${education}
        ${expertise}
        ${languages}
    </div>

    <!-- Right-side -->

    <div class="right-side">
        ${about}
        ${experience}
        ${side-projects}
    </div>
</div>
</body>
</html>
''