# Happ Nix — план миграции

## Решения

- Репозиторий: `MaximRock/happ-nix`, публичный.
- Лицензия упаковки/модуля: GPL-3.0.
- Пакет: официальный `.deb`, bundled Qt, x86_64-linux.
- `forceXwayland = true` в dotfiles; `forceSoftwareRendering = false`.
- Обновления: `scripts/update.sh` + weekly GitHub Action с PR.
- Миграция dotfiles: staged build, VM-тест, затем атомарный cutover с rollback.
- Старый Happ работает до Этапа 6. Новый на хосте не запускается раньше.
- Два `happd` одновременно невозможны: один systemd-сервис, один сокет
  `/tmp/happd.sock`, один TUN.
- Dotfiles не коммитить без отдельного подтверждения.

## Инварианты

- Не запускать `nixos-rebuild test` и `switch` до Этапа 6.
- Не останавливать старый `happd` до cutover.
- Не удалять старые исходники до успешного cutover.
- Все switch-операции выполнять через `pkexec`.
- Секреты в публичный репозиторий не попадают.

---

## Этап 0. Подготовка и точка отката — выполнено

- Точка отката: `/home/max/happ-legacy-backup-20261116-181116/`.
- Система: generation 310, `/nix/store/bc6ha1zn201r754h3ca965ycqrq6shag-nixos-system-nixos-26.05.20261102.7dcdd87`.
- Старый `happd`: active, PID 1146, `/nix/store/fzc25kzpw0rrnjd0d3i6fm08f5jpk560-happ-4.7.2`.
- [x] Зафиксировать текущую генерацию и store path старого `happd`.
- [x] Сделать резерв вне репозитория:
  - `modules/nixos/networking/happ.nix`;
  - `pkgs/happ/`;
  - `lib/overlays.nix`;
  - `home/common/packages.nix`;
  - `flake.nix`, `flake.lock`;
  - сведения о текущей системе и `happd`.
- [x] Учесть, что Happ-файлы в dotfiles в состоянии intent-to-add:
  обычный `git restore` их содержимое не вернёт.
- [x] Старый `happd` не останавливать.

**Gate:** резерв создан, текущий Happ работает.

---

## Этап 1. Репозиторий и пакет — выполнено

**Цель:** собрать новый пакет Happ, не трогая dotfiles.

Создать:

```text
/home/max/projects/happ-nix/
├── PLAN.md
├── flake.nix
├── flake.lock
├── happ.nix
├── .gitignore
```

`happ.nix`:
- официальный `.deb` Happ;
- bundled Qt, как в текущем пакете;
- `makeWrapper` и runtime deps: `coreutils`, `lsb-release`, `net-tools`,
  `iproute2`, `iptables`, `procps`;
- `$out/bin/happ`, `$out/bin/Happ`, `$out/bin/happd`;
- desktop `Exec` → `$out/bin/happ`;
- `forceXwayland`: `QT_QPA_PLATFORM=xcb` + удаление Wayland-плагинов;
- `forceSoftwareRendering`: software Qt/GL;
- проверки наличия `Happ`, `happd`, `Happ.desktop`;
- `meta.license` не указывать: бинарник проприетарный, чтобы не требовать
  `allowUnfree` у пользователей.

`flake.nix`:
- input `nixpkgs` = `nixos-unstable`;
- outputs: `packages.{default,happ}`, `apps.default`, `overlays.default`,
  `checks.{happ,happ-xwayland,happ-software}`;
- `nixosModules.default` добавить на Этапе 2.

Проверка:

```sh
nix flake lock
nix flake check --show-trace
nix build .#happ --no-link
```

**Gate:** пакет собирается, бинарники и desktop на месте.

**Статус:** `nix flake check --show-trace` — all checks passed; `nix build .#happ`
— `/nix/store/1sadc2lzc2qvd225fmy1kq9pnc7z07i9-happ-4.7.2`. Default wrapper:
PATH/`SSL_CERT_FILE`/`XKB_CONFIG_ROOT`; desktop/icon на месте. Xwayland:
`QT_QPA_PLATFORM=xcb`, Wayland-плагины удалены. Software:
`QT_QUICK_BACKEND`/`QSG_RHI_BACKEND`/`LIBGL_ALWAYS_SOFTWARE`. Старый `happd`
остаётся active; dotfiles не тронуты.

---

## Этап 2. NixOS-модуль, CI и обновления — выполнено

- `happ-module.nix`:
  - `services.happ.enable`;
  - `services.happ.package`;
  - `forceXwayland`, `forceSoftwareRendering`;
  - `tunMode.enable`, `tunMode.interface`;
  - HWID-симлинк `/var/lib/dbus/machine-id`;
  - `happd` root-сервис;
  - TUN: `tun`, `checkReversePath = "loose"`, trusted interface.
- `flake.nix`: добавить `nixosModules.default`.
- `scripts/update.sh`:
  - latest release Happ;
  - URL `.deb`;
  - SRI-хеш;
  - обновление `version`/`hash`;
  - `nix build .#happ`.
- `.github/workflows/ci.yml`: `nix flake check`, `bash -n scripts/update.sh`.
- `.github/workflows/update.yml`: weekly/manual, updater, сборка, PR.
- `README.md`, `README.ru.md`, `LICENSE` GPL-3.0.

