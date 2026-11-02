# CURAJ site: Wix to GitHub Pages — design

Date: 2026-11-02

## Goal

Move the public site of Partidul CURAJ pentru România from Wix
(https://cosettechichirau.wixsite.com/curaj) to a static site hosted on
GitHub Pages, keeping the same pages, content and look.

## Decisions

- **Approach:** plain hand-written HTML + CSS, no build step, no framework.
- **Hosting:** public repo `cosettechichirau/curaj-site`, GitHub Pages from the
  `main` branch root, URL `https://cosettechichirau.github.io/curaj-site/`.
  All internal links and asset paths are relative so a custom domain can be
  added later without edits.
- **Forms:** both forms post to Formspree. Two placeholder form IDs live in one
  clearly marked place in each page; the owner creates the forms and pastes
  the IDs. The README explains this.
- **Design:** faithful rebuild of the Wix layout. CURAJ blue `#0033A1`
  (RGB 0/51/161 from the statute), Montserrat headings via Google Fonts,
  responsive down to phone width.

## Pages

### `index.html` (home)
Sections in the same order as Wix:
1. Header: logo (links home), nav: Statut, Contact.
2. Hero: flag photo on the left; on the right, the intro paragraph
   ("Partidul CURAJ pentru România este răspunsul nostru…") and the
   **Formular de înscriere** (Nume și prenume, Telefon, Județ, Email,
   role select "Mă înscriu în calitate de…", submit "Vreau să mă înscriu").
3. "Noul pact pentru România modernă": the manifesto text, signed
   Cosette Chichirău, Președintele partidului.
4. Five numbered pillars (01–05).
5. "Echipa": team members with photos and roles.
6. "Valorile noastre": Umanismul, Pragmatismul, Spiritul de echipă.
7. "Prin ce suntem diferiți de alte partide?": five bullet points.
8. Footer.

### `statut.html`
Title, "Actualizat conform Deciziei nr.1/20.10.2023 a Comitetului de
Inițiativă", a "Descarcă în format PDF" button linking to
`assets/statut.pdf`, then a two-column layout: chapter list (19 chapters,
Cap. I to Cap. XIV) on the left, the selected chapter's articles on the
right. Clicking a chapter swaps the content (small vanilla JS, `assets/statut.js`);
all chapters are in the HTML so the page works without JS and is searchable.
Chapter text is captured from the Wix tabs; the PDF is the fallback source
for any chapter that does not capture cleanly.

### `contact.html`
"Contact" heading and party name on the left; form on the right with
Nume, Email, Telefon, Județ, Titlul mesajului, Mesaj, submit "Trimite mesajul".

## Files

```
index.html
statut.html
contact.html
assets/style.css
assets/statut.js
assets/statut.pdf
assets/img/        logo, flag, team photos, section photos (from Wix)
README.md          how to edit content, where Formspree IDs go, how Pages deploys
docs/superpowers/  this spec and the implementation plan
```

## Out of scope

Wix cookie banner and analytics, the Wix promo bar, past Wix form
submissions (not exportable), a custom domain (can be added later), and
the Wix site itself, which stays untouched.

## Verification

Open all three pages at the live GitHub Pages URL in the browser at desktop
and phone widths; confirm every image, the PDF link and all 19 chapters
load; confirm each form has the right fields and posts to Formspree.
