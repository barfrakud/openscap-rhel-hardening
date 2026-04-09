# 04 — Tailoring (dostosowanie profilu CIS)

## Cel

Utworzenie tailoring file — dostosowanego profilu CIS Level 1 Server,
który uwzględnia specyfikę naszego środowiska. W komercyjnych wdrożeniach
**nigdy** nie stosuje się profilu "as-is" — zawsze tworzy się tailoring
z udokumentowanym uzasadnieniem każdej modyfikacji.

## Dlaczego tailoring?

| Powód                          | Przykład                                           |
|--------------------------------|----------------------------------------------------|
| Reguła niewykonalna technicznie| Osobna partycja `/tmp` na istniejącym systemie     |
| Reguła nie dotyczy środowiska  | IPv6 disabled — gdy sieć nie używa IPv6            |
| Firma ma własne wartości       | Min. długość hasła 14 zamiast domyślnych 8         |
| Wymóg audytora                 | Każde wyłączenie reguły musi mieć uzasadnienie     |

## Krok 1: Analiza wyników baseline

Na podstawie raportu z kroku 03 zidentyfikuj reguły do modyfikacji:

### Reguły do wyłączenia (disable) — 3 reguły

**Tailoring (disable) vs. Exception Register — kluczowe rozróżnienie:**
- **Disable w tailoringu** = reguła *nie dotyczy* tego środowiska lub roli serwera.
  Reguła znika z raportu (`notselected`) — OpenSCAP jej nie sprawdza.
- **Exception Register (krok 07)** = reguła *dotyczy* nas, ale nie możemy jej spełnić.
  Reguła nadal `fail` w raporcie — z formalnym uzasadnieniem i compensating controls.

| Rule ID | Opis | Powód wyłączenia |
|---------|------|------------------|
| `xccdf_org.ssgproject.content_rule_partition_for_tmp` | Ensure /tmp is a separate partition | VM zainstalowana na jednej partycji; przebudowa układu dysku = pełna reinstalacja systemu — poza zakresem laboratorium |
| `xccdf_org.ssgproject.content_rule_partition_for_var` | Ensure /var is a separate partition | j.w. |
| `xccdf_org.ssgproject.content_rule_package_httpd_removed` | Ensure httpd is not installed | CIS rekomenduje usunięcie zbędnych usług sieciowych — Apache jest *celowo* zainstalowaną usługą w tym środowisku (rola: serwer webowy) |

> **Uwaga:** Reguły `partition_for_var_log`, `partition_for_var_log_audit` i `partition_for_home`
> **nie występują w CIS Level 1** (są częścią Level 2) — nie są sprawdzane przez wybrany profil.
> Do **Exception Register** (krok 07) trafiają realne reguły CIS L1, które failują ale mają
> uzasadnienie biznesowe: `grub2_password` (EXC-001), AIDE/FIM (EXC-002), `sshd_limit_user_access` (EXC-003).

### Reguły z modyfikowanymi wartościami (refine-value) — 3 reguły

| Value ID | Parametr | Wartość domyślna | Nasza wartość | Uzasadnienie |
|----------|----------|------------------|---------------|--------------|
| `xccdf_org.ssgproject.content_value_var_password_minlen` | Min. długość hasła | 8 znaków | 14 | Wymóg przykładowej polityki firmowej |
| `xccdf_org.ssgproject.content_value_var_accounts_maximum_age_login_defs` | Max. wiek hasła | 365 dni | 90 | Alignment z wymaganiami CIS L2 |
| `xccdf_org.ssgproject.content_value_var_accounts_tmout` | Timeout nieaktywnej sesji | 600 s (10 min) | 900 s (15 min) | Bardziej praktyczny dla sesji admina; wartość celowo poluzowana |

## Krok 2: Utworzenie tailoring file

Na RHEL 10 tailoring files tworzy się narzędziem `autotailor` z pakietu `openscap-utils`.
`oscap xccdf generate tailoring` oraz `scap-workbench` nie są dostępne w tej wersji.

### Weryfikacja pakietów

```bash
rpm -q openscap-utils openscap-scanner scap-security-guide
```

### Generowanie tailoring file

```bash
sudo autotailor \
  --unselect=xccdf_org.ssgproject.content_rule_partition_for_tmp \
  --unselect=xccdf_org.ssgproject.content_rule_partition_for_var \
  --unselect=xccdf_org.ssgproject.content_rule_package_httpd_removed \
  --var-value=xccdf_org.ssgproject.content_value_var_password_minlen=14 \
  --var-value=xccdf_org.ssgproject.content_value_var_accounts_maximum_age_login_defs=90 \
  --var-value=xccdf_org.ssgproject.content_value_var_accounts_tmout=900 \
  --output /var/log/openscap/tailoring.xml \
  --tailored-profile-id cis_server_l1_tailored \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml \
  cis_server_l1
```

