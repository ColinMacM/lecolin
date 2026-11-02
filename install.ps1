# Native Windows installer (PowerShell). For the full zsh setup, use WSL and
# run ./install.sh inside it instead; this script covers what runs natively:
#   - installs Neovim, Git, ripgrep, zoxide, Node LTS (winget) and pay-respects
#   - links nvim config  -> %LOCALAPPDATA%\nvim   (directory junction: no admin needed)
#   - loads windows\profile.ps1 from your PowerShell $PROFILE (zoxide + `f`)
# kitty and zsh have no native Windows builds.
# Safe to re-run. An existing nvim config is renamed to nvim.pre-lecolin.<timestamp>.
#   -NoTools   only do the linking
param([switch]$NoTools)
$ErrorActionPreference = 'Stop'

$Repo  = $PSScriptRoot
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

if (-not $NoTools) {
    if (-not (Have winget)) { throw 'winget not found. Install "App Installer" from the Microsoft Store.' }
    $pkgs = @{
        nvim   = 'Neovim.Neovim'
        git    = 'Git.Git'
        rg     = 'BurntSushi.ripgrep.MSVC'
        zoxide = 'ajeetdsouza.zoxide'
        node   = 'OpenJS.NodeJS.LTS'
    }
    foreach ($cmd in $pkgs.Keys) {
        if (Have $cmd) { Write-Host "ok       $cmd" }
        else { winget install --id $pkgs[$cmd] -e --accept-source-agreements --accept-package-agreements }
    }
    if (-not (Have pay-respects)) {
        Invoke-RestMethod https://raw.githubusercontent.com/iffse/pay-respects/main/install.ps1 | Invoke-Expression
    }
    # Pick up PATH changes made by the installers in this session.
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

# nvim config -> %LOCALAPPDATA%\nvim
$src = Join-Path $Repo 'nvim'
$dst = Join-Path $env:LOCALAPPDATA 'nvim'
$item = Get-Item $dst -Force -ErrorAction SilentlyContinue
if ($item -and $item.LinkType -and ($item.Target -eq $src -or $item.Target -contains $src)) {
    Write-Host "ok       $dst"
} else {
    if ($item) {
        Rename-Item $dst "$dst.pre-lecolin.$Stamp"
        Write-Host "backup   $dst -> $dst.pre-lecolin.$Stamp"
    }
    New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
    Write-Host "linked   $dst -> $src"
}

# PowerShell profile: dot-source the repo's profile (no symlink needed).
$line = ". `"$(Join-Path $Repo 'windows\profile.ps1')`""
New-Item -ItemType Directory -Force -Path (Split-Path $PROFILE) | Out-Null
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE | Out-Null }
if (Select-String -Path $PROFILE -SimpleMatch $line -Quiet) {
    Write-Host "ok       $PROFILE"
} else {
    Add-Content -Path $PROFILE -Value "`n# lecolin dotfiles`n$line"
    Write-Host "updated  $PROFILE"
}

Write-Host "`nDone. Open a new terminal; nvim installs its plugins on first launch."
