# 🛠️  Proof-of-Care — Developer Environment (v0)

> One machine-file to rule them all.  
> Follow the table, run the quick health-check, and you can compile every part of the stack—Solidity, Rust / RISC Zero, Python agents, and the OP-Stack DevNet—without version whiplash.

| Tool / SDK | Required Version (July 2025) | Install Command / Notes |
|------------|-----------------------------|-------------------------|
| **Rust** | `stable 1.79` | `rustup default stable` |
| **RISC Zero zkVM tool-chain** | `risc0-zkvm 2.1.0` | `cargo install cargo-risczero` |
| **Node.js** | `v20.x LTS` | via [`asdf`](https://asdf-vm.com) → `asdf install nodejs 20.11.0` |
| **Foundry** (Solidity) | nightly `forge 0.2.8` | `curl -L https://foundry.paradigm.xyz | bash && foundryup` |
| **Solidity compiler** | bundled `0.8.24` (auto-pulled by Foundry) | — |
| **Python (agent scripts)** | `3.11` | `pyenv install 3.11.6` |
| **GitHub CLI** | `>= 2.50` | `brew install gh` / `choco install gh` |
| **Docker Desktop** | `24.x` (buildkit enabled) | download from docker.com (needed for OP-Stack DevNet) |

```bash
## Quick health-check  — run in any shell
rustc --version
cargo risczero --version
forge --version
node -v
python --version
docker -v