let 
  langs = [
    {name = "English"; percent = 90;}
    {name = "Spanish"; percent = 100;}
    {name = "Catalan"; percent = 100;}
  ];

  gen = x: ''
  <div class="lang-box">
      <p class="info-title">${x.name}</p>
      <span class="percent"><div style="width: ${toString x.percent}%;"></div></span>
  </div>
  '';
in
''
 <div class="language padding-top-bg">
            <h1 class="heading-primary-white">Language</h1>
            <div class="info-box padding-top-sm">
                ${builtins.concatStringsSep "" (map gen langs)}
            </div>
        </div>
''