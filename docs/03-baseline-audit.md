# 03 — Audyt bazowy (Baseline Scan)

## Cel

Uruchomienie pierwszego skanu CIS Level 1 Server na czystym RHEL 10
z działającym Apache. Zebranie wyników "przed hardingiem" jako punkt odniesienia.

## Komendy

### Wylistowanie dostępnych profili

```bash
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml

# Output:
Title: CIS Red Hat Enterprise Linux 10 Benchmark for Level 1 - Server
Id: xccdf_org.ssgproject.content_profile_cis_server_l1
```

### Uruchomienie skanu

```bash
sudo oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis_server_l1 \
  --results /var/log/openscap/baseline-results.xml \
  --results-arf /var/log/openscap/baseline-arf.xml \
  --report /var/log/openscap/baseline-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

**Co robi ta komenda:**
- `--profile xccdf_org.ssgproject.content_profile_cis_server_l1` — używa profilu CIS Level 1 Server
- `--results /var/log/openscap/baseline-results.xml` — zapisuje surowe wyniki w formacie XCCDF (do dalszego przetwarzania)
- `--results-arf /var/log/openscap/baseline-arf.xml` — zapisuje wyniki w formacie ARF (Asset Reporting Format, używany przez compliance tools)
- `--report /var/log/openscap/baseline-report.html` — generuje czytelny raport HTML do przeglądania w przeglądarce
- Ostatni argument to ścieżka do pliku z definicjami reguł CIS (SSG — Security Scanned Guides)

**Uwaga:** Profil ID może się różnić — użyj dokładnego ID z `oscap info`.

### Przeglądanie raportu w terminalu (Lynx)

Na serwerze bez GUI zainstaluj przeglądarkę tekstową:

```bash
sudo dnf install -y lynx
lynx /var/log/openscap/baseline-report.html
```

Nawigacja w Lynx:
- **↑/↓** — przewijanie
- **Enter** — wejście w link
- **B** — powrót
- **Q** — wyjście

### Transfer raportu HTML na maszynę lokalną (opcjonalnie)

```bash
# Z maszyny lokalnej (nie z VM):
scp root@<IP_VM>:/var/log/openscap/baseline-report.html .
```

## Analiza raportu

Po otwarciu `baseline-report.html` w przeglądarce:

1. **Nagłówek** — data skanu, profil, wersja SSG
2. **Score** — procent zgodności (spodziewany ~40-60% na czystym systemie)
3. **Tabela reguł** — status każdej reguły:
   - 🟢 **pass** — reguła spełniona
   - 🔴 **fail** — reguła niespełniona (wymaga naprawy)
   - ⚪ **notapplicable** — reguła nie dotyczy tego systemu
   - 🟡 **notchecked** — brak testu dla tej reguły

### Kategoryzacja wyników

Pogrupuj faile według kategorii (patrz LAB_RULES.md):

| Kategoria              | Liczba fail | Przykłady reguł |
|------------------------|-------------|-----------------|
| Filesystem & Partitions|             |                 |
| SSH                    |             |                 |
| Authentication         |             |                 |
| Kernel & Sysctl        |             |                 |
| Network                |             |                 |
| Logging & Auditing     |             |                 |
| Services               |             |                 |
| Filesystem Permissions |             |                 |

*(Wypełnij tabelę na podstawie swojego raportu)*

## Pytania do odpowiedzenia

1. Jaki procent reguł przeszedł (pass)?
2. Które kategorie mają najwięcej faili?
3. Czy są jakieś reguły, których NIE da się naprawić po instalacji (np. partycje)?
4. Ile reguł to "quick wins" — proste do naprawienia?

---

### Notatki z realizacji

```
# Twoje notatki:

```
