# 🚠 My infra

[![CI](https://git.mndn.fr/camille/infra/actions/workflows/ci.yaml/badge.svg)](https://git.mndn.fr/camille/infra/actions?workflow=ci.yaml) [![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://builtwithnix.org)

This repository contains the configurations of my machines using NixOS and `lon`.

## 🗂 Layout

- `nixos/`: modules imported by every host. Each is guarded by the option it configures, so it only takes effect where that option is on; [`nixos/README.md`](nixos/README.md) lists the hosts concerned. `base` holds what all hosts share.
- `hosts/<name>/`: one folder per machine, every file and folder in it imported.
  - `default.nix`: what the machine is for and its addresses.
  - `hardware.nix` and `disko.nix`: the machine itself (boot, disks, drivers), so new hardware only means new versions of these.
  - one folder per service it runs.
- `pkgs/`: packages of my own, `lib/`: helpers (module discovery, DNS zones from nginx virtual hosts), `patches/`: patches applied to inputs, `scripts/`: maintenance scripts.
- `inputs.nix` and `lon.lock`: the pinned inputs; `secrets.nix`: the agenix recipients.

A host's `networking.addresses` is a plain value in its `default.nix`, with no reference to `pkgs`, `config` or `lib`. The other hosts read it as `hosts.<name>` from that file alone, without evaluating the host.

## ❄ About [NixOS](https://nixos.org)

NixOS is a Linux distribution based on the Nix/[Lix](https://lix.systems/) package manager. It allows fully reproducible builds and a declarative configuration style, using a functional langage called Nix.

## 📌 About [`lon`](https://github.com/nikstur/lon)

`lon` is a simple and convenient dependency pinning for Nix, that enables the use of other Nix projects, flake or not.

## 💡 Inspiration

This project is clearly inspired by [JulienMalka/snowfield](https://github.com/JulienMalka/snowfield).