**Gate:** `nix flake check` проходит; updater на 4.7.2 отвечает «already up to date».

**Статус:** `happ-module.nix` — `services.happ.{enable,package,forceXwayland,
forceSoftwareRendering}`, `tunMode.{enable,interface}`; `happd` через
`${package}/bin/happd` (root, wrapper PATH); HWID-симлинк; TUN (`tun`, loose
`rp_filter`, trusted `tun0`). Модуль проверен evaluation-тестом: ExecStart,
tmpfiles, firewall, kernelModules, systemPackages корректны. `nixosModules.default`
добавлен. `scripts/update.sh` протестирован на переходе 0.0.0 → 4.7.2 (version,
SRI-хеш, сборка) и на повторном запуске — «Happ is already up to date: 4.7.2».
CI (`nix flake check`, `bash -n`) и weekly/manual update workflow с PR;
yamllint чистый. README.md, README.ru.md, LICENSE GPL-3.0 добавлены.
`nix flake check` — all checks passed; dotfiles и старый `happd` не тронуты.

---

## Этап 3. Публикация — выполнено

- Показать сообщение коммита и запросить подтверждение.
- Создать начальный коммит.
- Опубликовать:

```sh
gh repo create MaximRock/happ-nix --public --source=. --remote=origin --push
```

- Дождаться зелёного CI.

**Gate:** репозиторий опубликован, CI зелёный. Старый Happ на хосте не тронут.

**Статус:** начальный коммит `a77e9a4`; репозиторий
https://github.com/MaximRock/happ-nix опубликован (`--public`, remote `origin`);
CI run `43897912746` — success. Dotfiles и старый `happd` не тронуты.

---

## Этап 4. VM smoke-тест — выполнено

- Минимальная NixOS VM с новым модулем из опубликованного `happ-nix`.
- `nixpkgs` 26.05, как в dotfiles.
- `services.happ.enable = true`, `tunMode.enable = true`, `forceXwayland = true`.
- X11/Xvfb для GUI.
- Без sops, GPU и полного host-конфига.

Проверить:
- `happd` active и `/tmp/happd.sock`;
- запуск `happ` и окно под X11/Xvfb;
- desktop и иконку;
- symlink `machine-id`;
- `tun`, `rp_filter`, trusted interface;
- `QT_QPA_PLATFORM=xcb` и PATH/wrapper;
- отсутствие missing libs.

VM не проверяет реальную подписку/HWID, настоящий TUN-трафик, Niri/Wayland и GPU.
Это проверяется после cutover.

**Gate:** VM прошла. Только после этого трогать dotfiles.

**Статус:** `nixosTest` `happ-vm-smoke` (VM-флейк в `/tmp/opencode/happ-vm-test`)
— passed. Nixpkgs `7dcdd87` (26.05), опубликованный `happ-nix` `784d595`,
Xvfb + Mesa llvmpipe. `happd` active (root) и `/tmp/happd.sock`; окно
«Happ 4.7.2 (341)» 1000x640; desktop/icon; HWID-симлинк; `tun` и
`/dev/net/tun`; rpfilter `--loose` и trusted `tun0`; wrapper
`QT_QPA_PLATFORM=xcb`, runtime PATH и `SSL_CERT_FILE`; missing libs нет.
Реальная подписка/HWID, TUN-трафик, Niri/Wayland и GPU не проверялись.
Dotfiles и старый `happd` не тронуты.

---

## Этап 5. Staging dotfiles без switch

- Добавить input `happ-nix` с `nixpkgs.follows`.
- Сохранить старый модуль как `happ-legacy.nix`.
- Заменить `happ.nix` на обёртку нового модуля.
- Убрать `pkgs.happ` из `home/common/packages.nix`.
- `pkgs/happ` и overlay пока оставить на диске.
- Выполнить:

```sh
nix flake lock
nixos-rebuild build --flake .#nixos
```

- **Не делать `switch` и `test`.**

**Gate:** staging-сборка прошла, в `result` есть новый `happ`, `happd` и desktop,
rollback-генерация известна.

---

## Этап 6. Cutover

- Один `nixos-rebuild switch` через `pkexec`.
- Старый `happd` останавливается, новый запускается; старая генерация сохраняется.
- Проверить сервис и GUI.
- При сбое — `switch --rollback`; старый Happ возвращается.

**Gate:** `happd` active, GUI запускается, HWID и TUN работают.

---

## Этап 7. Cleanup и проверка на хосте

- Удалить `happ-legacy.nix`, `pkgs/happ`, overlay-блок.
- Финальный `nixos-rebuild build`.
- Второй switch не нужен: удаляются только неиспользуемые файлы.
- Проверить:
  - `happd`, журнал;
  - `machine-id`;
  - `tun`, `rp_filter`;
  - desktop/icon;
  - запуск Happ, подписку/HWID, TUN.
- Внешний резерв удалить после подтверждения стабильности.
- Коммит dotfiles — только после отдельного подтверждения.

**Gate:** Happ работает из нового пакета, старые файлы удалены, ссылок нет.

---

## Будущие обновления

1. Weekly workflow обновляет `happ.nix` и открывает PR.
2. PR собирается внутри workflow; при изменении layout `.deb` сборка падает.
3. После мержа в dotfiles:

```sh
nix flake update happ-nix
nixos-rebuild build --flake .#nixos
```

4. Затем обычный switch с rollback-генерацией.
