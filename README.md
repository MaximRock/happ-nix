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
| `services.happ.tunMode.enable` | `false` | Enable TUN support (`tun` module, loose `rp_filter`, trusted interface). |
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

## License

The packaging code and NixOS module are licensed under GPL-3.0 (see
[LICENSE](LICENSE)). The bundled Happ binaries are proprietary software
distributed by the Happ project; this repository only repackages the official
release.
