# install-logan.ps1 - ONE command install for Logan CLI on Windows
# Author: Yuval Avidani (YUV.AI) - https://yuv.ai
#
# Public install (no clone required):
#   irm https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.ps1 | iex
#
# Optional env:
#   $env:LOGAN_HOME
#   $env:LOGAN_INSTALL_SRC
#   $env:LOGAN_INSTALL_NO_START = "1"
#   $env:CI = "1"   # skip auto-start
#
$ErrorActionPreference = "Stop"

$LoganRepo = if ($env:LOGAN_REPO) { $env:LOGAN_REPO } else { "https://github.com/hoodini/logan-cli.git" }
$LoganRef = if ($env:LOGAN_REF) { $env:LOGAN_REF } else { "main" }
$LoganHome = if ($env:LOGAN_HOME) { $env:LOGAN_HOME } else { Join-Path $env:USERPROFILE ".logan" }
$InstallDir = if ($env:LOGAN_INSTALL_DIR) { $env:LOGAN_INSTALL_DIR } else { Join-Path $LoganHome "src\logan-cli" }
$LocalBin = Join-Path $env:USERPROFILE ".local\bin"
$ManagedBin = Join-Path $LoganHome "bin"
$GitHubRepo = if ($env:GITHUB_REPO) { $env:GITHUB_REPO } else { "hoodini/logan-cli" }

function Write-Log($msg) { Write-Host "==> $msg" }
function Die($msg) { Write-Error "error: $msg"; exit 1 }

function Test-Interactive {
  # irm|iex always redirects stdin - do NOT require !IsInputRedirected.
  # Start when this is a real user session unless CI/NO_START opts out.
  if ($env:LOGAN_INSTALL_NO_START -eq "1") { return $false }
  if ($env:CI -or $env:NONINTERACTIVE) { return $false }
  try {
    return [Environment]::UserInteractive
  } catch {
    return $true
  }
}

function Ensure-Dir($p) {
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

function Add-UserPath($dir) {
  Ensure-Dir $dir
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if (-not $userPath) { $userPath = "" }
  $parts = $userPath -split ";" | Where-Object { $_ -ne "" }
  if ($parts -notcontains $dir) {
    $newPath = ($parts + $dir) -join ";"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Log "Added $dir to user PATH"
  }
  if ($env:Path -notlike "*$dir*") {
    $env:Path = "$dir;$env:Path"
  }
}

function Install-Binary($src, $dest) {
  Ensure-Dir (Split-Path $dest -Parent)
  $tmp = "$dest.new.$PID"
  Copy-Item -Force $src $tmp
  Move-Item -Force $tmp $dest
}

function Ensure-Git {
  if (Get-Command git -ErrorAction SilentlyContinue) { return }
  Write-Log "git missing - trying winget…"
  if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements | Out-Null
  } else {
    Die "git is required. Install Git for Windows, then re-run the one-liner."
  }
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Die "git still missing after install attempt"
  }
}

function Ensure-Rust {
  $cargoHome = Join-Path $env:USERPROFILE ".cargo\bin"
  $env:Path = "$cargoHome;$env:Path"
  if ((Get-Command cargo -ErrorAction SilentlyContinue) -and (Get-Command rustc -ErrorAction SilentlyContinue)) {
    Write-Log "Rust: $(rustc --version)"
    return
  }
  Write-Log "Rust missing - installing rustup…"
  $tmp = Join-Path $env:TEMP "rustup-init.exe"
  Invoke-WebRequest -Uri "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe" -OutFile $tmp
  & $tmp -y --default-toolchain stable
  $env:Path = "$cargoHome;" + [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
  if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Die "cargo still missing after rustup. Open a new PowerShell and re-run."
  }
}

function Ensure-Protoc {
  if ($env:PROTOC -and (Test-Path $env:PROTOC)) {
    Write-Log "protoc: $env:PROTOC"
    return
  }
  if (Get-Command protoc -ErrorAction SilentlyContinue) {
    Write-Log "protoc: $(protoc --version)"
    return
  }
  # Prefer repo-vendored protoc after clone (Unix binary may not run on Windows)
  Write-Log "protoc missing - trying winget/choco, then GitHub zip…"
  if (Get-Command winget -ErrorAction SilentlyContinue) {
    try {
      winget install --id Google.Protobuf -e --accept-source-agreements --accept-package-agreements | Out-Null
    } catch { }
  }
  if (Get-Command choco -ErrorAction SilentlyContinue) {
    try { choco install protoc -y | Out-Null } catch { }
  }
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
  if (Get-Command protoc -ErrorAction SilentlyContinue) {
    Write-Log "protoc: $(protoc --version)"
    return
  }
  # Official protoc release zip (win64)
  $tag = "v28.3"
  $ver = "28.3"
  $url = "https://github.com/protocolbuffers/protobuf/releases/download/$tag/protoc-$ver-win64.zip"
  $tools = Join-Path $LoganHome "tools\protoc"
  Ensure-Dir $tools
  $zip = Join-Path $env:TEMP "protoc-win64.zip"
  try {
    Invoke-WebRequest -Uri $url -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath $tools -Force
  } catch {
    Die "protoc is required to build Logan and could not be installed automatically. Install protoc (https://github.com/protocolbuffers/protobuf/releases) and re-run, or set `$env:PROTOC to protoc.exe. Detail: $_"
  }
  $protocExe = Join-Path $tools "bin\protoc.exe"
  if (-not (Test-Path $protocExe)) {
    Die "protoc download finished but $protocExe is missing. Install protoc manually and re-run."
  }
  $env:PROTOC = $protocExe
  $env:Path = "$(Join-Path $tools 'bin');$env:Path"
  Write-Log "protoc ready: $env:PROTOC"
}

