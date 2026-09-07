#!/usr/bin/env bash
# render-hook.sh — наложить текст-хук на видео и привести к вертикали 1080x1920 (Reels/Shorts).
# Работает через ffmpeg (Windows full build, Git Bash). Кириллица поддержана через textfile.
#
# Использование:
#   ./render-hook.sh -i input.mp4 -t "ТВОЙ ХУК" [опции]
#   ./render-hook.sh -i clip.mov -t $'ПЕРВАЯ СТРОКА\nВТОРАЯ СТРОКА' -m fit -d 6 -o out.mp4
#
# Опции:
#   -i FILE   входное видео (обязательно)
#   -t TEXT   текст хука (обязательно). Перенос строки — реальный \n в $'...'
#   -o FILE   выходной файл (по умолчанию: <вход>_hook.mp4)
#   -d SEC    сколько секунд держать хук на экране (по умолчанию 6)
#   -m MODE   fill = обрезать под кадр (обычное видео) | fit = вписать с полями (скринкаст, не режет UI). По умолчанию fill
#   -p POS    top | center | bottom — где плашка. По умолчанию top
#   -s SIZE   размер шрифта (по умолчанию 72; уменьшай для длинного текста)
#   -f FILE   .ttf шрифта (по умолчанию Arial Bold). Для Montserrat/Bebas — подсунь свой .ttf
set -euo pipefail

IN=""; TEXT=""; OUT=""; DUR=6; MODE=fill; POS=top; FSIZE=72
FONT="C:/Windows/Fonts/arialbd.ttf"
ACCENT="0xF5761E"        # акцентный цвет по умолчанию — поменяй под свой бренд
PLATE="black@0.55"       # тёмная полупрозрачная плашка
FADE="0.5"               # длительность плавного исчезания, сек

while getopts "i:t:o:d:m:p:s:f:" opt; do
  case "$opt" in
    i) IN="$OPTARG" ;;
    t) TEXT="$OPTARG" ;;
    o) OUT="$OPTARG" ;;
    d) DUR="$OPTARG" ;;
    m) MODE="$OPTARG" ;;
    p) POS="$OPTARG" ;;
    s) FSIZE="$OPTARG" ;;
    f) FONT="$OPTARG" ;;
    *) echo "неизвестная опция"; exit 1 ;;
  esac
done

[ -z "$IN" ] && { echo "ОШИБКА: нет -i входного видео"; exit 1; }
[ -z "$TEXT" ] && { echo "ОШИБКА: нет -t текста хука"; exit 1; }
[ -f "$IN" ] || { echo "ОШИБКА: файл не найден: $IN"; exit 1; }
[ -z "$OUT" ] && OUT="${IN%.*}_hook.mp4"

# Текст хука пишем во временный файл В ТЕКУЩЕЙ ПАПКЕ с простым именем.
# Важно: нативный Windows-ffmpeg НЕ читает MSYS-пути (/tmp/...) и пути с двоеточием,
# поэтому берём относительное имя без диска и двоеточий.
TXT_TMP=".hooktext_$$.txt"
printf '%s' "$TEXT" > "$TXT_TMP"
trap 'rm -f "$TXT_TMP"' EXIT

# Экранируем двоеточие в пути шрифта для парсера фильтров ffmpeg (C:/ -> C\:/)
FONT_ESC="${FONT/:/\\:}"

# Приведение к 1080x1920: fill = увеличить и обрезать; fit = вписать и добить полями фона
if [ "$MODE" = "fit" ]; then
  FIT="scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=0x0D0D0D,setsar=1"
else
  FIT="scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1"
fi

# Вертикальная позиция плашки/текста
case "$POS" in
  top)    Y="220" ;;
  center) Y="(h-text_h)/2" ;;
  bottom) Y="h-text_h-260" ;;
  *)      Y="220" ;;
esac

# Плавное исчезание хука в конце: alpha=1 до (DUR-FADE), затем линейно в 0
END=$(awk "BEGIN{print $DUR-$FADE}")
ALPHA="if(lt(t,$END),1,if(lt(t,$DUR),($DUR-t)/$FADE,0))"

# Фильтр: фит -> тёмная плашка (по времени) -> оранжевая вертикальная полоса-акцент -> текст с фейдом
VF="${FIT},\
drawbox=x=0:y=${Y}-40:w=iw:h=text_h_dummy:color=${PLATE}:t=fill:enable='lt(t,$DUR)':replace=1,\
drawtext=fontfile='${FONT_ESC}':textfile='${TXT_TMP}':fontcolor=white:fontsize=${FSIZE}:\
x=90:y=${Y}:line_spacing=16:box=1:boxcolor=${PLATE}:boxborderw=48:\
borderw=0:alpha='${ALPHA}':enable='lt(t,$DUR)',\
drawbox=x=42:y=${Y}-40:w=12:h=200:color=${ACCENT}:t=fill:enable='lt(t,$DUR)'"

# Плашку рисуем через box самого drawtext (подгоняется под текст) — убираем костыльный drawbox с dummy
VF="${FIT},\
drawbox=x=42:y=${Y}-46:w=12:h=210:color=${ACCENT}:t=fill:enable='lt(t,$DUR)',\
drawtext=fontfile='${FONT_ESC}':textfile='${TXT_TMP}':fontcolor=white:fontsize=${FSIZE}:\
x=90:y=${Y}:line_spacing=16:box=1:boxcolor=${PLATE}:boxborderw=44:\
alpha='${ALPHA}':enable='lt(t,$DUR)'"

echo "→ рендер: $IN  →  $OUT   (режим=$MODE, хук=${DUR}с, шрифт=${FSIZE})"
ffmpeg -y -hide_banner -loglevel error -i "$IN" \
  -vf "$VF" \
  -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p \
  -c:a aac -b:a 128k -movflags +faststart \
  "$OUT"

# Пред-полётная проверка: файл валиден и не битый
if ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$OUT" >/dev/null 2>&1; then
  DIM=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$OUT")
  echo "✓ готово: $OUT  ($DIM)"
else
  echo "✗ ОШИБКА: выходной файл битый"; exit 1
fi
