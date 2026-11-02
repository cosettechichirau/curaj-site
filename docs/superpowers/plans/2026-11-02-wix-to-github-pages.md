# CURAJ Wix → GitHub Pages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the three-page CURAJ party site as static HTML/CSS in this repo and publish it on GitHub Pages at `https://cosettechichirau.github.io/curaj-site/`.

**Architecture:** Three hand-written HTML pages share one stylesheet and a common header/footer markup. The Statut page holds all 18 chapters in the HTML and a 30-line script toggles which is visible. Forms post to Formspree. A shell check script asserts structural invariants (all chapters present, every referenced asset exists, no links back to Wix).

**Tech Stack:** HTML5, CSS (custom properties, grid, flex), vanilla JS, Google Fonts (Montserrat), Formspree, GitHub Pages, `gh` CLI.

Spec: `docs/superpowers/specs/2026-11-02-wix-to-github-pages-design.md`

Source material already downloaded to the session scratchpad
`/private/tmp/claude-501/-Users-cosette-Developer-curaj-site/13f0614a-145e-443f-91cf-c18955e53f66/scratchpad/wix/`:
`home.html`, `statut.html`, `contact.html` (Wix page sources), `statut.pdf`, `img/*` (15 images).

---

## File structure

```
index.html            home page
statut.html           statute, 18 chapters + chapter switcher
contact.html          contact form
assets/style.css      all styling, CSS variables at top
assets/statut.js      chapter switcher (progressive enhancement)
assets/statut.pdf     downloadable statute
assets/img/           logo.png, hero-flag.jpg, team/*.png, section photos
scripts/check.sh      structural checks run before every commit
README.md             editing guide, Formspree setup, deployment
```

---

### Task 1: Assets

**Files:**
- Create: `assets/img/*`, `assets/statut.pdf`

- [ ] **Step 1: Identify each downloaded image** by viewing it (Read tool on each file in scratchpad `wix/img/`). Expected: one logo PNG (1099×390 RGBA), one flag JPG hero, seven 610×807 team portraits, the rest section/background photos.

- [ ] **Step 2: Map portraits to names** using the order of `<img>` tags in `wix/home.html` around the "Echipa" section:

```bash
grep -oE '(alt="[^"]*"|static\.wixstatic\.com/media/[a-z0-9_]+~mv2\.(png|jpg))' wix/home.html | grep -B1 '610' | head -40
```
(adjust: look for `alt` attributes near each portrait URL; if no alt, compare with the live page via the browser screenshot of the Echipa section.)

- [ ] **Step 3: Copy with meaningful names**

```bash
mkdir -p assets/img/team
cp wix/img/<logo>.png assets/img/logo.png
cp wix/img/<flag>.jpg assets/img/hero-flag.jpg
cp wix/img/<portrait>.png assets/img/team/cosette-chichirau.png   # etc. for all 7
cp wix/statut.pdf assets/statut.pdf
```

- [ ] **Step 4: Commit**

```bash
git add assets && git commit -m "Add images and statute PDF exported from Wix"
```

---

### Task 2: Capture Statut chapters

**Files:**
- Create: scratchpad `statut/01.txt` … `19.txt` (not committed)

- [ ] **Step 1: In the built-in browser open** `https://cosettechichirau.wixsite.com/curaj/statut`, use `find` with query "Cap." to get refs for all 19 tabs.

- [ ] **Step 2: For each tab:** `computer left_click ref`, `wait 1`, `get_page_text max_chars 60000`; save the article text (from the first `Art.` line to the end of main) to `statut/NN.txt`.

- [ ] **Step 3: Verify** the 19 files together contain every `Art.N` from 1 up to the last article number with no gaps:

```bash
cat statut/*.txt | grep -oE '^Art\.[0-9]+' | sort -t. -k2 -n -u | awk -F. '{print $2}' | awk 'NR>1 && $1!=prev+1 {print "GAP after", prev} {prev=$1}'
```
Expected: no output. If a chapter is missing or garbled, extract that chapter from `statut.pdf` instead (`pdftotext -layout wix/statut.pdf -` if available, else `python3 -I -m pip install --user pypdf` then extract) and note it in the final report.

