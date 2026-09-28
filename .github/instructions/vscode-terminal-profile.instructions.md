---
description: "Use when changing VS Code integrated terminal settings, especially terminal.integrated.defaultProfile or terminal profile definitions."
applyTo: "**/.vscode/settings.json"
---
# VS Code Terminal Profile Settings

- Set the OS-specific `terminal.integrated.defaultProfile.<platform>` key (`windows`, `linux`, or `osx`); do not use a generic `terminal.integrated.defaultProfile` key.
- The selected profile name must match an entry under `terminal.integrated.profiles.<platform>` or a profile VS Code detects on that platform.
- Do not infer a user's preferred shell from the CI runner. This repository's GitHub Actions jobs run on Ubuntu, while workspace settings may be used on another OS.
- If PowerShell blocks an npm CLI script such as `npx.ps1`, use its Windows command shim (for example, `npx.cmd`) instead of changing the machine's execution policy.
- Preserve existing settings and profile definitions. Do not add machine-specific executable paths or choose a shell when the requested profile is unclear; ask which installed profile to use.
- Keep terminal profile changes in `.vscode/settings.json`. Do not change Terraform or CI commands as a side effect of a terminal setting request.