<#
.SYNOPSIS
  Siapkan satu PC baru agar bisa menjalankan automation free Instagram likes
  persis seperti di PC utama: skill terinstall, memory terpasang, repo kode
  ter-clone, kredensial git siap.

.DESCRIPTION
  Jalankan di dalam clone repo skill ini:

      git clone https://github.com/ozysparda/skill-free-instagram-likes.git
      cd skill-free-instagram-likes
      powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1

  Yang dilakukan:
    1. Memastikan Git terpasang (opsional pasang lewat winget).
    2. Menginstal skill ke ~/.config/opencode/skills.
    3. Memasang blok memory global di ~/.config/opencode/AGENTS.md
       (blok terpisah: skill-free-instagram-likes) - TIDAK menyentuh blok
       skill lain yang sudah ada.
    4. Clone/update repo kode ozysparda/gh-free-likes.
    5. Menyiapkan kredensial git bila file token GitHub tersedia.

  Token TIDAK pernah disimpan di dalam repo.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
  powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1 -SkipGitInstall -SkipClone
#>
[CmdletBinding()]
param(
  [string]$RepoPath = '',
  [string]$SkillsTarget = '',
  [string]$TokenFile = '',
  [switch]$SkipGitInstall,
  [switch]$SkipClone,
  [switch]$SkipMemory
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Step($msg) { Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "   [OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "   [!] $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "   [X] $msg" -ForegroundColor Red }

Write-Host "==============================================" -ForegroundColor DarkCyan
Write-Host " Bootstrap skill-free-instagram-likes" -ForegroundColor DarkCyan
Write-Host "=============================================="

# ------------------------------------------------------------------ 1. Git ---
Write-Step "Memeriksa Git"
$git = $null
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
  $git = $gitCmd.Source
} elseif (Test-Path 'C:\Program Files\Git\cmd\git.exe') {
  $git = 'C:\Program Files\Git\cmd\git.exe'
}

if ($git) {
  Write-Ok "Git: $git ($((& $git --version)))"
} else {
  Write-Warn "Git belum ditemukan."
  if ($SkipGitInstall) {
    Write-Err "Lewati pemasangan karena -SkipGitInstall. Pasang manual dari https://git-scm.com/download/win"
  } else {
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
      Write-Host "   Memasang Git lewat winget (bisa memakan waktu 1-3 menit)..."
      & winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements | Out-Host
      if (Test-Path 'C:\Program Files\Git\cmd\git.exe') {
        $git = 'C:\Program Files\Git\cmd\git.exe'
        $cur = [Environment]::GetEnvironmentVariable('Path', 'User')
        if ($cur -notlike '*Git\cmd*') {
          [Environment]::SetEnvironmentVariable('Path', $cur.TrimEnd(';') + ';C:\Program Files\Git\cmd', 'User')
          Write-Ok "Git dipasang & 'C:\Program Files\Git\cmd' ditambahkan ke PATH user."
        }
      } else {
        Write-Err "Pemasangan Git lewat winget tidak menghasilkan path yang diharapkan."
      }
    } else {
      Write-Err "winget tidak tersedia. Pasang manual dari https://git-scm.com/download/win"
    }
  }
}

# ------------------------------------------------------------- 2. Skills ---
Write-Step "Menginstal skill"
& (Join-Path $repoRoot 'install.ps1') -Target $SkillsTarget
Write-Ok "Skill siap (buka sesi OpenCode baru agar terdeteksi)."

# ------------------------------------------------------------- 3. Memory ---
if (-not $SkipMemory) {
  Write-Step "Memasang memory global (~/.config/opencode/AGENTS.md)"
  $cfgDir = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $env:USERPROFILE '.config' }
  $ocDir  = Join-Path $cfgDir 'opencode'
  $agents = Join-Path $ocDir 'AGENTS.md'
  New-Item -ItemType Directory -Force -Path $ocDir | Out-Null

  $begin = '<!-- BEGIN: skill-free-instagram-likes -->'
  $end   = '<!-- END: skill-free-instagram-likes -->'
  # Catatan: here-string tunggal supaya backtick (markdown code) tidak
  # diperlakukan sebagai escape character oleh PowerShell.
  $template = @'
__BEGIN__
## Memory: skill-free-instagram-likes

Dokumentasi lengkap & reusable ada di repo `ozysparda/skill-free-instagram-likes`
(clone: `git clone https://github.com/ozysparda/skill-free-instagram-likes.git`).

- Memory indeks: `MEMORY.md`
- Fakta & keputusan: `docs/memory/01-ig-likes-automation.md`
- Kredensial (lokal, tidak di-commit): `docs/memory/02-kredensial-ig-likes.local.md`