---

### Task 3: Stylesheet and shared chrome

**Files:**
- Create: `assets/style.css`

- [ ] **Step 1: Write `assets/style.css`**

```css
:root {
  --blue: #0033a1;
  --blue-dark: #00277a;
  --blue-light: #e8edf8;
  --text: #1a1a1a;
  --muted: #555;
  --bg: #fff;
  --radius: 4px;
  --max: 1100px;
  --font-head: "Montserrat", "Helvetica Neue", Arial, sans-serif;
  --font-body: "Montserrat", "Helvetica Neue", Arial, sans-serif;
}
* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body { margin: 0; font: 400 16px/1.6 var(--font-body); color: var(--text); background: var(--bg); }
img { max-width: 100%; display: block; }
a { color: var(--blue); }
h1, h2, h3 { font-family: var(--font-head); font-weight: 700; line-height: 1.2; margin: 0 0 .5em; }
h1 { font-size: 2.2rem; } h2 { font-size: 1.8rem; color: var(--blue); } h3 { font-size: 1.1rem; }
.wrap { max-width: var(--max); margin: 0 auto; padding: 0 20px; }

/* header */
.site-header { position: sticky; top: 0; z-index: 10; background: #fff; border-bottom: 1px solid #e5e5e5; }
.site-header .wrap { display: flex; align-items: center; justify-content: space-between; height: 72px; }
.site-header .logo img { height: 36px; width: auto; }
.site-nav a { margin-left: 28px; text-decoration: none; font-weight: 600; font-size: .95rem; color: var(--blue); }
.site-nav a[aria-current="page"] { opacity: .55; }

/* hero */
.hero { display: grid; grid-template-columns: 1fr 1fr; min-height: 640px; }
.hero-img { background: url("img/hero-flag.jpg") center/cover no-repeat; }
.hero-panel { background: var(--blue); color: #fff; padding: 56px 48px; }
.hero-panel p { font-size: 1.05rem; margin: 0 0 32px; }
.card { background: #fff; color: var(--text); border-radius: var(--radius); padding: 28px; }
.card h2 { font-size: 1.3rem; color: var(--blue); margin-bottom: 18px; }

/* forms */
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.form-grid .full { grid-column: 1 / -1; }
label { display: block; font-size: .8rem; color: var(--muted); margin-bottom: 4px; }
input, select, textarea { width: 100%; font: inherit; padding: 10px 12px; border: 1px solid #c9cfdd; border-radius: var(--radius); background: #fff; color: var(--text); }
input:focus, select:focus, textarea:focus { outline: 2px solid var(--blue); outline-offset: 1px; border-color: var(--blue); }
textarea { min-height: 120px; resize: vertical; }
.btn { display: inline-block; background: var(--blue); color: #fff; border: 0; border-radius: var(--radius); padding: 12px 28px; font: 600 1rem var(--font-head); cursor: pointer; text-decoration: none; }
.btn:hover { background: var(--blue-dark); }
.btn-outline { background: #fff; color: var(--blue); border: 2px solid var(--blue); }
.btn-outline:hover { background: var(--blue-light); }

/* sections */
section { padding: 72px 0; }
section.alt { background: var(--blue-light); }
.pact { max-width: 820px; margin: 0 auto; text-align: center; }
.pact p { font-size: 1.05rem; }
.pact .sign { margin-top: 40px; font-weight: 600; }
.pact .sign small { display: block; font-weight: 400; color: var(--muted); }
.pillars { display: grid; grid-template-columns: repeat(5, 1fr); gap: 24px; }
.pillars .num { font: 700 2.4rem var(--font-head); color: var(--blue); }
.team { display: grid; grid-template-columns: repeat(4, 1fr); gap: 28px; }
.team figure { margin: 0; text-align: center; }
.team img { aspect-ratio: 610/807; object-fit: cover; border-radius: var(--radius); }
.team figcaption { margin-top: 10px; font-weight: 600; }
.team figcaption small { display: block; font-weight: 400; color: var(--muted); }
.values { display: grid; grid-template-columns: repeat(3, 1fr); gap: 32px; }
.diff ul { list-style: none; padding: 0; max-width: 700px; margin: 0 auto; }
.diff li { padding: 14px 0 14px 28px; border-bottom: 1px solid #d8def0; position: relative; }
.diff li::before { content: ""; position: absolute; left: 0; top: 22px; width: 12px; height: 12px; background: var(--blue); transform: rotate(45deg); }

/* statut */
.statut-head { text-align: center; padding: 56px 0 24px; }
.statut-head p { color: var(--muted); }
.statut { display: grid; grid-template-columns: 300px 1fr; gap: 40px; padding: 24px 0 80px; }
.chapters { list-style: none; margin: 0; padding: 0; position: sticky; top: 90px; align-self: start; }
.chapters button { width: 100%; text-align: left; background: none; border: 0; border-left: 3px solid transparent; padding: 10px 12px; font: 500 .9rem var(--font-body); color: var(--text); cursor: pointer; }
.chapters button:hover { background: var(--blue-light); }
.chapters button[aria-selected="true"] { border-left-color: var(--blue); color: var(--blue); font-weight: 700; }
.chapter { display: none; }
.chapter.is-active { display: block; }
.chapter h2 { font-size: 1.4rem; }
.chapter h3 { margin-top: 28px; }
.chapter p { margin: 0 0 1em; }
.no-js .chapter { display: block; }
.no-js .chapters { display: none; }

/* contact */
.contact { display: grid; grid-template-columns: 1fr 1.4fr; gap: 56px; align-items: start; padding: 80px 0; }
.contact h1 { color: var(--blue); }
.contact .party { color: var(--blue); font-size: .85rem; letter-spacing: .04em; }

/* footer */
.site-footer { background: var(--blue); color: #fff; padding: 28px 0; font-size: .85rem; }
.site-footer a { color: #fff; }
.site-footer .wrap { display: flex; justify-content: space-between; flex-wrap: wrap; gap: 12px; }

@media (max-width: 900px) {
  .hero { grid-template-columns: 1fr; }
  .hero-img { min-height: 260px; }
  .pillars { grid-template-columns: repeat(2, 1fr); }
  .team { grid-template-columns: repeat(2, 1fr); }
  .values { grid-template-columns: 1fr; }
  .statut { grid-template-columns: 1fr; }
  .chapters { position: static; }
  .contact { grid-template-columns: 1fr; }
}
@media (max-width: 560px) {
  .hero-panel { padding: 32px 20px; }
  .form-grid { grid-template-columns: 1fr; }
  .pillars { grid-template-columns: 1fr; }
  .site-nav a { margin-left: 16px; }
}
```

