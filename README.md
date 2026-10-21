# Skill OpenCode — Free Instagram Likes

Skill + memory khusus untuk **automation free Instagram likes** (SMM panel,
captcha multi-provider, temp-mail OTP, jadwal penuh di GitHub Actions).

Repo ini **terpisah** dari katalog skill umum
(`ozysparda/skill-free-instagram-likes`) supaya tidak bercampur dengan
pengembangan skill lain.

## Isi

### Skill

| Skill ID | Untuk apa |
| --- | --- |
| `free-instagram-likes` | Klaim free IG likes dari 46 SMM panel (tanpa password IG), captcha multi-provider, OTP temp-mail, GH Actions terjadwal |

### Memory

| Berkas | Isi |
| --- | --- |
| `MEMORY.md` | Indeks pengetahuan + aturan emas |
| `docs/memory/01-ig-likes-automation.md` | Fakta, kronologi, keputusan & alasan, registry service, peta error, trik anti-bot, TODO |
| `docs/memory/02-kredensial-ig-likes.local.md` | *(lokal, tidak di-commit)* kredensial panel SMM, API key captcha, mail.tm, alias Gmail |

Kode yang dijalankan skill ini ada di repo terpisah:
**https://github.com/ozysparda/gh-free-likes** (private).

## Pasang di PC baru

```bash
git clone https://github.com/ozysparda/skill-free-instagram-likes.git
cd skill-free-instagram-likes
```

**Windows (PowerShell)**

```powershell
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

**macOS / Linux**

```bash
chmod +x bootstrap.sh install.sh
./bootstrap.sh
```

`bootstrap` akan:
1. Menginstal skill ke `~/.config/opencode/skills/free-instagram-likes`.
2. Memasang blok memory global di `~/.config/opencode/AGENTS.md`
   (blok `skill-free-instagram-likes`, aman dijalankan berulang).
3. Clone/update repo kode `ozysparda/gh-free-likes`.
4. Menyiapkan kredensial git bila file token GitHub tersedia.

Opsi:

```powershell
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1 -SkipClone
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1 -TokenFile D:\secure\github-token.txt
```

## Yang TIDAK dibawa

Password & API key **tidak** ada di repo ini (`.gitignore` menolak `*.local.md`).
Untuk PC baru:

1. Salin `docs/memory/02-kredensial-ig-likes.local.md` secara manual, atau
   set ulang lewat `skills/free-instagram-likes/scripts/setup-github.ps1 -SecretFile <file>`.
2. Token GitHub: <https://github.com/settings/tokens/new> — scope `repo`,
   *No expiration*, simpan di `%TEMP%\opencode\github-token.txt`.

## Aturan emas

1. Jangan pernah menaruh token/password di dalam repo.
2. **Jangan pernah memberikan password Instagram ke tool/service mana pun.**
3. Jangan percaya status "sukses" tanpa verifikasi frasa konfirmasi yang strict.
4. Jangan spam order (pacing 45–60 detik, max 8–10 order/siklus).
5. Verifikasi byte-per-byte setelah commit, bukan hanya "commit sukses".
