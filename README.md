# Site-ul Partidului CURAJ pentru România

Site static, publicat cu GitHub Pages la **https://cosettechichirau.github.io/curaj-site/**.
Înlocuiește vechiul site Wix (cosettechichirau.wixsite.com/curaj). Nu are niciun pas de build:
fiecare pagină este un fișier HTML obișnuit, iar orice modificare făcută pe ramura `main`
apare pe site în 1–2 minute.

## Structura

| Fișier | Conținut |
| --- | --- |
| `index.html` | Pagina principală: formular de înscriere, „Noul pact”, cele 5 priorități, echipa, valorile |
| `echilibru-stat-privat.html` … `renastem-patriotismul-romanesc.html` | Cele 5 pagini de prioritate (butoanele „Mai multe”) |
| `statut.html` | Statutul partidului, 18 capitole, cu buton de descărcare PDF |
| `contact.html` | Formular de contact |
| `assets/style.css` | Tot stilul site-ului; culorile sunt definite la începutul fișierului |
| `assets/statut.js` | Comutarea între capitolele statutului (fără JS se afișează tot statutul) |
| `assets/statut.pdf` | Statutul în format PDF |
| `assets/img/` | Logo, fotografii echipă (`team/`), imagini priorități (`pillars/`) |
| `scripts/check.sh` | Verificări automate ale structurii site-ului |

## Cum modifici textul

1. Deschide fișierul HTML al paginii (pe GitHub, apasă pe fișier, apoi pe creionul „Edit”).
2. Modifică textul între etichete, de exemplu `<p>Text vechi</p>` → `<p>Text nou</p>`.
3. Salvează („Commit changes”). Site-ul se actualizează singur.

Pentru a înlocui o fotografie, încarcă noul fișier în `assets/img/` cu **același nume** ca cel vechi.
Pentru un statut nou, înlocuiește `assets/statut.pdf` și actualizează textul capitolelor din `statut.html`.

## Formularele (Formspree) — de făcut o singură dată

Site-ul fiind static, formularele trimit datele prin [Formspree](https://formspree.io) (gratuit până la 50 de mesaje/lună).

1. Creează un cont pe formspree.io cu adresa de e-mail la care vrei să primești mesajele.
2. Creează două formulare („New form”): unul pentru înscrieri, unul pentru contact. Fiecare primește un ID de forma `xabcdefg`.
3. În `index.html`, înlocuiește `YOUR_SIGNUP_FORM_ID` cu ID-ul formularului de înscriere.
4. În `contact.html`, înlocuiește `YOUR_CONTACT_FORM_ID` cu ID-ul formularului de contact.
5. Trimite un mesaj de test de pe site; prima trimitere îți cere să confirmi adresa de e-mail.

Până la pasul 3–4, apăsarea butonului de trimitere afișează o pagină de eroare Formspree.

## Verificări

```bash
scripts/check.sh
```

Verifică faptul că toate paginile există, că fiecare imagine/fișier referit există, că nu au rămas
linkuri către Wix, că statutul are toate cele 18 capitole și că formularele trimit către Formspree.

## Domeniu propriu (opțional)

În GitHub: Settings → Pages → Custom domain, introdu domeniul (ex. `curaj.ro`) și urmează instrucțiunile DNS
afișate. GitHub creează automat fișierul `CNAME`. Toate linkurile din site sunt relative, deci nu trebuie modificat nimic.

## Pentru dezvoltatori

Previzualizare locală:

```bash
python3 -m http.server 8765
```

apoi deschide http://localhost:8765. Documentația de proiectare se află în `docs/superpowers/`.
