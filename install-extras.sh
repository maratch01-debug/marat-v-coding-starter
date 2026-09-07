#!/usr/bin/env bash
# Прокачка Claude Code - 4 надстройки поверх обычной установки (macOS/Linux).
# Запуск: bash install-extras.sh
# Что ставит: память между сессиями, свой браузер, методология-скиллы - бесплатно;
# связка для генерации контента (Higgsfield/HeyGen/ElevenLabs) - нужны свои аккаунты/ключи.
set +e

echo "== 1/3 Бесплатные надстройки =="

echo "  -> плагин claude-mem (память между сессиями)"
claude plugin marketplace add thedotmack/claude-mem
claude plugin install claude-mem@thedotmack

echo "  -> плагин superpowers (методология: план -> критика -> выполнение)"
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install superpowers@claude-plugins-official

echo "  -> agent-browser (свой браузер вместо Playwright, дешевле по токенам)"
npm install -g agent-browser
agent-browser install
claude mcp add -s user agent-browser -- agent-browser mcp --tools core

echo ""
echo "== 2/3 Связка для генерации контента (опционально, нужны свои аккаунты) =="

echo "  -> higgsfield (картинки/видео) - HTTP, OAuth в браузере при первом вызове"
claude mcp add --transport http -s user higgsfield https://mcp.higgsfield.ai/mcp

echo "  -> heygen (говорящий аватар) - HTTP, OAuth в браузере при первом вызове"
claude mcp add --transport http -s user heygen https://mcp.heygen.com/mcp/v1/

if [ -n "$ELEVENLABS_API_KEY" ]; then
  echo "  -> elevenlabs (голос/клонирование) - ключ найден, подключаю"
  claude mcp add -s user elevenlabs -e "ELEVENLABS_API_KEY=$ELEVENLABS_API_KEY" -- uvx elevenlabs-mcp
else
  echo "  ! elevenlabs пропущен: нет ключа. Ключ - на elevenlabs.io (нужен платный тариф с API)."
  echo "    Добавь вручную: claude mcp add -s user elevenlabs -e ELEVENLABS_API_KEY=<ключ> -- uvx elevenlabs-mcp"
fi

echo ""
echo "== 3/3 Готово =="
echo "Перезапусти Claude Code, чтобы всё подхватилось."
echo "Higgsfield и HeyGen спросят логин в браузере при первом обращении к ним - это нормально."
echo "Проверить, что всё встало: claude mcp list"