Repo kode: `ozysparda/gh-free-likes` (public).
Skill terpasang di `~/.config/opencode/skills/`: `free-instagram-likes`.

Aturan global skill ini: jangan pernah memberikan password Instagram ke
tool/service mana pun; jangan percaya status "sukses" tanpa verifikasi frasa
konfirmasi strict; jangan spam order (pacing 45-60 detik); jangan menaruh
token/password di dalam repo.
__END__
'@
  $block = $template.Replace('__BEGIN__', $begin).Replace('__END__', $end)

  if (Test-Path $agents) {
    $current = Get-Content $agents -Raw -Encoding UTF8
    $pattern = [regex]::Escape($begin) + '[\s\S]*?' + [regex]::Escape($end)
    if ($current -match $pattern) {
      $current = [regex]::Replace($current, $pattern, '')
      $current = $current.TrimEnd() + "`n`n" + $block + "`n"
      Set-Content -Path $agents -Value $current -Encoding UTF8 -NoNewline
      Write-Ok "Blok memory diperbarui di AGENTS.md."
    } else {
      Add-Content -Path $agents -Value ("`n" + $block) -Encoding UTF8
      Write-Ok "Blok memory ditambahkan ke AGENTS.md."
    }
  } else {
    Set-Content -Path $agents -Value $block -Encoding UTF8 -NoNewline
    Write-Ok "AGENTS.md dibuat."
  }
}

# -------------------------------------------------------------- 4. Clone ---
if (-not $SkipClone) {
  Write-Step "Menyiapkan repo kode gh-free-likes"
  if (-not $git) {
    Write-Warn "Lewati clone karena git tidak tersedia."
  } else {
    if (-not $RepoPath) {
      $RepoPath = Join-Path (Split-Path -Parent $repoRoot) 'gh-free-likes'
    }
    if (Test-Path (Join-Path $RepoPath '.git')) {
      Write-Host "   Update: $RepoPath"
      & $git -C $RepoPath pull --ff-only origin main | Out-Host
    } else {
      Write-Host "   Clone: $RepoPath"
      & $git clone https://github.com/ozysparda/gh-free-likes.git $RepoPath | Out-Host
    }
    if (Test-Path (Join-Path $RepoPath '.git')) {
      Write-Ok "Repo siap di $RepoPath"
    } else {
      Write-Err "Clone gagal."
    }
  }
}

# --------------------------------------------------------- 5. Kredensial ---
Write-Step "Menyiapkan kredensial git"
if (-not $TokenFile) {
  $candidate = Join-Path $env:TEMP 'opencode\github-token.txt'
  if (Test-Path $candidate) { $TokenFile = $candidate }
}

if ($git -and $TokenFile -and (Test-Path $TokenFile)) {
  $gh = ((Get-Content $TokenFile -Raw) | Select-String 'ghp_[A-Za-z0-9]+')
  if ($gh) {
    $token = $gh.Matches[0].Value
    $credPath = Join-Path $env:USERPROFILE '.git-credentials'
    Set-Content -Path $credPath -Value "https://ozysparda:$token@github.com" -NoNewline -Encoding ASCII
    & $git config --global credential.helper store
    Write-Ok "Credential store diperbarui ($credPath)."
  } else {
    Write-Warn "Isi file token tidak recognizable (butuh pola ghp_...)."
  }
} else {
  Write-Warn "File token GitHub tidak ditemukan. Isi manual:"
  Write-Host "   1. Buat PAT: https://github.com/settings/tokens/new (scope repo, No expiration)"
  Write-Host "   2. Simpan ke %TEMP%\opencode\github-token.txt"
  Write-Host "   3. Jalankan ulang: .\bootstrap.ps1 -TokenFile <path>"
}

# ------------------------------------------------------------ 6. Ringkasan ---
Write-Step "Ringkasan"
if ($git) { Write-Host "   git          : $git" }
if ($SkillsTarget) {
  Write-Host "   skills       : $SkillsTarget"
} else {
  $dest = if ($env:XDG_CONFIG_HOME) { Join-Path $env:XDG_CONFIG_HOME 'opencode\skills' } else { Join-Path $env:USERPROFILE '.config\opencode\skills' }
  Write-Host "   skills       : $dest"
}
Write-Host "   memory       : $(Join-Path $env:USERPROFILE '.config\opencode\AGENTS.md')"
if ($RepoPath) { Write-Host "   repo kode    : $RepoPath" }

Write-Host "`nSelesai. Buka sesi OpenCode baru untuk memakai skill & memory." -ForegroundColor Green
Write-Host "Contoh: minta 'tambah like Instagram pake skill free-instagram-likes'." -ForegroundColor Green