- [ ] **Step 2: Commit**

```bash
git add assets/style.css && git commit -m "Add site stylesheet"
```

---

### Task 4: Check script

**Files:**
- Create: `scripts/check.sh`

- [ ] **Step 1: Write the script** (it will fail until pages exist, which is the "red" state):

```bash
#!/usr/bin/env bash
# Structural checks for the static site. Run from repo root: scripts/check.sh
set -u
fail=0
err() { echo "FAIL: $*"; fail=1; }

for p in index.html statut.html contact.html; do
  [ -f "$p" ] || err "$p missing"
done

# every local asset referenced from HTML must exist
for p in index.html statut.html contact.html; do
  [ -f "$p" ] || continue
  grep -oE '(src|href)="(assets|\./assets)/[^"]+"' "$p" | sed -E 's/^[a-z]+="//; s/"$//' | while read -r ref; do
    [ -f "$ref" ] || err "$p references missing $ref"
  done
done

# no links back to Wix
grep -lE 'wixsite\.com|wixstatic\.com|filesusr\.com' index.html statut.html contact.html assets/style.css 2>/dev/null && err "Wix URL still referenced"

# statut has all 18 chapters, as both buttons and sections
if [ -f statut.html ]; then
  n=$(grep -c 'class="chapter"' statut.html); [ "$n" -eq 19 ] || err "statut.html has $n chapter sections, expected 19"
  b=$(grep -c 'data-chapter=' statut.html);  [ "$b" -eq 19 ] || err "statut.html has $b chapter buttons, expected 19"
fi

# forms post to formspree
for p in index.html contact.html; do
  [ -f "$p" ] && { grep -q 'action="https://formspree.io/f/' "$p" || err "$p form does not post to Formspree"; }
done

[ $fail -eq 0 ] && echo "OK" || exit 1
```

