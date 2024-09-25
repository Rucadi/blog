let
    utils = import ../nixutils {};
    name = "Ruben Cano Diaz";
    title = "Software and Hardware engineer";
    photo = (utils.file2base64 ../images/profile.jpg).htmlImage;
in
''
<div class="profile">
    <div class="profile-img">
        ${photo}
    </div>
    <h1 class="name">${name}</h1>
    <p class="title">${title}</p>
</div>
''