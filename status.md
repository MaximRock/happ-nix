# Happ Nix — статус миграции

Обновлено: 2026-11-16. Источник: [PLAN.md](PLAN.md).

**Выполнено: этапы 0–2 из 0–7.**

## Обзор

- [x] Этап 0. Подготовка и точка отката
- [x] Этап 1. Репозиторий и пакет
- [x] Этап 2. NixOS-модуль, CI и обновления
- [ ] Этап 3. Публикация
- [ ] Этап 4. VM smoke-тест
- [ ] Этап 5. Staging dotfiles без switch
- [ ] Этап 6. Cutover
- [ ] Этап 7. Cleanup и проверка на хосте

---

## Этап 0. Подготовка и точка отката — выполнено

- [x] Этап завершён (gate пройден).
- [x] Зафиксировать текущую генерацию и store path старого `happd`.
  - generation 310, `/nix/store/bc6ha1zn201r754h3ca965ycqrq6shag-nixos-system-nixos-26.05.20261102.7dcdd87`;
  - старый `happd`: active, PID 1146, `/nix/store/fzc25kzpw0rrnjd0d3i6fm08f5jpk560-happ-4.7.2`.
- [x] Сделать резерв вне репозитория (`/home/max/happ-legacy-backup-20261116-181116/`):
  - [x] `modules/nixos/networking/happ.nix`;
  - [x] `pkgs/happ/`;
  - [x] `lib/overlays.nix`;
  - [x] `home/common/packages.nix`;
  - [x] `flake.nix`, `flake.lock`;
  - [x] сведения о текущей системе и `happd`.
- [x] Учесть, что Happ-файлы в dotfiles в состоянии intent-to-add: обычный `git restore` их содержимое не вернёт.
- [x] Старый `happd` не останавливать.
- [x] Gate: резерв создан, текущий Happ работает.

---

## Этап 1. Репозиторий и пакет — выполнено

- [x] Этап завершён (gate пройден).
- [x] Создать `PLAN.md`, `flake.nix`, `flake.lock`, `happ.nix`, `.gitignore`.
- [x] `happ.nix`: официальный `.deb` Happ.
- [x] `happ.nix`: bundled Qt, как в текущем пакете.
- [x] `happ.nix`: `makeWrapper` и runtime deps (`coreutils`, `lsb-release`, `net-tools`, `iproute2`, `iptables`, `procps`).
- [x] `happ.nix`: `$out/bin/happ`, `$out/bin/Happ`, `$out/bin/happd`.
- [x] `happ.nix`: desktop `Exec` → `$out/bin/happ`.
- [x] `happ.nix`: `forceXwayland` — `QT_QPA_PLATFORM=xcb` + удаление Wayland-плагинов.
- [x] `happ.nix`: `forceSoftwareRendering` — software Qt/GL.
- [x] `happ.nix`: проверки наличия `Happ`, `happd`, `Happ.desktop`.
- [x] `happ.nix`: `meta.license` не указывать (бинарник проприетарный, чтобы не требовать `allowUnfree`).
- [x] `flake.nix`: input `nixpkgs` = `nixos-unstable`.
- [x] `flake.nix`: outputs `packages.{default,happ}`, `apps.default`, `overlays.default`, `checks.{happ,happ-xwayland,happ-software}`.
- [x] `flake.nix`: `nixosModules.default` (выполнено на Этапе 2).
- [x] `nix flake lock`.
- [x] `nix flake check --show-trace` — all checks passed.
- [x] `nix build .#happ --no-link` — `/nix/store/1sadc2lzc2qvd225fmy1kq9pnc7z07i9-happ-4.7.2`.
- [x] Gate: пакет собирается, бинарники и desktop на месте.

---

## Этап 2. NixOS-модуль, CI и обновления — выполнено

- [x] Этап завершён (gate пройден).
- [x] `happ-module.nix`: `services.happ.enable`.
- [x] `happ-module.nix`: `services.happ.package`.
- [x] `happ-module.nix`: `forceXwayland`, `forceSoftwareRendering`.
- [x] `happ-module.nix`: `tunMode.enable`, `tunMode.interface`.
- [x] `happ-module.nix`: HWID-симлинк `/var/lib/dbus/machine-id`.
- [x] `happ-module.nix`: `happd` root-сервис.
- [x] `happ-module.nix`: TUN — `tun`, `checkReversePath = "loose"`, trusted interface.
- [x] `flake.nix`: добавлен `nixosModules.default`.
- [x] `scripts/update.sh`: latest release Happ.
- [x] `scripts/update.sh`: URL `.deb`.
- [x] `scripts/update.sh`: SRI-хеш.
- [x] `scripts/update.sh`: обновление `version`/`hash`.
- [x] `scripts/update.sh`: `nix build .#happ`.
- [x] `.github/workflows/ci.yml`: `nix flake check`, `bash -n scripts/update.sh`.
- [x] `.github/workflows/update.yml`: weekly/manual, updater, сборка, PR.
- [x] `README.md`, `README.ru.md`, `LICENSE` GPL-3.0.
- [x] Gate: `nix flake check` проходит; updater на 4.7.2 отвечает «already up to date».

