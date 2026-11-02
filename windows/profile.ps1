# PowerShell equivalent of the interactive bits of zsh/.zshrc.
# Loaded from $PROFILE by install.ps1.

# zoxide: smarter cd (`z <dir>`, `zi` for interactive).
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# pay-respects: type `f` after a failed command to correct it.
if (Get-Command pay-respects -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (pay-respects pwsh --alias f | Out-String) })
}

# GitHub MCP plugin for Claude Code (reuses gh CLI login).
if (Get-Command gh -ErrorAction SilentlyContinue) {
    $env:GITHUB_PERSONAL_ACCESS_TOKEN = (gh auth token 2>$null)
}

# Tab completion that behaves like zsh's menu.
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
# Fish/zsh-autosuggestions-style inline history suggestions (PSReadLine 2.1+).
try { Set-PSReadLineOption -PredictionSource History } catch {}
