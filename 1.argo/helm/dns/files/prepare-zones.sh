#!/bin/sh
# Prépare les zones sur le volume persistant avant le démarrage de named.
#  - source inchangée depuis le dernier déploiement : on ne touche à rien (fichier + journal), les
#    enregistrements dynamiques (challenges ACME de cert-manager, external-dns) survivent au redémarrage.
#  - source modifiée : nouvelle source + enregistrements dynamiques de la zone live (= live moins
#    l'ancienne source), serial = max(date YYMMDDHHMM, serial live + 1), journal supprimé.
# Usage : prepare-zones.sh <dossier source> <dossier zones> <fichier>=<zone> ...
set -u
SRC=$1; Z=$2; shift 2
APPLIED=$Z/.applied
mkdir -p "$APPLIED"
NOW=$(date -u +%y%m%d%H%M)
compile() { # compile <zone> <fichier> <sortie> [-j] : format canonique, un enregistrement absolu par ligne
  named-compilezone -q -i none -k ignore -n ignore -r ignore -M ignore -S ignore -W ignore -s full ${4:-} -o "$3" "$1" "$2" 2>&1
}
serial_of() { awk '$4=="SOA"{print $7; exit}' "$1"; }

for arg in "$@"; do
  key=${arg%%=*}; zone=${arg#*=}
  src=$SRC/$key; dst=$Z/$key; prev=$APPLIED/$key
  if [ -f "$dst" ] && [ -f "$prev" ] && cmp -s "$src" "$prev"; then
    echo "$key: source inchangée, zone live conservée (serial $(grep -oE '[0-9]+; *serial' "$dst" | grep -oE '^[0-9]+' || echo '?'))"
    continue
  fi
  tmp=$(mktemp -d)
  : > "$tmp/dyn"; live=0
  if [ -f "$dst" ] && compile "$zone" "$dst" "$tmp/live" -j; then
    live=$(serial_of "$tmp/live")
    # Référence = ancienne source appliquée, ou à défaut la nouvelle source
    ref=$prev; [ -f "$ref" ] || ref=$src
    if compile "$zone" "$ref" "$tmp/ref"; then
      awk 'NR==FNR{seen[$0]=1;next} $4!="SOA" && !($0 in seen)' "$tmp/ref" "$tmp/live" > "$tmp/dyn"
    fi
  elif [ -f "$dst" ]; then
    echo "$key: ATTENTION zone live illisible, enregistrements dynamiques perdus"
  fi
  cp -L "$src" "$tmp/new"
  if [ -s "$tmp/dyn" ]; then
    { echo; echo "; Enregistrements dynamiques conservés (cert-manager, external-dns)"; cat "$tmp/dyn"; } >> "$tmp/new"
  fi
  cur=$(grep -oE '[0-9]+; *serial' "$tmp/new" | grep -oE '^[0-9]+')
  new=$(awk -v a="$NOW" -v b="$((live + 1))" -v c="${cur:-0}" 'BEGIN{m=a; if(b>m)m=b; if(c>m)m=c; print m}')
  sed -i -E "s/[0-9]+(; *serial)/$new\1/" "$tmp/new"
  if ! compile "$zone" "$tmp/new" "$tmp/check" >/dev/null; then
    echo "$key: ATTENTION la fusion ne passe pas named-checkzone, on repart de la source seule"
    cp -L "$src" "$tmp/new"; sed -i -E "s/[0-9]+(; *serial)/$new\1/" "$tmp/new"
  fi
  mv "$tmp/new" "$dst"
  rm -f "$dst.jnl"
  cp -L "$src" "$prev"
  echo "$key: source appliquée, serial ${live} -> ${new}, $(wc -l < "$tmp/dyn") enregistrement(s) dynamique(s) conservé(s)"
  rm -rf "$tmp"
done
# named tourne en utilisateur bind : il doit pouvoir écrire journal et dumps
chmod 0777 "$Z"
find "$Z" -maxdepth 1 -type f -exec chmod 0666 {} +
