#!/usr/bin/env bash
# Structural checks for the static site. Run from the repo root: scripts/check.sh
set -u
cd "$(dirname "$0")/.."
fail=0
err() { echo "FAIL: $*"; fail=1; }

PAGES="index.html statut.html contact.html echilibru-stat-privat.html viitor-copii-tineri.html respectam-femeile.html siguranta-zilei-de-maine.html renastem-patriotismul-romanesc.html"

for p in $PAGES; do
  [ -f "$p" ] || err "$p missing"
done

# every local asset or page referenced from HTML/CSS must exist
for p in $PAGES assets/style.css; do
  [ -f "$p" ] || continue
  for ref in $(grep -oE '(src|href|url\()=?"?\(?[^"):]+\.(css|js|png|jpg|jpeg|svg|pdf|html)' "$p" | sed -E "s/^[a-z]+\\(?=?[\"']?\\(?[\"']?//" | grep -vE '^(https?:|//|#|mailto:)' | sort -u); do
    case "$p" in assets/*) base="assets/$ref" ;; *) base="$ref" ;; esac
    [ -f "$base" ] || err "$p references missing $base"
  done
done

# no links back to Wix
if grep -lE 'wixsite\.com|wixstatic\.com|filesusr\.com' $PAGES assets/style.css assets/statut.js 2>/dev/null; then err "Wix URL still referenced"; fi

# statut has all 18 chapters, as both buttons and sections
if [ -f statut.html ]; then
  n=$(grep -c '<article class="chapter' statut.html); [ "$n" -eq 18 ] || err "statut.html has $n chapter sections, expected 18"
  b=$(grep -c 'data-chapter=' statut.html);  [ "$b" -eq 18 ] || err "statut.html has $b chapter buttons, expected 18"
  a=$(grep -oE '<h3>Art\. ?[0-9]+' statut.html | wc -l | tr -d ' '); [ "$a" -ge 95 ] || err "statut.html has only $a article headings, expected 99"
fi

# forms post to Formspree
for p in index.html contact.html; do
  [ -f "$p" ] && { grep -q 'action="https://formspree.io/f/' "$p" || err "$p form does not post to Formspree"; }
done

# every page has the shared nav and footer
for p in $PAGES; do
  [ -f "$p" ] || continue
  grep -q 'class="site-header"' "$p" || err "$p lacks site header"
  grep -q 'class="site-footer"' "$p" || err "$p lacks site footer"
  grep -q '<html lang="ro">' "$p" || err "$p lacks lang=ro"
done

[ $fail -eq 0 ] && echo "OK" || exit 1
