# 05 — Audyt końcowy (Post-Hardening Scan)

## Cel

Uruchomienie drugiego skanu z identycznymi parametrami i porównanie
wyników z audytem bazowym.

## Krok 1: Uruchomienie skanu końcowego

```bash
sudo oscap xccdf eval \
  --profile cis_server_l1 \
  --results /root/openscap-reports/post-results.xml \
  --results-arf /root/openscap-reports/post-arf.xml \
  --report /root/openscap-reports/post-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

## Krok 2: Transfer raportu

```bash
scp root@<IP_VM>:/root/openscap-reports/post-report.html .
```

## Krok 3: Porównanie wyników

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
