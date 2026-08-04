# AGENTS.md

## Purpose

A static LuaRocks rock server for **WoW-U** (accessibility automation that lets disabled players play WoW with friends). This repo hosts rockspec files and manifest indices so `luarocks` can resolve and download the `wow-dev-core` package, whose actual Lua source lives in [WoW-U/core-luarock](https://github.com/WoW-U/core-luarock). It is a plain static file host (e.g. GitHub Pages) — **not** a full LuaRocks server (no `luarocks-admin`, no rock-building, no upload API).

## Stack

Pure static files. No build tooling, no generator, no CI. Manifests are hand-authored Lua tables; `index.html` is hand-authored HTML. Everything is edited by hand and committed directly.

## Structure

- `index.html` — human-browsable rock index page (lists versions; also links to `.zip` manifest archives that **do not exist** — dead/aspirational links, not a bug to "fix" without asking)
- `manifest` — canonical LuaRocks manifest (Lua table: `commands`, `modules`, `repository`), lists every published `wow-dev-core` version, all entries `arch = "rockspec"`
- `manifest-5.1`, `manifest-5.2`, `manifest-5.3`, `manifest-5.4` — per-Lua-version manifest variants, hand-duplicated from `manifest`. Currently `manifest`/`5.1`/`5.2`/`5.3` are identical; `5.4` is missing the `1.0.1-1` entry (a known drift — see Gotchas).
- `wow-dev-core-<version>-<revision>.rockspec` — one file per release (currently `1.0.0-1` through `1.0.6-1`). Each pins `source.url` to `git+ssh://git@github.com/WoW-U/core-luarock.git` at `tag = "v<version>"`.

## Publishing a new version (manual runbook)

There is no automation — follow these steps in order every time `core-luarock` cuts a new release:

1. **Author the rockspec**: create `wow-dev-core-<major.minor.patch>-<rockspec-revision>.rockspec` (copy the most recent one as a template). Set `version`, `source.tag = "v<major.minor.patch>"`, and update `build.modules` to match core-luarock's current module layout exactly (module name → `src/...` path).
2. **Update every manifest**: append the new version entry (`["<version>-<revision>"] = { { arch = "rockspec" } }`) to `manifest` **and** `manifest-5.1`, `manifest-5.2`, `manifest-5.3`, `manifest-5.4`. There is no generator — you must edit all five files by hand, consistently. (Double-check `manifest-5.4` isn't already behind before you start — see Gotchas.)
3. **Update `index.html`**: add the new version to the visible version list.
4. **Commit and push.**

## Naming & versioning conventions

- Package name is fixed: `wow-dev-core`.
- Rockspec filename: `wow-dev-core-<major.minor.patch>-<rockspec-revision>.rockspec`.
- Git tag in `core-luarock`: `v<major.minor.patch>` (no rockspec-revision suffix).
- `rockspec_format = "3.1"` used consistently across all rockspecs — keep new ones on this version.
- `dependencies` / `build_dependencies` currently just pin `lua >= 5.1`; `test_dependencies` is present but empty.

## Dependencies

This repo is purely metadata — it never contains actual Lua source. It is directly downstream of **WoW-U/core-luarock**: every rockspec's `source.url` and `tag` point there, and `build.modules` must be kept in sync with that repo's module layout whenever it changes. If a rockspec's module list and core-luarock's actual files diverge, installs will fail at build time even though the rockspec resolves fine.

## Maintainer gotchas

- **SSH source URL**: `source.url` uses `git+ssh://`, so `luarocks install wow-dev-core` requires SSH access to `core-luarock`. Fine for internal WoW-U use; this is not set up for public/anonymous installs.
- **Manifest drift**: manifests are hand-duplicated per Lua version with no generator. `manifest-5.4` is already missing an entry (`1.0.1-1`) that the other four have — treat any manifest edit as "edit all 5 files," and don't assume they're currently in sync.
- **Broken `.zip` links**: `index.html` links to manifest `.zip` archives that were never actually produced. Known, not yet fixed — don't spend time debugging a "404" here unless asked to actually add the archives.
