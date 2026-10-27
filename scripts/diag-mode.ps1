. F:\project\design-library\scripts\uia-lib.ps1
$w = Focus-App 'ChatGPT'
Dump-Names $w @('Button','MenuItem','ComboBox','SplitButton') | Select -First 80
Save-Shot 'codex' '_chatgpt-state' @{ app='tmp'; notes='diagnostic' }