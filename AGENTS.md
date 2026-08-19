# AGENTS.md

## Purpose

A static LuaRocks rock server for **WoW-U** (accessibility automation that lets disabled players play WoW with friends). This repo hosts rockspec files and manifest indices so `luarocks` can resolve and download the `wow-dev-core` package, whose actual Lua source lives in [WoW-U/core-luarock](https://github.com/WoW-U/core-luarock). It is a plain static file host served via **GitHub Pages at `https://wow-u.github.io/luarocks/`** — **not** a full LuaRocks server (no `luarocks-admin`, no rock-building, no upload API).

## Stack

Pure static files. No build tooling, no generator, no CI. Manifests are hand-authored Lua tables; `index.html` is hand-authored HTML. Everything is edited by hand and committed directly.

## Structure

- `index.html` — human-browsable rock index page (lists versions; also links to `.zip` manifest archives that **do not exist** — dead/aspirational links, not a bug to "fix" without asking)
- `manifest` — canonical LuaRocks manifest (Lua table: `commands`, `modules`, `repository`), lists every published `wow-dev-core` version, all entries `arch = "rockspec"`
- `manifest-5.1`, `manifest-5.2`, `manifest-5.3`, `manifest-5.4` — per-Lua-version manifest variants, hand-duplicated from `manifest`. Currently `manifest`/`5.1`/`5.2`/`5.3` are identical; `5.4` intentionally omits `1.0.1-1` (see Gotchas).
- `wow-dev-core-<version>-<revision>.rockspec` — one file per release (currently `1.0.0-1` through `1.0.7-1`). Each pins `source.url` to `git+https://github.com/WoW-U/core-luarock.git` at `tag = "v<version>"`.

## Publishing a new version (manual runbook)

There is no automation — follow these steps in order every time `core-luarock` cuts a new release:

1. **Author the rockspec**: create `wow-dev-core-<major.minor.patch>-<rockspec-revision>.rockspec` (copy the most recent one as a template). Set `version`, `source.tag = "v<major.minor.patch>"`, and update `build.modules` to match core-luarock's current module layout exactly (module name → `src/...` path). Use `source.url = "git+https://github.com/WoW-U/core-luarock.git"` (HTTPS, not SSH).
2. **Update every manifest**: append the new version entry (`["<version>-<revision>"] = { { arch = "rockspec" } }`) to `manifest` **and** `manifest-5.1`, `manifest-5.2`, `manifest-5.3`, `manifest-5.4`. There is no generator — you must edit all five files by hand, consistently. (Double-check `manifest-5.4` isn't already behind before you start — see Gotchas.)
3. **Update `index.html`**: add the new version to the visible version list.
4. **Commit and push.**

## Naming & versioning conventions

- Package name is fixed: `wow-dev-core`.
- Rockspec filename: `wow-dev-core-<major.minor.patch>-<rockspec-revision>.rockspec`.
- Git tag in `core-luarock`: `v<major.minor.patch>` (no rockspec-revision suffix).
- `rockspec_format = "3.1"` used consistently across all rockspecs — keep new ones on this version.
- `dependencies` / `build_dependencies` pin `lua >= 5.1`; from `1.0.7-1` onwards, `test_dependencies` uses `busted`.

## Dependencies

This repo is purely metadata — it never contains actual Lua source. It is directly downstream of **WoW-U/core-luarock**: every rockspec's `source.url` and `tag` point there, and `build.modules` must be kept in sync with that repo's module layout whenever it changes. If a rockspec's module list and core-luarock's actual files diverge, installs will fail at build time even though the rockspec resolves fine.

## Agent publishing runbook

> Read this section once, then follow it exactly. The rest of the file is background.

**Consumers install with:**
```
luarocks install wow-dev-core --only-server=https://wow-u.github.io/luarocks/
# fallback server: https://raw.githubusercontent.com/WoW-U/luarocks/main/
```

### Pre-flight (do first, stop if any fail)

- [ ] Confirm the `v<version>` tag is pushed and public on `WoW-U/core-luarock`. A tag not yet public = broken installs for every consumer the moment you publish.
- [ ] Confirm `build.modules` in your new rockspec matches core-luarock's actual `src/` layout for that tag. Divergence causes build-time failure even though the rockspec resolves fine.

### File changes (all required, in order)

1. Create `wow-dev-core-<version>-<rev>.rockspec` — copy the most recent rockspec as template. Set `version`, `source.tag = "v<version>"`, update `build.modules`. `source.url` must be `git+https://…`, never `git+ssh://`.
2. Append `["<version>-<rev>"] = { { arch = "rockspec" } }` to `manifest`, `manifest-5.1`, `manifest-5.2`, `manifest-5.3`. For `manifest-5.4`: omit the entry if the rockspec declares `lua … < 5.4`.
3. Add the version to `index.html`.
4. **BOM check before committing**: every manifest file's first three bytes must NOT be `EF BB BF`. PowerShell UTF-8 default writes a BOM. Write with `New-Object System.Text.UTF8Encoding $false`. Do NOT validate with `loadfile` — it silently skips BOMs and gives a false pass.
5. Stage by filename (`git add manifest manifest-5.1 manifest-5.2 manifest-5.3 manifest-5.4 wow-dev-core-<version>-<rev>.rockspec index.html`), commit, push.
6. Never add `.nojekyll` — it switches Pages to a raw artifact deploy that breaks the deploy step, leaving the old build live with no error visible on push.

### Post-push verification (required — do not skip)

- Watch the `pages-build-deployment` workflow run in GitHub Actions. If it fails: fix the root cause and push again. **Do not re-run an older successful workflow run** — that republishes stale content.
- Fetch the live manifest and confirm the new version appears:
  ```
  curl -s https://wow-u.github.io/luarocks/manifest | grep "<version>-<rev>"
  ```
- Run a real install (the only proof that counts):
  ```
  luarocks install wow-dev-core --only-server=https://wow-u.github.io/luarocks/ --tree /tmp/verify-<version>
  ```
  Expected: installs the new version, places expected module files. A dry manifest check is not sufficient.

### Known historical defect (do not touch)

- `1.0.2-1` rockspec points at `tag = "v1.0.1"` (no `v1.0.2` tag in core-luarock). Leave it.

---

## Maintainer gotchas

- **HTTPS source URL**: `source.url` uses `git+https://` (public, no SSH key required). All rockspecs use this. Do not revert to `git+ssh://`.
- **Manifest drift**: manifests are hand-duplicated per Lua version with no generator. `manifest-5.4` **intentionally** omits `1.0.1-1` — the `1.0.1-1` rockspec declares `lua >= 5.1, < 5.4`, which excludes Lua 5.4, so its absence is correct LuaRocks behaviour. Do not add it. Treat any manifest edit as "edit all 5 files," and don't assume they're currently in sync.
- **`1.0.2-1` historical defect**: its rockspec points at `tag = "v1.0.1"` (no `v1.0.2` tag exists in core-luarock). Known, unfixed — do not retag or remove it from the manifests.
- **Broken `.zip` links**: `index.html` links to manifest `.zip` archives that were never actually produced. Known, not yet fixed — don't spend time debugging a "404" here unless asked to actually add the archives.
- **GitHub Pages**: repo is served at `https://wow-u.github.io/luarocks/`. Configure luarocks with `luarocks config rocks_servers '{"https://wow-u.github.io/luarocks/"}'`.
- **Manifest files must be UTF-8 without BOM**: PowerShell's default `[System.IO.File]::WriteAllText` with `[System.Text.Encoding]::UTF8` writes a BOM (`EF BB BF`). luarocks fetches manifests as strings and parses them via `load()`, which rejects the BOM with `unexpected symbol near '<\239>'`. Lua's `loadfile` silently skips BOMs, so `assert(loadfile(m))` passes even on a BOM-corrupted file — always verify with a byte check: `[System.IO.File]::ReadAllBytes($f)[0..2]` must be `63 6F 6D` (not `EF BB BF`). Always write manifests with `New-Object System.Text.UTF8Encoding $false`.
- **Do NOT add `.nojekyll`**: this repo builds via Jekyll through GitHub's built-in `pages-build-deployment` workflow. Jekyll correctly serves the extension-less `manifest*` files. Adding `.nojekyll` switches to a raw-upload deploy path that fails at the "Deploy to GitHub Pages" step — confirmed broken on 2026-08-17 from commit `ca163e1` onward. If `.nojekyll` appears again, remove it immediately.
