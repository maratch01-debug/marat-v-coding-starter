#!/usr/bin/env bash
# Старт в одну команду (macOS/Linux): клонирует шаблон + ставит 4 надстройки Claude Code.
# Запуск:
#   curl -fsSL https://raw.githubusercontent.com/maratch01-debug/marat-v-coding-starter/main/install.sh | bash
set +e
repo="https://github.com/maratch01-debug/marat-v-coding-starter.git"
dir="marat-v-coding-starter"

if [ -d "$dir" ]; then
  echo "Папка '$dir' уже есть рядом - перейди в другое место (или переименуй/удали её) и запусти команду снова."
  exit 0
fi

echo "== 1/2 Клонирую шаблон =="
git clone "$repo" "$dir"
cd "$dir"

echo ""
echo "== 2/2 Ставлю 4 надстройки Claude Code (память, браузер, методология + связка контента) =="
bash install-extras.sh

echo ""
echo "ГОТОВО."
echo "Перейди в папку:  cd $dir"
echo "Открой её в VS Code, открой Claude Code и напиши любую фразу - начнётся знакомство."
echo "Если ставил надстройки - перезапусти Claude Code, чтобы они подхватились."
