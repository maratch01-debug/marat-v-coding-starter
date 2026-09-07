# Прокачка Claude Code — 4 надстройки поверх обычной установки (Windows).
# Запуск: powershell -ExecutionPolicy Bypass -File install-extras.ps1
# Что ставит: память между сессиями, свой браузер, методология-скиллы — бесплатно;
# связка для генерации контента (Higgsfield/HeyGen/ElevenLabs) — нужны свои аккаунты/ключи.
$ErrorActionPreference = "Continue"

Write-Host "== 1/3 Бесплатные надстройки ==" -ForegroundColor Cyan

Write-Host "  -> плагин claude-mem (память между сессиями)"
claude plugin marketplace add thedotmack/claude-mem
claude plugin install claude-mem@thedotmack

Write-Host "  -> плагин superpowers (методология: план -> критика -> выполнение)"
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install superpowers@claude-plugins-official

Write-Host "  -> agent-browser (свой браузер вместо Playwright, дешевле по токенам)"
npm install -g agent-browser
agent-browser install
claude mcp add -s user agent-browser -- agent-browser mcp --tools core

Write-Host ""
Write-Host "== 2/3 Связка для генерации контента (опционально, нужны свои аккаунты) ==" -ForegroundColor Cyan

Write-Host "  -> higgsfield (картинки/видео) - HTTP, OAuth в браузере при первом вызове"
claude mcp add --transport http -s user higgsfield https://mcp.higgsfield.ai/mcp

Write-Host "  -> heygen (говорящий аватар) - HTTP, OAuth в браузере при первом вызове"
claude mcp add --transport http -s user heygen https://mcp.heygen.com/mcp/v1/

if ($env:ELEVENLABS_API_KEY) {
  Write-Host "  -> elevenlabs (голос/клонирование) - ключ найден, подключаю"
  claude mcp add -s user elevenlabs -e "ELEVENLABS_API_KEY=$env:ELEVENLABS_API_KEY" -- uvx elevenlabs-mcp
} else {
  Write-Host "  ! elevenlabs пропущен: нет ключа. Ключ - на elevenlabs.io (нужен платный тариф с API)." -ForegroundColor Yellow
  Write-Host '    Добавь вручную: claude mcp add -s user elevenlabs -e ELEVENLABS_API_KEY=<ключ> -- uvx elevenlabs-mcp' -ForegroundColor Yellow
}

Write-Host ""
Write-Host "== 3/3 Готово ==" -ForegroundColor Cyan
Write-Host "Перезапусти Claude Code, чтобы всё подхватилось."
Write-Host "Higgsfield и HeyGen спросят логин в браузере при первом обращении к ним - это нормально."
Write-Host "Проверить, что всё встало: claude mcp list"
