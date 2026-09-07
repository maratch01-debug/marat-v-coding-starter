---
name: video-montage
description: Use when you need to turn a raw video into a vertical Reel/Short — overlay a text hook, fit to 1080x1920, burn subtitles, add music, put a PiP proof-screen, or batch-render many clips. Local ffmpeg montage, no video editor or apps. Keywords рилс shorts хук вертикаль 1080x1920 субтитры озвучка музыка монтаж ffmpeg.
---

# video-montage — монтаж рилсов через ffmpeg

## Overview
Превращаю сырое видео в готовый вертикальный рилс командой, без монтажёра и приложений.
Ядро — наложить текст-хук и привести к 1080×1920. Всё локально на ffmpeg (нужен full build
с whisper, libass, drawtext). Проверено рендером на реальном видео.

## Когда использовать
- «Наложи хук на это видео», «сделай из этого рилс», «впиши в вертикаль».
- Нужны субтитры, музыка, пруф-скрин в углу, пачка роликов сразу.
- НЕ для сложного нелинейного монтажа (много склеек по кадрам, цветокор, кеинг) — это в CapCut.

## Честный предел (проговаривать вслух)
Я **не вижу кадр глазами** — ставлю текст по координатам. Если хук налезет на лицо/важный
объект — скажи «сдвинь вниз», меняю `-p bottom` или Y. Один вариант хука = один рендер
(превью без рендера не покажу).

## Хук на видео — главный рецепт (готовый скрипт)
```bash
bash skills/video-montage/render-hook.sh -i clip.mp4 -t $'КАК Я СОБРАЛ\nЗАВОД НА ИИ' -d 6
```
Опции: `-m fill` (обрезать под кадр, обычное видео) / `-m fit` (вписать с полями, скринкаст —
не режет UI); `-p top|center|bottom`; `-s 72` размер шрифта; `-d 6` секунд держать хук;
`-f путь.ttf` свой шрифт. Скрипт сам приводит к 1080×1920, рисует тёмную плашку + акцентную
полосу + белый капс, плавно убирает хук к концу, проверяет что файл не битый.
Кириллица и переносы (`$'...\n...'`) поддержаны через textfile (не ломается на спецсимволах).

## Быстрый справочник (остальные операции)

**Вписать в вертикаль без хука.** fill (обрезать):
```bash
ffmpeg -i in.mp4 -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1" -c:a copy out.mp4
```
fit (скринкаст, поля фоном, UI не режется): `scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=0x0D0D0D`

**Субтитры из готового .srt** (прожечь в стиле рилса, капс, ключевое акцентным цветом — правится в .ass):
```bash
ffmpeg -i in.mp4 -vf "subtitles=subs.srt:force_style='Fontname=Arial,Bold=1,FontSize=16,PrimaryColour=&H00FFFFFF,Outline=2,Alignment=2,MarginV=120'" -c:a copy out.mp4
```
Авто-субтитры из речи: ffmpeg собран с `--enable-whisper` → фильтр `whisper` (нужен ggml-модель
.bin, скачать один раз). Пока модели нет — субтитры из присланного .srt.

**Музыка под видео** (подмешать фон, приглушить, нормализовать громкость к −14 LUFS):
```bash
ffmpeg -i in.mp4 -i music.mp3 -filter_complex "[1:a]volume=0.25[bg];[0:a][bg]amix=inputs=2:duration=first[a];[a]loudnorm=I=-14:TP=-1[ao]" -map 0:v -map "[ao]" -c:v copy -shortest out.mp4
```

**PiP пруф-скрин в углу** (показать скрин оплаты/результата поверх видео, первые N сек):
```bash
ffmpeg -i in.mp4 -i proof.png -filter_complex "[1]scale=520:-1[p];[0][p]overlay=x=W-w-40:y=H-h-40:enable='between(t,0,6)'" -c:a copy out.mp4
```

**Пачкой (батч).** Список видео+хуков → цикл по render-hook.sh:
```bash
while IFS='|' read -r vid hook; do
  bash skills/video-montage/render-hook.sh -i "$vid" -t "$hook" -o "${vid%.*}_reel.mp4"
done < hooks.txt   # строки формата: clip1.mp4|ТЕКСТ ХУКА
```

## Фирменные дефолты в скрипте (меняй под свой бренд)
Акцент `0xF5761E` (оранжевый), тёмная плашка `black@0.55`, фон полей `0x0D0D0D`, шрифт Arial
Bold (для Montserrat/Bebas-look — положи .ttf и передай `-f`). Открой `render-hook.sh` и
поменяй `ACCENT`/`PLATE` на свои — совпадёт с твоей дизайн-системой (скилл **design-system**).

## Частые ошибки
- **`Cannot read file '/tmp/...'`** — нативный Windows-ffmpeg не читает MSYS-пути и пути с `:`.
  Текст/шрифт — относительным именем или с экранированным `C\:/...` (в скрипте уже сделано).
- **Хук налез на лицо** — я не вижу кадр; сменить `-p bottom` или уменьшить `-s`.
- **Скринкаст обрезало по краям** — использовать `-m fit`, не `fill`.
- **Тихий звук после склейки** — прогнать через `loudnorm=I=-14`.

## Связи
- Хук-конвейер — часть контент-завода: скилл **content-factory**.
- Репликация чужих виралок целиком — скилл **viral-remix**.
