# 03 — Audyt bazowy (Baseline Scan)

## Cel

Uruchomienie pierwszego skanu CIS Level 1 Server na czystym RHEL 10
z działającym Apache. Zebranie wyników "przed hardingiem" jako punkt odniesienia.

## Komendy

### Wylistowanie dostępnych profili

```bash
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

*(Zapisz listę profili — znajdź ID profilu CIS Level 1 Server)*

### Uruchomienie skanu

```bash
sudo oscap xccdf eval \
  --profile cis_server_l1 \
  --results /root/openscap-reports/baseline-results.xml \
  --results-arf /root/openscap-reports/baseline-arf.xml \
  --report /root/openscap-reports/baseline-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

**Uwaga:** Profil ID może się różnić — użyj dokładnego ID z `oscap info`.

### Podgląd wyników w terminalu

```bash
# Podsumowanie — ile pass, ile fail
oscap xccdf eval \
  --profile cis_server_l1 \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml 2>&1 | tail -20
```

### Transfer raportu HTML na maszynę lokalną

```bash
# Z maszyny lokalnej (nie z VM):
scp root@<IP_VM>:/root/openscap-reports/baseline-report.html .
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
