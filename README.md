# Logan (`logan`)

**Logan** is a terminal-based AI coding agent CLI by
**[Yuval Avidani](https://yuv.ai)** (YUV.AI) - AI Builder & Speaker.

Forked from [xAI Grok Build](https://github.com/xai-org/grok-build) (Apache-2.0).

It runs as a full-screen TUI that understands your codebase, edits files,
executes shell commands, searches the web, and manages long-running tasks -
interactively, headlessly for scripting/CI, or embedded in editors via the
Agent Client Protocol (ACP).

## Author

**Yuval Avidani** - AI Builder & Speaker (YUV.AI)

| | |
| --- | --- |
| Web | [yuv.ai](https://yuv.ai) |
| Linktree | [linktr.ee/yuvai](https://linktr.ee/yuvai) |
| X | [@yuvalav](https://x.com/yuvalav) |
| Instagram | [@yuval_770](https://instagram.com/yuval_770) |
| Facebook | [@yuval.avidani](https://facebook.com/yuval.avidani) |
| GitHub | [@hoodini](https://github.com/hoodini) |
| TikTok | [@yuval.ai](https://tiktok.com/@yuval.ai) |

> **Attribution:** Based on Grok Build by SpaceXAI / xAI.
> See [NOTICE](NOTICE) and [LICENSE](LICENSE) (Apache License 2.0).
> Logan itself is authored and maintained by Yuval Avidani (YUV.AI).

---

## Status of this fork

| Surface | State |
| --- | --- |
| Product name | **Logan** by YUV.AI |
| CLI binary | **`logan`** |
| Config home | **`~/.logan`** (override with `LOGAN_HOME`) |
| System config | `/etc/logan` (Unix) |
| Internal crate names | Still `xai-grok-*` for now (build graph intact) |
| Upstream auto-update / xAI install CDN | Still present - disable or rewire before shipping |

---

## Building from source

Requirements:

- **Rust** - toolchain is pinned by [`rust-toolchain.toml`](rust-toolchain.toml);
  `rustup` installs it on first build.
- **protoc** - resolves [`bin/protoc`](bin/protoc) (dotslash) or `$PROTOC` / `PATH`.
- macOS and Linux are the supported build hosts.

```sh
cargo run -p xai-grok-pager-bin              # build + launch the TUI
cargo build -p xai-grok-pager-bin --release  # release binary: target/release/logan
cargo check -p xai-grok-pager-bin            # fast validation
```

```sh
./target/release/logan --version
```

On first launch the original Grok Build auth flow may open a browser for xAI
credentials. You will likely want to rewire auth and model providers for Logan.

Config lives under `~/.logan/` (for example `~/.logan/config.toml`).

---

## Repository layout

| Path | Contents |
| --- | --- |
| `crates/codegen/xai-grok-pager-bin` | Composition root; builds the `logan` binary |
| `crates/codegen/xai-grok-pager` | The TUI |
| `crates/codegen/xai-grok-shell` | Agent runtime + leader/stdio/headless entry points |
| `crates/codegen/xai-grok-tools` | Tool implementations |
| `crates/codegen/xai-grok-workspace` | Host filesystem, VCS, execution, checkpoints |
| `third_party/` | Vendored upstream source (Mermaid diagram stack) |

The root `Cargo.toml` is generated upstream - prefer editing per-crate
`Cargo.toml` files when possible.

---

## Development

```sh
cargo check -p <crate>        # target specific crates; full workspace is slow
cargo test -p xai-grok-config
cargo clippy -p <crate>
cargo fmt --all
```

---

## License

First-party fork changes are by **Yuval Avidani (YUV.AI)**.

Upstream Grok Build code remains under the **Apache License, Version 2.0** -
see [`LICENSE`](LICENSE). Copyright for upstream code remains with SpaceXAI as
stated in that file.

This fork keeps Apache-2.0 compliance: license text preserved, and
[`NOTICE`](NOTICE) records both the original work and Logan authorship.

Third-party and vendored code remains under its original licenses - see
[`THIRD-PARTY-NOTICES`](THIRD-PARTY-NOTICES).
