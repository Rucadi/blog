
let 
    url = "https://rucadi.eu/";
    me = "Ruben Cano";
    github = "https://github.com/rucadi";
    twitter = "https://twitter.com/rucadi_dev";
    linkedin = "https://www.linkedin.com/in/rubencanodiaz/";
    email = "ruben.canodiaz@gmail.com";

    articles = "";
    aside = ''
    <aside>
    <div>
        <a href="${url}">
        <img src=imgs/face.png alt="${me}" title="${me}">
        </a>
        <h1>
        <a href="${url}">${me}</a>
        </h1>

        <p>Software engineer</p>

        <nav>
        <ul class="list">
                <li>
                <a target="_self"
                    href="https://rucadi.eu/pages/about.html#about">
                    About
                </a>
                </li>
        </ul>
        </nav>

        <ul class="social">

        <li>
            <a class="sc-github"
            href="${github}"
            target="_blank">
            <i class="fa-brands fa-github"></i>
            </a>
        </li>

        <li>
            <a class="sc-twitter"
            href="https://twitter.com/"
            target="_blank">
            <i class="fa-brands fa-twitter"></i>
            </a>
        </li>
        
        </ul>
    </div>

    </aside>
    '';
in
{
    index.body = ''
    
    
    
    
    ''
}