- [ ] **Step 2: Run it, expect failures** `chmod +x scripts/check.sh && scripts/check.sh` → `FAIL: index.html missing` etc.

- [ ] **Step 3: Commit** `git add scripts && git commit -m "Add structural check script"`

---

### Task 5: Home page

**Files:**
- Create: `index.html`

- [ ] **Step 1: Write `index.html`** with this skeleton; the text is copied verbatim from the Wix page text captured earlier (hero intro, manifesto, pillars, team, values, differences):

```html
<!doctype html>
<html lang="ro">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CURAJ pentru România</title>
<meta name="description" content="Partidul CURAJ pentru România – o opțiune politică ce pune accent pe organizare, responsabilitate și pragmatism.">
<link rel="icon" href="assets/img/logo.png">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="assets/style.css">
</head>
<body>
<header class="site-header"><div class="wrap">
  <a class="logo" href="./"><img src="assets/img/logo.png" alt="CURAJ"></a>
  <nav class="site-nav"><a href="statut.html">Statut</a><a href="contact.html">Contact</a></nav>
</div></header>

<main>
<section class="hero" style="padding:0">
  <div class="hero-img" role="img" aria-label="Steagul României"></div>
  <div class="hero-panel">
    <p>Partidul CURAJ pentru România este răspunsul nostru la nevoia de revigorare a scenei politice. Oferim cetățenilor o opțiune politică ce pune accent pe organizare, responsabilitate și pragmatism.<br>Vino alături de noi!</p>
    <div class="card">
      <h2>Formular de înscriere</h2>
      <!-- FORMSPREE: replace YOUR_SIGNUP_FORM_ID with the ID from formspree.io -->
      <form class="form-grid" action="https://formspree.io/f/YOUR_SIGNUP_FORM_ID" method="POST">
        <div class="full"><label for="s-nume">Nume și prenume</label><input id="s-nume" name="nume" required></div>
        <div><label for="s-tel">Telefon</label><input id="s-tel" name="telefon" type="tel"></div>
        <div><label for="s-judet">Județ</label><input id="s-judet" name="judet"></div>
        <div class="full"><label for="s-email">Email *</label><input id="s-email" name="email" type="email" required></div>
        <div class="full"><label for="s-rol">Alege rolul tău în organizație</label>
          <select id="s-rol" name="rol"><option value="">Mă înscriu în calitate de...</option>
          <!-- options copied from Wix select, see Step 2 --></select></div>
        <div class="full"><button class="btn" type="submit">Vreau să mă înscriu</button></div>
      </form>
    </div>
  </div>
</section>

<section><div class="wrap pact">
  <h2>Noul pact pentru România modernă</h2>
  <p>…manifesto paragraphs verbatim…</p>
  <p class="sign">Cosette Chichirău<small>Președintele partidului Curaj pentru România</small></p>
</div></section>

<section class="alt"><div class="wrap pillars">
  <div><div class="num">01</div><h3>Un nou echilibru între stat și privat</h3></div>
  <!-- 02–05 likewise -->
</div></section>

<section><div class="wrap"><h2>Echipa</h2><div class="team">
  <figure><img src="assets/img/team/cosette-chichirau.png" alt=""><figcaption>Cosette Chichirău<small>Președinte</small></figcaption></figure>
  <!-- remaining 6 members -->
</div></div></section>

<section class="alt"><div class="wrap"><h2>Valorile noastre</h2><div class="values">
  <div><h3>Umanismul</h3><p>În centrul eforturilor noastre sunt oamenii: nevoile, ideile, valorile și munca lor.</p></div>
  <div><h3>Pragmatismul</h3><p>Imaginăm și dezvoltăm soluții practice pentru problemele actuale.</p></div>
  <div><h3>Spiritul de echipă</h3><p>Credem în spiritul de echipă, în susținere reciprocă și în efort comun.</p></div>
</div></div></section>

<section class="diff"><div class="wrap"><h2 style="text-align:center">Prin ce suntem diferiți<br>de alte partide?</h2><ul>
  <li>Criterii serioase pentru selecția candidaților</li>
  <li>Limite de mandate pentru parlamentari și primari</li>
  <li>Promovarea femeilor în politică</li>
  <li>Cultură internă bazată pe proiecte și soluții</li>
  <li>Cultivarea încrederii și susținerea echipei</li>
</ul></div></section>
</main>

<footer class="site-footer"><div class="wrap">
  <span>© Partidul CURAJ pentru România</span>
  <span><a href="statut.html">Statut</a> · <a href="contact.html">Contact</a></span>
</div></footer>
</body>
</html>
```