function Try-Prebuilt {
  try {
    $arch = if ([Environment]::Is64BitOperatingSystem) {
      if ($env:PROCESSOR_ARCHITECTURE -match "ARM") { "aarch64" } else { "x86_64" }
    } else { "x86_64" }
    $asset = "logan-windows-$arch.exe"
    $api = "https://api.github.com/repos/$GitHubRepo/releases/latest"
    $rel = Invoke-RestMethod -Uri $api -ErrorAction Stop
    $tag = $rel.tag_name
    if (-not $tag) { return $false }
    $url = "https://github.com/$GitHubRepo/releases/download/$tag/$asset"
    Write-Log "Trying prebuilt $asset @ $tag…"
    Ensure-Dir $ManagedBin
    $dest = Join-Path $ManagedBin "logan.exe"
    Invoke-WebRequest -Uri $url -OutFile "$dest.dl" -ErrorAction Stop
    Move-Item -Force "$dest.dl" $dest
    return $dest
  } catch {
    return $false
  }
}

function Resolve-Repo {
  if ($env:LOGAN_INSTALL_SRC -and (Test-Path (Join-Path $env:LOGAN_INSTALL_SRC "Cargo.toml"))) {
    return (Resolve-Path $env:LOGAN_INSTALL_SRC).Path
  }
  Ensure-Git
  Ensure-Dir (Split-Path $InstallDir -Parent)
  if (Test-Path (Join-Path $InstallDir ".git")) {
    Write-Log "Updating $InstallDir…"
    git -C $InstallDir fetch --depth 1 origin $LoganRef 2>$null
    git -C $InstallDir checkout $LoganRef 2>$null
    git -C $InstallDir pull --ff-only origin $LoganRef 2>$null
  } else {
    Write-Log "Cloning $LoganRepo → $InstallDir…"
    if (Test-Path $InstallDir) { Remove-Item -Recurse -Force $InstallDir }
    git clone --depth 1 --branch $LoganRef $LoganRepo $InstallDir
  }
  if (-not (Test-Path (Join-Path $InstallDir "Cargo.toml"))) {
    Die "clone failed: no Cargo.toml"
  }
  return $InstallDir
}

function Seed-Config {
  Ensure-Dir (Join-Path $LoganHome "memory")
  Ensure-Dir (Join-Path $LoganHome "hooks\bin")
  Ensure-Dir (Join-Path $LoganHome "skills")
  Ensure-Dir (Join-Path $LoganHome "sessions")
  $config = Join-Path $LoganHome "config.toml"
  if (-not (Test-Path $config)) {
    @"
# Logan config - Yuval Avidani (YUV.AI)
# Auth: logan login  OR  `$env:XAI_API_KEY=...

[memory]
enabled = true

[memory.session]
save_on_end = true

[memory.dream]
enabled = true

[memory.initial_injection]
enabled = true

[compat.claude]
skills = true
rules = true
agents = true
mcps = true
hooks = true

[compat.cursor]
skills = true
rules = true
agents = true
mcps = true
hooks = true

[cli]
installer = "internal"
use_leader = false

[ui]
permission_mode = "always-approve"
yolo = false
"@ | Set-Content -Path $config -Encoding UTF8
    Write-Log "Wrote $config"
  }
}

# ---------- main ----------
Write-Log "Logan one-command install (YUV.AI) - Windows"
Write-Log "home: $LoganHome"
Add-UserPath $LocalBin
Ensure-Dir $LoganHome
Ensure-Dir $ManagedBin

$binSrc = $null
$pre = Try-Prebuilt
if ($pre -and (Test-Path $pre)) {
  $binSrc = $pre
} else {
  $repo = Resolve-Repo
  $release = Join-Path $repo "target\release\logan.exe"
  if ((Test-Path $release) -and $env:LOGAN_FORCE_BUILD -ne "1") {
    Write-Log "Using existing build $release"
    $binSrc = $release
  } else {
    Ensure-Rust
    Ensure-Protoc
    Write-Log "Building Logan release (can take several minutes)…"
    Push-Location $repo
    try {
      cargo build -p xai-grok-pager-bin --release
    } finally {
      Pop-Location
    }
    if (-not (Test-Path $release)) {
      Die "build finished but $release missing. If cargo failed on protoc, install protoc or set `$env:PROTOC."
    }
    $binSrc = $release
  }
}

$destLocal = Join-Path $LocalBin "logan.exe"
$destManaged = Join-Path $ManagedBin "logan.exe"
Install-Binary $binSrc $destLocal
Install-Binary $binSrc $destManaged
# Also install bare name for Git Bash users who expect `logan`
$destLocalBare = Join-Path $LocalBin "logan"
try { Copy-Item -Force $destLocal $destLocalBare } catch { }

Seed-Config

Write-Log "Installed:"
& $destLocal --version
if ($LASTEXITCODE -ne 0) { Die "logan --version failed" }
Write-Log "  $destLocal"
Write-Log "  $destManaged"

Write-Host ""
Write-Host "Next:"
Write-Host "  logan login"
Write-Host "  logan"
Write-Host "  /stats          # after a turn"
Write-Host "  /context deep"
Write-Host ""

if (Test-Interactive) {
  Write-Log "Starting Logan…"
  # irm|iex leaves stdin as a pipe. A bare `& $destLocal` inherits that pipe and
  # the TUI can exit immediately. Start-Process with default UseShellExecute
  # gives Logan a free console (same idea as bash `logan </dev/tty`).
  $cwd = (Get-Location).Path
  Start-Process -FilePath $destLocal -WorkingDirectory $cwd -Wait
} else {
  Write-Log "Non-interactive install complete. Run: $destLocal"
}
