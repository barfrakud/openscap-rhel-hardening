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

| Metryka                  | Baseline Scan | Post-Hardening Scan | Zmiana      |
|--------------------------|---------------|---------------------|-------------|
| Score (%)                | 73.99%        | 95.45%              | +21.46 pp   |
| Reguły pass              | 170           | 283                 | +113        |
| Reguły fail              | 119           | 5                   | −114        |
| Reguły notapplicable     | 32            | 31                  | −1          |

> **Uwaga:** Liczba reguł `pass` wzrosła o 113, mimo że 3 reguły zostały wyłączone
> w tailoringu. Wynika to z tego, że remediation naprawiło 114 reguł fail → pass,
> a 3 wykluczone reguły (`notselected`) nie wchodzą do licznika `pass`.

### Porównanie po kategoriach

| Kategoria              | Fail (przed) | Fail (po) | Naprawione |
|------------------------|-------------|-----------|------------|
| Filesystem & Partitions| 4           | 0         | 4          |
| SSH                    | 13          | 1         | 12         |
| Authentication         | 34          | 2         | 32         |
| Kernel & Sysctl        | 41          | 0         | 41         |
| Network                | 1           | 0         | 1          |
| Logging & Auditing     | 8           | 1         | 7          |
| Services               | 9           | 1         | 8          |
| Filesystem Permissions | 9           | 0         | 9          |

> Kategoria **Authentication** obejmuje reguły sudo, GRUB, banery logowania i crypto
> policy. Kategoria **Logging & Auditing** obejmuje AIDE, journald i rsyslog.

### Reguły które nadal failują — dlaczego?

1. **Reguła:** `sshd_limit_user_access` — *Limit Users' SSH Access*
   - **Powód:** Wymaga zdefiniowania `AllowUsers` lub `AllowGroups` w `/etc/ssh/sshd_config`. Jest to decyzja architektoniczna zależna od polityki dostępu w danej organizacji — w środowisku laboratoryjnym nie zdefiniowano listy dozwolonych użytkowników SSH.

2. **Reguła:** `accounts_password_last_change_is_in_past` — *Ensure all users last password change date is in the past*
   - **Powód:** Sprawdza czy data ostatniej zmiany hasła we wszystkich kontach nie jest ustawiona na przyszłość (`/etc/shadow`, pole 3). W środowisku laboratoryjnym konto root lub inne konto testowe ma datę ustawioną nieprawidłowo (lub pole jest puste). Naprawa: `chage -d $(date +%Y-%m-%d) <username>`.

3. **Reguła:** `grub2_password` — *Set Boot Loader Password in grub2* (severity: high)
   - **Powód:** Wymaga interaktywnego ustawienia hasła GRUB2 poleceniem `grub2-setpassword`. Remediation Ansible nie wykonuje tej operacji, ponieważ wymaga podania hasła w trybie interaktywnym. W środowisku chmurowym/wirtualnym ochrona boot loadera jest często pomijana świadomie (brak fizycznego dostępu do konsoli).

4. **Reguła:** `ensure_journald_and_rsyslog_not_active_together` — *Ensure journald and rsyslog Are Not Active Together*
   - **Powód:** Remediation włączyło `rsyslog` (dla persystencji logów), ale nie wyłączyło forwardingu z `journald` do `rsyslog`. Reguła wykrywa, że obydwa serwisy są aktywne jednocześnie bez właściwej konfiguracji separacji. Naprawa: wyłączyć `ForwardToSyslog=no` w `journald.conf` lub odwrotnie — wyłączyć rsyslog i polegać wyłącznie na journald.

5. **Reguła:** `service_systemd-journal-upload_enabled` — *Enable systemd-journal-upload Service*
   - **Powód:** Reguła wymaga włączenia `systemd-journal-upload` do centralnego przesyłania logów na zdalny serwer (`systemd-journal-remote`). W środowisku laboratoryjnym nie istnieje centralny serwer logów — konfiguracja tej usługi wykracza poza zakres ćwiczenia.

## Krok 4: Wnioski

1. **Score poprawił się o 21.46 punktów procentowych** (73.99% → 95.45%). Udało się naprawić 114 z 119 failujących reguł, co stanowi wskaźnik naprawy na poziomie ~95.8%.

2. **Kategorie w pełni naprawione:** Filesystem & Partitions (4/4), Kernel & Sysctl (41/41), Network (1/1), Filesystem Permissions (9/9). Łącznie cztery z ośmiu kategorii osiągnęły 100% compliance.

3. **Reguły wymagające zmian architektonicznych (partycje):** `partition_for_tmp`, `partition_for_var`, `partition_for_home`, `partition_for_var_log`, `partition_for_var_log_audit` — wszystkie wymagają oddzielnych partycji systemu plików, co niemożliwe jest do naprawienia bez reinstalacji systemu lub modyfikacji układu dysków. Zostały wyłączone w tailoringu (EXC-001..005).

4. **Hardening nie wpłynął negatywnie na działanie Apache** — usługa `httpd` pozostała aktywna przez cały proces, reguła `package_httpd_removed` została świadomie wyłączona w tailoringu (Apache jest wymagany przez środowisko laboratoryjne).

5. **Co zrobić inaczej następnym razem:**
   - Skonfigurować `AllowUsers`/`AllowGroups` w SSH już na etapie instalacji systemu.
   - Ustawić hasło GRUB2 (`grub2-setpassword`) jako krok manualny przed uruchomieniem Ansible.
   - Zdecydować się na jedną architekturę logowania (journald *albo* rsyslog) przed hardeningiem, a nie po.
   - Zaplanować docelowy layout partycji przed instalacją systemu — naprawienie reguł partycji post-factum jest praktycznie niemożliwe bez reinstalacji.

---

### Notatki z realizacji

```
# Twoje notatki:

```
