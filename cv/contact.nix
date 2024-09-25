let 
  tlf = "+34 627012975";
  mail = "ruben.canodiaz@gmail.com";
  city = "Barcelona";
  country = "Spain";
in
''
<div class="contact padding-top-bg">
            <h1 class="heading-primary-white">Contact</h1>
            <div class="info-box padding-top-sm">
                <div class="info-title">Phone</div>
                <div class="info">
                    <a href="${tlf}">${tlf}</a>
                </div>
            </div>
            <div class="info-box padding-top-sm">
                <div class="info-title">Email</div>
                <div class="info">
                    <a href="mailto:${mail}">${mail}</a>
                </div>
            </div>
            <div class="info-box padding-top-sm">
                <div class="info-title">Address</div>
                <div class="info">${city}, ${country}</div>
            </div>
        </div>
''