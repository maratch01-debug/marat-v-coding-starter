# Старт в одну команду (Windows): клонирует шаблон + ставит 4 надстройки Claude Code.
# Запуск (вставь целиком в PowerShell):
#   irm https://raw.githubusercontent.com/maratch01-debug/marat-v-coding-starter/main/install.ps1 | iex
$ErrorActionPreference = "Continue"
$repo = "https://github.com/maratch01-debug/marat-v-coding-starter.git"
$dir = "marat-v-coding-starter"

if (Test-Path $dir) {
  Write-Host "Папка '$dir' уже есть рядом - перейди в другое место (или переименуй/удали её) и запусти команду снова." -ForegroundColor Yellow
} else {
  Write-Host "== 1/2 Клонирую шаблон ==" -ForegroundColor Cyan
  git clone $repo $dir

  Set-Location $dir

  Write-Host ""
  Write-Host "== 2/2 Ставлю 4 надстройки Claude Code (память, браузер, методология + связка контента) ==" -ForegroundColor Cyan
  powershell -ExecutionPolicy Bypass -File ".\install-extras.ps1"

  Write-Host ""
  Write-Host "ГОТОВО." -ForegroundColor Green
  Write-Host "Открой папку '$dir' в VS Code, открой Claude Code и напиши любую фразу - начнётся знакомство."
  Write-Host "Если ставил надстройки - перезапусти Claude Code, чтобы они подхватились."
}
