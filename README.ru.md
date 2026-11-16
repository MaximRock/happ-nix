# happ-nix

Nix-флейк с пакетом [Happ](https://github.com/Happ-proxy/happ-desktop) —
прокси-клиента на базе Xray (VLESS/VMess/Trojan/Shadowsocks) — и NixOS-модулем
для него.

Пакет распаковывает официальный Linux `.deb` с bundled Qt. Репозиторий не
связан с проектом Happ.

## NixOS-модуль

```nix
{
  inputs.happ-nix.url = "github:MaximRock/happ-nix";
  inputs.happ-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    { nixpkgs, happ-nix, ... }:
    {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        modules = [
          happ-nix.nixosModules.default
          {
            services.happ.enable = true;
            services.happ.tunMode.enable = true;
            services.happ.forceXwayland = true;
          }
        ];
      };
    };
}
```

Модуль устанавливает Happ, создаёт root-сервис `happd` и симлинк
`/var/lib/dbus/machine-id`, который нужен для HWID.

### Опции

| Опция | По умолчанию | Описание |
| --- | --- | --- |
| `services.happ.enable` | `false` | Установить Happ и сервис `happd`. |
| `services.happ.package` | сборка из `happ.nix` | Используемый пакет Happ. |
| `services.happ.forceXwayland` | `false` | Сборка с `QT_QPA_PLATFORM=xcb`, без Wayland-плагинов. |
| `services.happ.forceSoftwareRendering` | `false` | Сборка с software-рендерингом Qt/OpenGL. |
| `services.happ.tunMode.enable` | `false` | Поддержка TUN (модуль `tun`, loose `rp_filter`, trusted interface). |
| `services.happ.tunMode.interface` | `"tun0"` | Имя TUN-интерфейса. |

`forceXwayland` и `forceSoftwareRendering` влияют только на пакет по
умолчанию; при переопределении `services.happ.package` они игнорируются.

Одновременно может работать только один `happd`: он занимает `/tmp/happd.sock`
и TUN-интерфейс, поэтому второй экземпляр настраивать нельзя.

## Пакет без NixOS

```sh
nix build github:MaximRock/happ-nix
./result/bin/happ
```

## Обновления

Пакет фиксирует официальный `.deb` по версии и SRI-хешу. Еженедельный GitHub
Action запускает `scripts/update.sh`, собирает результат и открывает pull
request.

Обновление существующего input'а:

```sh
nix flake update happ-nix
```

Затем пересоберите систему. Если upstream изменит layout `.deb`, сборка
упадёт, а не создаст молча сломанный wrapper.

## Лицензия

Код упаковки и NixOS-модуль распространяются под GPL-3.0 (см.
[LICENSE](LICENSE)). Бинарники Happ — проприетарное ПО проекта Happ; этот
репозиторий лишь переупаковывает официальный релиз.
