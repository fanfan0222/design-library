# refresh-demo.ps1 - rebuild index.json + demo/screens-data.js and sync self-contained preview copy
$R = 'F:\project\design-library'; $P = 'C:\Users\fanfan\design-library-preview\demo'
python "$R\scripts\build_demo.py"
if (Test-Path $P) { Remove-Item -Recurse -Force $P }
New-Item -ItemType Directory -Force $P | Out-Null
Copy-Item "$R\demo\index.html","$R\demo\screens-data.js" $P
[IO.File]::WriteAllText("$P\config.js", "window.IMG_BASE = './';`nwindow.FULL_BASE = 'file:///F:/project/design-library/';`n", (New-Object Text.UTF8Encoding $false))
Get-ChildItem "$R\apps" -Recurse -Filter shot-ai.jpg | % { $rel = $_.FullName.Substring($R.Length+1); $dst = Join-Path $P $rel; New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null; Copy-Item $_.FullName $dst }
"preview synced: $P"