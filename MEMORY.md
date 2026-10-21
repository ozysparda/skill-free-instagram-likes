# MEMORY — Indeks Pengetahuan (Free Instagram Likes)

Semua yang dipelajari & dipakai saat membangun **automation free Instagram
likes**. Repo ini adalah "otak" yang bisa dibawa ke PC mana pun: clone repo
ini, jalankan `bootstrap`, skill dan memory ikut terpasang.

| Berkas | Isi |
| --- | --- |
| `docs/memory/01-ig-likes-automation.md` | Fakta & target, kronologi, keputusan & alasannya, arsitektur GH Actions, registry 46 service, peta error → fix, trik anti-bot, cheat sheet, TODO |
| `docs/memory/02-kredensial-ig-likes.local.md` | *(LOCAL, tidak di-commit)* akun panel SMM, API key captcha, mail.tm, alias Gmail, isi GitHub Secrets |

Referensi teknis (di dalam skill):

| Berkas | Isi |
| --- | --- |
| `skills/free-instagram-likes/SKILL.md` | Manual operasional skill |
| `skills/free-instagram-likes/references/services.md` | Registry service + status + limit |
| `skills/free-instagram-likes/references/captcha.md` | Chain provider captcha + bypass + budgeting |
| `skills/free-instagram-likes/references/mail.md` | OTP, alias email, forwarding, App Password |
| `skills/free-instagram-likes/references/github-actions.md` | Workflow, secrets, runner, kuota menit |
| `skills/free-instagram-likes/references/troubleshooting.md` | Symptom → diagnosis → fix |
| `skills/free-instagram-likes/references/code-map.md` | Peta file & fungsi kode |

Aturan emas yang berlaku di semua dokumen:

1. **Jangan pernah menaruh token, password, atau `.env` di dalam repo.**
2. **Jangan pernah memberikan password Instagram ke tool/service mana pun.**
3. **Jangan percaya hasil "sukses" tanpa verifikasi** — pakai frasa konfirmasi
   strict, bukan kata marketing (`order`, `success`, `thank`).
4. **Jangan spam order** — pacing 45–60 detik antar order, maks 8–10 per siklus,
   1 order per service per hari.
5. **Verifikasi byte-per-byte** setelah commit, bukan hanya "commit sukses".
6. **Dokumentasikan tiap temuan baru** di memory ini supaya PC berikutnya langsung paham.