- [ ] **Step 2: Fill the role `<select>` options** from the Wix source:
`grep -oE '<option[^>]*>[^<]*</option>' wix/home.html` (or `read_page` on the live select). Copy them verbatim.

- [ ] **Step 3: Run `scripts/check.sh`** → still FAIL only on statut/contact missing; no `index.html` lines.

- [ ] **Step 4: Commit** `git add index.html && git commit -m "Add home page"`

---

### Task 6: Contact page

**Files:**
- Create: `contact.html`

- [ ] **Step 1: Write `contact.html`** with the same `<head>`, header (nav link `aria-current="page"` on Contact) and footer as `index.html`, and this main:

```html
<main><div class="wrap contact">
  <div><h1>Contact</h1><p class="party">Partidul CURAJ PENTRU ROMÂNIA</p></div>
  <!-- FORMSPREE: replace YOUR_CONTACT_FORM_ID with the ID from formspree.io -->
  <form class="form-grid" action="https://formspree.io/f/YOUR_CONTACT_FORM_ID" method="POST">
    <div><label for="c-nume">Nume *</label><input id="c-nume" name="nume" required></div>
    <div><label for="c-email">Email *</label><input id="c-email" name="email" type="email" required></div>
    <div><label for="c-tel">Telefon *</label><input id="c-tel" name="telefon" type="tel" required></div>
    <div><label for="c-judet">Județ</label><input id="c-judet" name="judet"></div>
    <div class="full"><label for="c-subiect">Titlul mesajului</label><input id="c-subiect" name="_subject"></div>
    <div class="full"><label for="c-mesaj">Mesaj</label><textarea id="c-mesaj" name="mesaj"></textarea></div>
    <div class="full"><button class="btn" type="submit" style="width:100%">Trimite mesajul</button></div>
  </form>
</div></main>
```

- [ ] **Step 2: Run `scripts/check.sh`** → only statut lines fail.
- [ ] **Step 3: Commit** `git add contact.html && git commit -m "Add contact page"`

---

### Task 7: Statut page and switcher

**Files:**
- Create: `statut.html`, `assets/statut.js`

- [ ] **Step 1: Write `assets/statut.js`**

```js
(function () {
  var buttons = document.querySelectorAll('.chapters button');
  var chapters = document.querySelectorAll('.chapter');
  function show(id) {
    chapters.forEach(function (c) { c.classList.toggle('is-active', c.id === id); });
    buttons.forEach(function (b) { b.setAttribute('aria-selected', String(b.dataset.chapter === id)); });
    if (history.replaceState) history.replaceState(null, '', '#' + id);
  }
  buttons.forEach(function (b) {
    b.addEventListener('click', function () { show(b.dataset.chapter); });
  });
  var initial = location.hash.slice(1);
  show(document.getElementById(initial) ? initial : chapters[0].id);
})();
```

- [ ] **Step 2: Generate chapter HTML** from the 19 text files with a small Python script in the scratchpad (not committed). Rules: a line starting with `Art.` becomes `<h3>`, any other non-empty line becomes `<p>`, chapter id is `cap-1` … `cap-19`. Escape `&`, `<`, `>`. Output is pasted into `statut.html`.