## Krok 3: Weryfikacja wygenerowanego tailoring file

`autotailor` generuje plik XML automatycznie. Warto go przejrzeć, żeby zrozumieć strukturę:

```bash
# Podgląd wygenerowanego pliku
cat /var/log/openscap/tailoring.xml
```

Rzeczywista struktura wygenerowanego pliku wygląda następująco:

```xml
<?xml version="1.0" ?>
<ns0:Tailoring xmlns:ns0="http://checklists.nist.gov/xccdf/1.2" id="xccdf_auto_tailoring_default">
  <ns0:benchmark href="file:///usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml"/>
  <ns0:version time="2026-04-09T12:32:09">1</ns0:version>
  <ns0:Profile id="xccdf_org.ssgproject.content_profile_cis_server_l1_tailored"
               extends="xccdf_org.ssgproject.content_profile_cis_server_l1">
    <!-- Reguły wyłączone — selected="false" -->
    <ns0:select idref="xccdf_org.ssgproject.content_rule_package_httpd_removed" selected="false"/>
    <ns0:select idref="xccdf_org.ssgproject.content_rule_partition_for_tmp" selected="false"/>
    <ns0:select idref="xccdf_org.ssgproject.content_rule_partition_for_var" selected="false"/>
    <!-- Wartości ustawione bezpośrednio -->
    <ns0:set-value idref="xccdf_org.ssgproject.content_value_var_accounts_maximum_age_login_defs">90</ns0:set-value>
    <ns0:set-value idref="xccdf_org.ssgproject.content_value_var_accounts_tmout">900</ns0:set-value>
    <ns0:set-value idref="xccdf_org.ssgproject.content_value_var_password_minlen">14</ns0:set-value>
  </ns0:Profile>
</ns0:Tailoring>
```

**Co tu widzimy — mechanizm nowego profilu:**

- `autotailor` tworzy **nowy profil XCCDF** (`cis_server_l1_tailored`), który **dziedziczy** z profilu bazowego
  (`extends="...cis_server_l1"`). Nowy profil zawiera tylko *różnice* względem oryginału.
- Pełne ID nowego profilu: `xccdf_org.ssgproject.content_profile_cis_server_l1_tailored` —
  `autotailor` automatycznie dodał prefix `xccdf_org.ssgproject.content_profile_`.
- Wartości są zapisane jako `set-value` (bezpośrednia wartość), nie `refine-value` z selectorem.
- OpenSCAP przy skanowaniu z `--tailoring-file` nakłada ten profil na DataStream —
  wyłączone reguły nie pojawiają się w raporcie (`notselected`), zmienione wartości zastępują domyślne.

## Krok 4: Weryfikacja tailoring file

```bash
# Walidacja — sprawdź czy plik jest poprawny
oscap info /var/log/openscap/tailoring.xml

# Test — skan z zapisem wyników do XML (tymczasowy plik)
sudo oscap xccdf eval \
  --profile cis_server_l1_tailored \
  --tailoring-file /var/log/openscap/tailoring.xml \
  --results /tmp/tailoring-test.xml \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml > /dev/null 2>&1

# Weryfikacja — sprawdź status wyłączonych reguł w wynikach XML
grep -E "partition_for_tmp|partition_for_var|package_httpd_removed" /tmp/tailoring-test.xml

# Uwaga: reguły notselected NIE pojawiają się w stdout oscap (są pomijane),
# dlatego weryfikacja wymaga pliku wynikowego XML.
```

## Krok 5: Użycie tailoring w kolejnych krokach

Tailoring file jest gotowy. Od tego momentu każda komenda `oscap` używa dwóch flag:
`--profile cis_server_l1_tailored` i `--tailoring-file /var/log/openscap/tailoring.xml`.

## W środowisku komercyjnym

- Tailoring file jest **wersjonowany** w Git razem z dokumentacją
- Każda zmiana w tailoringu wymaga **akceptacji security teamu**
- Tailoring jest **per rola serwera** (web, db, app mają różne profile)
- Audytorzy sprawdzają tailoring file — wyłączone reguły muszą mieć uzasadnienie
- Tailoring file jest dystrybuowany przez Satellite/Ansible na wszystkie hosty

---

### Notatki z realizacji

```
# Twoje notatki:

```
