let 
  langs = [
    {name = "English"; level = "Professional";}
    {name = "Spanish"; level = "Native";}
    {name = "Catalan"; level = "Native";}
  ];

  gen = x: ''
  <div class="lang-box">
      <div>
          <p class="info-title">${x.name}</p>
          <div class="info">${x.level}</div>
      </div>
  </div>
  '';
in
''
 <div class="language padding-top-bg">
            <h1 class="heading-primary-white">Languages</h1>
            <div class="info-box padding-top-sm">
                ${builtins.concatStringsSep "" (map gen langs)}
            </div>
        </div>
''