```python
import html, re, pathlib, sys
src = pathlib.Path(sys.argv[1]); titles = [l.strip() for l in open(sys.argv[2], encoding='utf-8') if l.strip()]
out = []
for i, (f, title) in enumerate(zip(sorted(src.glob('*.txt')), titles), 1):
    body = []
    for line in f.read_text(encoding='utf-8').splitlines():
        s = line.strip().replace('​', '')
        if not s: continue
        tag = 'h3' if re.match(r'^Art\.\s*\d+', s) else 'p'
        body.append(f'<{tag}>{html.escape(s)}</{tag}>')
    out.append(f'<article class="chapter" id="cap-{i}">\n<h2>{html.escape(title)}</h2>\n' + '\n'.join(body) + '\n</article>')
print('\n'.join(out))
```

- [ ] **Step 3: Write `statut.html`** with shared head/header/footer (nav `aria-current="page"` on Statut), `<body class="no-js">` plus `<script>document.body.classList.remove('no-js')</script>` first thing in body, and:

```html
<main>
<div class="wrap statut-head">
  <h1>Statutul Partidului Curaj pentru România</h1>
  <p>Actualizat conform Deciziei nr.1/20.10.2023 a Comitetului de Inițiativă</p>
  <a class="btn btn-outline" href="assets/statut.pdf" download>Descarcă în format PDF</a>
</div>
<div class="wrap statut">
  <ul class="chapters" role="tablist">
    <li><button type="button" role="tab" data-chapter="cap-1">Cap. I - Dispoziții generale</button></li>
    <!-- … 19 buttons, titles exactly as on Wix -->
  </ul>
  <div class="chapter-body">
    <!-- generated <article class="chapter" id="cap-N"> blocks -->
  </div>
</div>
</main>
<script src="assets/statut.js"></script>
```

- [ ] **Step 4: Run `scripts/check.sh`** → `OK`.
- [ ] **Step 5: Commit** `git add statut.html assets/statut.js && git commit -m "Add statute page with chapter switcher"`

---

### Task 8: README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README.md** covering: what the site is, file map, how to edit text (open the HTML file, edit, commit), how to connect Formspree (create account, two forms, replace `YOUR_SIGNUP_FORM_ID` in `index.html` and `YOUR_CONTACT_FORM_ID` in `contact.html`), how to replace the statute PDF or a photo, how to run `scripts/check.sh`, and that GitHub Pages deploys `main` automatically within a minute or two. Also how to add a custom domain later (Settings → Pages → Custom domain; CNAME file is created by GitHub).

- [ ] **Step 2: Commit** `git add README.md && git commit -m "Add README with editing and deployment guide"`

---

### Task 9: Publish

- [ ] **Step 1: Create the repo and push**

```bash
gh repo create cosettechichirau/curaj-site --public --source=. --remote=origin --push --description "Site-ul Partidului CURAJ pentru România"
```

- [ ] **Step 2: Enable Pages from main root**

```bash
gh api -X POST repos/cosettechichirau/curaj-site/pages -f build_type=legacy -f 'source[branch]=main' -f 'source[path]=/'
```
Expected: JSON with `"html_url": "https://cosettechichirau.github.io/curaj-site/"`.

- [ ] **Step 3: Wait for the first build** `gh api repos/cosettechichirau/curaj-site/pages/builds/latest --jq .status` until `built` (poll every 20 s, up to 3 min).

---

### Task 10: Verify live

- [ ] **Step 1:** Built-in browser: open `https://cosettechichirau.github.io/curaj-site/`, screenshot, `get_page_text`; confirm hero, form, manifesto, pillars, 7 team members, values, differences.
- [ ] **Step 2:** Open `statut.html`; click chapter 1, 10 and 19 buttons; confirm content changes and PDF link returns 200 (`curl -sI … | head -1`).
- [ ] **Step 3:** Open `contact.html`; confirm six fields and button.
- [ ] **Step 4:** `resize_window preset mobile`, screenshot each page, confirm no horizontal scroll (`document.documentElement.scrollWidth <= window.innerWidth` via javascript_tool), then `preset desktop`.
- [ ] **Step 5:** `curl -s -o /dev/null -w '%{http_code}'` for every `assets/img/*` URL and the PDF → all 200.
- [ ] **Step 6:** Report to the user: live URL, Formspree steps left for them, anything that fell back to the PDF.