---

## Этап 3. Публикация

- [ ] Этап завершён (gate пройден).
- [ ] Показать сообщение коммита и запросить подтверждение.
- [ ] Создать начальный коммит.
- [ ] Опубликовать:

```sh
gh repo create MaximRock/happ-nix --public --source=. --remote=origin --push
```

- [ ] Дождаться зелёного CI.
- [ ] Gate: репозиторий опубликован, CI зелёный. Старый Happ на хосте не тронут.

---

## Этап 4. VM smoke-тест

- [ ] Этап завершён (gate пройден).
- [ ] Минимальная NixOS VM с новым модулем из опубликованного `happ-nix`.
- [ ] `nixpkgs` 26.05, как в dotfiles.
- [ ] `services.happ.enable = true`, `tunMode.enable = true`, `forceXwayland = true`.
- [ ] X11/Xvfb для GUI.
- [ ] Без sops, GPU и полного host-конфига.
- [ ] Проверить: `happd` active и `/tmp/happd.sock`.
- [ ] Проверить: запуск `happ` и окно под X11/Xvfb.
- [ ] Проверить: desktop и иконку.
- [ ] Проверить: symlink `machine-id`.
- [ ] Проверить: `tun`, `rp_filter`, trusted interface.
- [ ] Проверить: `QT_QPA_PLATFORM=xcb` и PATH/wrapper.
- [ ] Проверить: отсутствие missing libs.
- [ ] Gate: VM прошла. Только после этого трогать dotfiles.

---

## Этап 5. Staging dotfiles без switch

- [ ] Этап завершён (gate пройден).
- [ ] Добавить input `happ-nix` с `nixpkgs.follows`.
- [ ] Сохранить старый модуль как `happ-legacy.nix`.
- [ ] Заменить `happ.nix` на обёртку нового модуля.
- [ ] Убрать `pkgs.happ` из `home/common/packages.nix`.
- [ ] `pkgs/happ` и overlay пока оставить на диске.
- [ ] Выполнить `nix flake lock`.
- [ ] Выполнить `nixos-rebuild build --flake .#nixos`.
- [ ] Не делать `switch` и `test`.
- [ ] Gate: staging-сборка прошла, в `result` есть новый `happ`, `happd` и desktop, rollback-генерация известна.

---

## Этап 6. Cutover

- [ ] Этап завершён (gate пройден).
- [ ] Один `nixos-rebuild switch` через `pkexec`.
- [ ] Старый `happd` останавливается, новый запускается; старая генерация сохраняется.
- [ ] Проверить сервис и GUI.
- [ ] При сбое — `switch --rollback`; старый Happ возвращается.
- [ ] Gate: `happd` active, GUI запускается, HWID и TUN работают.

---

## Этап 7. Cleanup и проверка на хосте

- [ ] Этап завершён (gate пройден).
- [ ] Удалить `happ-legacy.nix`, `pkgs/happ`, overlay-блок.
- [ ] Финальный `nixos-rebuild build`.
- [ ] Второй switch не нужен: удаляются только неиспользуемые файлы.
- [ ] Проверить: `happd`, журнал.
- [ ] Проверить: `machine-id`.
- [ ] Проверить: `tun`, `rp_filter`.
- [ ] Проверить: desktop/icon.
- [ ] Проверить: запуск Happ, подписку/HWID, TUN.
- [ ] Внешний резерв удалить после подтверждения стабильности.
- [ ] Коммит dotfiles — только после отдельного подтверждения.
- [ ] Gate: Happ работает из нового пакета, старые файлы удалены, ссылок нет.

---

## Будущие обновления

- [ ] Weekly workflow обновляет `happ.nix` и открывает PR.
- [ ] PR собирается внутри workflow; при изменении layout `.deb` сборка падает.
- [ ] После мержа в dotfiles: `nix flake update happ-nix`, `nixos-rebuild build --flake .#nixos`.
- [ ] Затем обычный switch с rollback-генерацией.
