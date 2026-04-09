# 06 — Audyt końcowy (Post-Hardening Scan)

## Cel

Uruchomienie drugiego skanu z identycznymi parametrami i porównanie
wyników z audytem bazowym.

## Krok 1: Uruchomienie skanu końcowego

```bash
sudo oscap xccdf eval \
  --profile cis_server_l1_tailored \
  --tailoring-file /var/log/openscap/tailoring.xml \
  --results /var/log/openscap/post-results.xml \
  --results-arf /var/log/openscap/post-arf.xml \
  --report /var/log/openscap/post-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

## Krok 2: Transfer raportu

```bash
scp root@<IP_VM>:/var/log/openscap/post-report.html .
```

## Krok 3: Porównanie wyników

> **Uwaga do interpretacji:** Audyt końcowy używa tailored profilu. Trzy reguły
> wyłączone w tailoringu (`partition_for_tmp`, `partition_for_var`, `package_httpd_removed`)
> nie pojawiają się w raporcie końcowym (`notselected`). Zmniejsza to całkowitą liczbę
> reguł w porównaniu z audytem bazowym — uwzględnij to przy interpretacji różnicy w score.
> Reguły partycji `/var/log`, `/var/log/audit`, `/home` nadal pojawiają się jako `fail`
> (są w zakresie profilu) i wysą udokumentowane jako EXC-001..003.

### Tabela porównawcza

| Metryka                  | Baseline Scan | Post-Hardening Scan | Zmiana   |
|--------------------------|---------------|---------------------|----------|
| Score (%)                |               |                     |          |
| Reguły pass              |               |                     |          |
| Reguły fail              |               |                     |          |
| Reguły notapplicable     |               |                     |          |

### Porównanie po kategoriach

| Kategoria              | Fail (przed) | Fail (po) | Naprawione |
|------------------------|-------------|-----------|------------|
| Filesystem & Partitions|             |           |            |
| SSH                    |             |           |            |
| Authentication         |             |           |            |
| Kernel & Sysctl        |             |           |            |
| Network                |             |           |            |
| Logging & Auditing     |             |           |            |
| Services               |             |           |            |
| Filesystem Permissions |             |           |            |

### Reguły które nadal failują — dlaczego?

Dla każdej reguły, która nadal failuje po hardeningu, wyjaśnij dlaczego:

1. **Reguła:** *(ID i opis)*
   - **Powód:** *(np. wymaga osobnej partycji, świadoma decyzja, bug w fixie)*

*(Powtórz dla każdej reguły)*

## Krok 4: Wnioski

1. O ile procent poprawił się compliance score?
2. Które kategorie zostały w pełni naprawione?
3. Które reguły wymagają zmian architektonicznych (np. partycje)?
4. Czy hardening wpłynął na działanie Apache?
5. Co byś zrobił inaczej następnym razem?

---

### Notatki z realizacji

```
# Twoje notatki:

```
