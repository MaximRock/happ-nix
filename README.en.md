[Русский](README.md) | **English**

# happ-nix

Nix flake that packages [Happ](https://github.com/Happ-proxy/happ-desktop) — a
proxy client powered by Xray (VLESS/VMess/Trojan/Shadowsocks) — and provides a
NixOS module for it.

The package repacks the official Linux `.deb` release with its bundled Qt
libraries. It is not affiliated with the Happ project.

## NixOS module

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

The module installs Happ, creates the root `happd` service and the
`/var/lib/dbus/machine-id` symlink used for the HWID.

### Options

| Option | Default | Description |
| --- | --- | --- |
| `services.happ.enable` | `false` | Install Happ and the `happd` service. |
| `services.happ.package` | built from `happ.nix` | Happ package to use. |
| `services.happ.forceXwayland` | `false` | Build with `QT_QPA_PLATFORM=xcb`, no Wayland plugins. |
| `services.happ.forceSoftwareRendering` | `false` | Build with software Qt/OpenGL rendering. |
| `services.happ.tunMode.enable` | `false` | Enable TUN support (`tun` module, loose reverse-path filter, trusted interface). |
| `services.happ.tunMode.interface` | `"tun0"` | TUN interface name. |

`forceXwayland` and `forceSoftwareRendering` only affect the default package;
they are ignored when `services.happ.package` is overridden.

Only one `happd` can run at a time: it owns port-independent resources
`/tmp/happd.sock` and the TUN interface, so do not configure a second instance.

## Package without NixOS

```sh
nix build github:MaximRock/happ-nix
./result/bin/happ
```

## Updates

The package pins the official `.deb` by version and SRI hash. A weekly GitHub
Action runs `scripts/update.sh`, builds the result and opens a pull request.

To update an existing flake input:

```sh
nix flake update happ-nix
```

Then rebuild your system. If the upstream `.deb` layout changes, the package
build fails instead of silently producing a broken wrapper.

## Acknowledgements

Inspired by [MrShitFox/happ-nixos](https://github.com/MrShitFox/happ-nixos), an
unofficial NixOS module for Happ by MrShitFox. Thanks for the work and for the
key findings that got Happ running:

- **HWID:** Happ reads its identifier from `/var/lib/dbus/machine-id`, but
  dbus-broker does not create that file, so without a symlink to
  `/etc/machine-id` the HWID stays empty.
- **Wayland/wlroots:** the bundled Qt6 Wayland plugins can silently crash the
  client; `forceXwayland` (`QT_QPA_PLATFORM=xcb` and removal of the Wayland
  plugins) works around it.
- **TUN:** the loose reverse-path filter, trusted interface and root `happd`
  service needed to launch the cores.

This is an independent flake, not a fork of `happ-nixos`. Differences:

- `happ-nix` is a standalone flake with `nixosModules.default` and
  `nixpkgs.follows`; `happ-nixos` is cloned into `/etc/nixos` and imported via
  `happ-module.nix`.
- Happ runs directly from `/nix/store` (`$out/bin/happ`, `$out/bin/happd`) with
  no materialisation under `/opt/happ`.
- TUN mode is an explicit `services.happ.tunMode.enable` option with
  `services.happ.tunMode.interface` for the interface name (in `happ-nixos` it
  is `tunInterface`, and the TUN settings are always active when
  `services.happ.enable` is on).
- The flake provides `packages`/`overlay`/`checks`, CI and a weekly update
  workflow that opens a PR; `happ-nixos` is updated with `git pull` and a
  rebuild.

## License

The packaging code and NixOS module are licensed under GPL-3.0 (see
[LICENSE](LICENSE)). The bundled Happ binaries are proprietary software
distributed by the Happ project; this repository only repackages the official
release.
