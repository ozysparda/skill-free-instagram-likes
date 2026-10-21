#!/usr/bin/env bash
# Bootstrap skill-free-instagram-likes untuk macOS/Linux.
#
#   git clone https://github.com/ozysparda/skill-free-instagram-likes.git
#   cd skill-free-instagram-likes
#   ./bootstrap.sh
#
# Melakukan: pasang skill ke ~/.config/opencode/skills, pasang blok memory
# global di ~/.config/opencode/AGENTS.md (blok terpisah, tidak menyentuh blok
# skill lain), clone/update repo kode gh-free-likes, dan menyiapkan credential
# git bila file token tersedia.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skip_clone=0
skip_memory=0
token_file="${GITHUB_TOKEN_FILE:-${TMPDIR:-/tmp}/opencode/github-token.txt}"
code_path="${CODE_PATH:-$(dirname "$repo_root")/gh-free-likes}"

while [ $# -gt 0 ]; do
  case "$1" in
    --skip-clone) skip_clone=1 ;;
    --skip-memory) skip_memory=1 ;;
    --token-file) token_file="$2"; shift ;;
    --code-path) code_path="$2"; shift ;;
    *) echo "Argumen tidak dikenal: $1" >&2; exit 1 ;;
  esac
  shift
done

echo "=============================================="
echo " Bootstrap skill-free-instagram-likes"
echo "=============================================="

# ------------------------------------------------------------------ git ---
echo ">> Memeriksa Git"
if ! command -v git >/dev/null 2>&1; then
  echo "   [!] Git belum terpasang. Pasang manual:"
  echo "       macOS : brew install git"
  echo "       Debian: sudo apt install git"
  exit 1
fi
echo "   [OK] Git: $(git --version)"

# --------------------------------------------------------------- skills ---
echo ">> Menginstal skill"
./install.sh

# --------------------------------------------------------------- memory ---
if [ "$skip_memory" -eq 0 ]; then
  echo ">> Memasang memory global"
  oc_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
  agents="$oc_dir/AGENTS.md"
  mkdir -p "$oc_dir"
  begin='<!-- BEGIN: skill-free-instagram-likes -->'
  end='<!-- END: skill-free-instagram-likes -->'

  if [ -f "$agents" ] && grep -qF "$begin" "$agents"; then
    echo "   [OK] AGENTS.md sudah punya blok memory."
  else
    {
      echo "$begin"
      echo "## Memory: skill-free-instagram-likes"
      echo
      echo "Dokumentasi lengkap ada di repo \`ozysparda/skill-free-instagram-likes\`."
      echo "Memory indeks: MEMORY.md | docs/memory/01-ig-likes-automation.md"
      echo "Kredensial (lokal, tidak di-commit): docs/memory/02-kredensial-ig-likes.local.md"
      echo "Repo kode: ozysparda/gh-free-likes. Skill: free-instagram-likes."
      echo
      echo "Aturan global: jangan pernah memberi password Instagram ke tool/service;"
      echo "jangan percaya sukses tanpa verifikasi frasa strict; jangan spam order."
      echo "$end"
    } >> "$agents"
    echo "   [OK] AGENTS.md diperbarui: $agents"
  fi
fi

# ---------------------------------------------------------------- clone ---
if [ "$skip_clone" -eq 0 ]; then
  echo ">> Menyiapkan repo kode gh-free-likes"
  if [ -d "$code_path/.git" ]; then
    git -C "$code_path" pull --ff-only origin main
  else
    git clone https://github.com/ozysparda/gh-free-likes.git "$code_path"
  fi
  echo "   [OK] Repo siap di $code_path"
fi

# ---------------------------------------------------------- kredensial ---
echo ">> Menyiapkan kredensial git"
if [ -f "$token_file" ]; then
  token="$(grep -o 'ghp_[A-Za-z0-9]*' "$token_file" | head -n1)"
  if [ -n "$token" ]; then
    printf 'https://ozysparda:%s@github.com' "$token" > "$HOME/.git-credentials"
    chmod 600 "$HOME/.git-credentials"
    git config --global credential.helper store
    echo "   [OK] Credential store diperbarui."
  fi
else
  echo "   [!] File token GitHub tidak ditemukan ($token_file)."
  echo "       Buat PAT: https://github.com/settings/tokens/new (scope repo)"
fi

echo
echo "Selesai. Buka sesi OpenCode baru untuk memakai skill & memory."
