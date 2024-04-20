   GET = let 
        HTMX = "https://unpkg.com/htmx.org@1.9.11";
        content = ''
            int main()
            {
                __builtin_printf("Hello World\\n");
            }
        '';
        language = "cpp";
        theme = "vs-dark";
        
        monaco_style = ''
            .monaco {
            width: 100%;
            height: 50vh;
            border: 1px solid black;
            box-sizing: border-box;
            }
        '';

        button_style = ''
        .runcode {
            font-size: 20px; 
            padding: 10px 20px; 
            background-color: #4CAF50; 
            color: white; 
            border: none; 
            border-radius: 4px; 
            cursor: pointer;
            float: right;
        }
        '';
    
    in ''
        <!doctype html>
        <html lang="en">
        <head>
            <style>${button_style}</style>
            <style>${monaco_style}</style>
            <script src="${HTMX}"></script>
            <script type="module">
                import * as monaco from 'https://cdn.jsdelivr.net/npm/monaco-editor@0.39.0/+esm';
                window.editor = monaco.editor.create(
                    document.querySelector('.monaco'),{
                            value: `${content}`,
                            language: '${language}',
                            theme: '${theme}',
                            automaticLayout: true
                    }
                );
            </script>
            
            <link href="https://cdn.jsdelivr.net/npm/vscode-codicons@0.0.17/dist/codicon.min.css" rel="stylesheet">
        </head>

        <body> 
            <div class="monaco"></div>
            <button class="runcode" hx-vals='js:{code: editor.getValue()}' hx-get="/compile" hx-swap="innerHTML" hx-trigger="click" hx-target="#output">
            Run code!
            </button> 
            <div style="clear:both;"></div>
            <pre id="output"></pre>
        </body>
        </html>
    '';
