

let 
  array_of_education = [
    {
      year = "2020";
      title = "Master in Innovation and Research in Informatics: HPC";
      school = "Polytechnic University of Catalonia (UPC)";
      where = "Catalonia, Spain";
    }
    {
      year = "2018";
      title = "Bachelor of Informatics Engineering: Hardware";
      school = "Polytechnic University of Catalonia (UPC)";
      where = "Catalonia, Spain";
    }
    {
      year = "2017";
      title = "Summer School in Computer Vision and Chinese";
      school = "Beihang University (Beijing University of Aeronautics and Astronautics)";
      where = "Beijing, China";
    }
  ];

  gen = x: ''
  <div class="info-box padding-top-sm">
      <div class="info">${x.year}</div>
      <div class="info-title">${x.title}</div>
      <div class="info">${x.school}</div>
      <div class="info">${x.where}</div>
  </div>
  '';
in
''
<div class="education padding-top-bg">
  <h1 class="heading-primary-white">Education</h1>
  ${builtins.concatStringsSep "" (map gen array_of_education)}
</div>
''
        