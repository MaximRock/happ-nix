# План продвижения happ-nix

- Статус: [status.md](status.md)
- Дата старта: 2026-11-17
- Рабочая ветка: `main`
- Связанный PR: #1 (`happ-4.8.1`, draft) — вне рамок этого плана.

## Цель

Сделать `happ-nix` заметным и понятным для NixOS-пользователей Happ:
заполнить витрину GitHub, переписать README как лендинг, добавить
скриншот и social preview, оформить стабильный release 4.7.2.

## Решения

- `README.md` — английский, основной; `README.ru.md` — русский.
- Используем реальный скриншот Happ с очищенными личными данными и
  social preview на его основе.
- Release `happ-4.7.2` создаём сейчас, из существующего тега.
- Каждый этап запускается по отдельной команде пользователя.
- Работаем в `main`; PR #1 не мерджим и не меняем.

## Вне рамок

- Мердж и постоянная установка 4.8.1.
- Изменения пакета, модуля, flake и хоста.
- Покупка звёзд, star-for-star, спам в сообществах.
- Публикация в nixpkgs.
- Release 4.8.1 (отложен до решения по PR #1).

## Ограничения

- В скриншоте не должно быть секретов: подписок, серверов, email, HWID,
  токенов и других личных данных.
- Не менять тег `happ-4.7.2` и не переписывать историю.
- Проект остаётся неофициальной упаковкой; это должно быть явно указано.
- Код и текущая система не меняются; CI должен остаться зелёным.

## Этап 0. Каркас документации

Задачи:

1. Переключиться на `main` и проверить чистоту.
2. Создать `docs/promotion/PLAN.md`.
3. Создать `docs/promotion/status.md` с чек-боксами.
4. Проверить, что файлы не игнорируются.
5. Закоммитить и запушить каркас.

Проверка:

```sh
git check-ignore -v docs/promotion/PLAN.md docs/promotion/status.md
git status --short
```

**Gate:** оба файла существуют, не игнорируются, коммит в `main`,
CI не сломан.

## Этап 1. GitHub-витрина

Description:

```text
Unofficial Happ (Xray/VLESS) client for NixOS: flake, NixOS module,
TUN, HWID and Wayland fixes, automated updates.
```

Topics:

```text
nix nixos nix-flake nixos-module happ happ-proxy xray vless vmess
trojan shadowsocks vpn proxy tun wayland hwid desktop-client
```

Действия:

1. Заполнить description и topics.
2. Проверить About через `gh repo view`.
3. Закрепить репозиторий в профиле (вручную или через API).
4. Homepage пока не заполнять.

Команда для metadata (проверить поддержку флагов в текущем `gh`):

```sh
gh repo edit MaximRock/happ-nix \
  --description "Unofficial Happ (Xray/VLESS) client for NixOS: flake, NixOS module, TUN, HWID and Wayland fixes, automated updates." \
  --add-topic nix --add-topic nixos --add-topic nix-flake \
  --add-topic nixos-module --add-topic happ --add-topic happ-proxy \
  --add-topic xray --add-topic vless --add-topic vmess \
  --add-topic trojan --add-topic shadowsocks --add-topic vpn \
  --add-topic proxy --add-topic tun --add-topic wayland \
  --add-topic hwid --add-topic desktop-client
```

**Gate:** описание и topics видны в About; репозиторий закреплён.

## Этап 2. Скриншот и social preview

Файлы:

```text
assets/happ-nixos.png
assets/social-preview.png
```

Скриншот:

1. Открыть Happ с демо-профилем или пустым списком серверов.
2. Не показывать экран About с версией, чтобы не привязывать картинку
   к 4.7.2 или 4.8.1.
3. Скрыть или размыть подписки, серверы, email, HWID, токены.
4. Снять окно (Wayland: `grim` + `slurp`; X11: `import`/`flameshot`).
5. Обрезать, привести к ширине ~1200 px, убрать метаданные.
6. Показать скриншот пользователю на утверждение.

Social preview:

- 1280×640, PNG или JPG, меньше 1 MB.
- Тёмный фон, название `happ-nix`, подзаголовок `Happ for NixOS`.
- Плашки: `flake`, `TUN`, `Wayland fix`, `auto-updates`.
- Обязательная пометка `unofficial`.
- Не использовать логотип Happ как официальный; допустим скриншот окна.

Команды очистки (адаптировать под доступные инструменты):

```sh
magick assets/happ-nixos.png -strip -resize 1200x assets/happ-nixos.png
magick assets/social-preview.png -strip assets/social-preview.png
```

**Gate:** оба файла готовы, личные данные отсутствуют, пользователь
утвердил скриншот.

## Этап 3. Release 4.7.2

Создать release из существующего тега `happ-4.7.2`:

```sh
gh release create happ-4.7.2 \
  --repo MaximRock/happ-nix \
  --title "Happ 4.7.2 for NixOS" \
  --notes-file /tmp/happ-4.7.2-release-notes.md
```

Структура notes:

```md
Happ 4.7.2 packaged for NixOS.

Included:
- official Linux x64 .deb repacked with bundled Qt;
- NixOS module with happd, HWID symlink and optional TUN;
- XWayland workaround for wlroots;
- weekly automated update workflow and CI.

Install:
(add flake input and services.happ example)

Verified:
- CI;
- VM smoke test;
- NixOS 26.05 host build.

Links:
- English README
- Русский README

Notes:
- unofficial packaging, not affiliated with Happ;
- bundled Happ binaries are proprietary.
```

Проверка:

```sh
gh release view happ-4.7.2 --repo MaximRock/happ-nix
```

**Gate:** release опубликован, помечен Latest, ссылки работают.
Release 4.8.1 не создаём.

## Этап 4. README

Переименование:

```sh
git mv README.md README.ru.md
git mv README.en.md README.md
```

Обновить языковые ссылки:

- в `README.md`: `[Русский](README.ru.md) | **English**`;
- в `README.ru.md`: `**Русский** | [English](README.md)`.

Структура обоих README:

1. Языковой переключатель и бейджи: CI, license, latest release.
2. Одна фраза о проекте.
3. Скриншот `assets/happ-nixos.png`.
4. Why / Features.
5. Quick start для NixOS-флейка.
6. Package only с честной оговоркой про TUN/HWID и root-сервис.
7. Options.
8. How it works: `happd`, `/tmp/happd.sock`, `machine-id`, TUN.
9. Updates: weekly workflow, stable-only, `nix flake update`.
10. Compatibility / tested: NixOS 26.05, x86_64-linux, Wayland через
    XWayland, проприетарные бинарники.
11. Troubleshooting: пустой HWID, падение Wayland, нет TUN-трафика,
    software rendering.
12. Отличия от MrShitFox/happ-nixos.
13. Благодарности и лицензия.
14. Мягкая строка в конце: «If this saved you time, star the repo».

Бейджи:

```md
[![CI](https://github.com/MaximRock/happ-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/MaximRock/happ-nix/actions/workflows/ci.yml)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/MaximRock/happ-nix)](https://github.com/MaximRock/happ-nix/releases/latest)
```

**Gate:** английский README основной, русский синхронизирован,
изображения и ссылки работают.

## Этап 5. Публикация и проверка

1. Обновить `docs/promotion/status.md`.
2. Закоммитить README, assets и status.
3. Push в `main`.
4. Дождаться зелёного CI.
5. Загрузить social preview: Settings → Social preview.
6. Проверить, что репозиторий закреплён.
7. Проверить README в светлой/тёмной теме и на мобильном.
8. Проверить ссылки, бейджи, release и topics.
9. Убедиться, что в assets нет секретов и метаданных.
10. Отметить все применимые пункты в `status.md`.

**Gate:** опубликованный репозиторий выглядит как готовый проект,
CI зелёный, все применимые чек-боксы закрыты.

## Этап 6. Отложено

- Release `happ-4.8.1` после мерджа PR #1 и реального теста
  TUN/DNS/IPv6.
- Возможная публикация в NixOS Wiki / awesome-nix — отдельный план.

## Риски

- **Секреты на скриншоте.** Использовать демо-профиль, размывать данные,
  проверять изображение перед коммитом.
- **Кэш social preview.** Telegram/Discord могут показывать старую картинку;
  проверять после публикации, при необходимости обновлять.
- **Старый README в архиве тега.** Release создаётся из существующего тега
  `happ-4.7.2`; release notes ссылаются на актуальный `main`.
- **Конфликт с PR #1.** PR меняет только `happ.nix`; README/docs его не
  затрагивают.
- **Погоня за звёздами.** Никаких ботов и обменов; только польза и
  нормальные публикации.

## Правила ведения статуса

- После каждого этапа: `[ ]` → `[x]`, дата, коммит или URL.
- Ручные шаги (закрепление, social preview) помечать `manual`.
- Заблокированный шаг оставлять `[ ]` с пометкой `blocked: причина`.
- `status.md` — источник истины о прогрессе; `PLAN.md` — детали.

## Оценка

- Этап 0: 10–15 минут.
- Этап 1: 10–15 минут.
- Этап 2: 45–60 минут.
- Этап 3: 15–20 минут.
- Этап 4: 1–2 часа.
- Этап 5: 20–30 минут.
