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

### Reguły do wyłączenia (disable)

| Rule ID | Opis | Uzasadnienie wyłączenia |
|---------|------|-------------------------|
| *(z raportu)* | Osobna partycja `/tmp` | System zainstalowany, przebudowa dysku poza zakresem |
| *(z raportu)* | Osobna partycja `/var` | j.w. |
| *(z raportu)* | Osobna partycja `/var/log` | j.w. |
| *(z raportu)* | Osobna partycja `/var/log/audit` | j.w. |
| *(z raportu)* | Osobna partycja `/home` | j.w. |

*(Uzupełnij na podstawie swojego raportu)*

### Reguły z modyfikowanymi wartościami (refine-value)

| Rule ID | Parametr | Wartość domyślna | Nasza wartość | Uzasadnienie |
|---------|----------|------------------|---------------|--------------|
| *(z raportu)* | Min. długość hasła | 8 | 14 | Wymóg polityki firmowej |
| *(z raportu)* | Max. wiek hasła | 365 | 90 | Zgodność z CIS L2 |

*(Uzupełnij na podstawie swoich decyzji)*

## Krok 2: Utworzenie tailoring file

### Metoda A: Generowanie z oscap

```bash
# Wygeneruj bazowy tailoring file z profilu
sudo oscap xccdf generate tailoring \
  --profile cis_server_l1 \
  --new-profile-id cis_server_l1_tailored \
  --output /root/openscap-reports/tailoring.xml \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

### Metoda B: scap-workbench (GUI)

Jeśli masz dostęp do GUI, `scap-workbench` pozwala graficznie:
- Odznaczać reguły
- Modyfikować wartości
- Eksportować tailoring file

```bash
sudo dnf install -y scap-workbench
scap-workbench  # wymaga X11/Wayland
```

## Krok 3: Edycja tailoring file

Tailoring file to XML. Modyfikacje robimy ręcznie lub skryptem:

```bash
# Podgląd struktury
less /root/openscap-reports/tailoring.xml
```

Kluczowe elementy XML:

```xml
<!-- Wyłączenie reguły -->
<xccdf:select idref="xccdf_org.ssgproject.content_rule_partition_for_tmp" selected="false"/>

<!-- Zmiana wartości parametru -->
<xccdf:refine-value idref="xccdf_org.ssgproject.content_value_var_password_minlen" selector="14"/>
```

## Krok 4: Weryfikacja tailoring file

```bash
# Walidacja — sprawdź czy plik jest poprawny
oscap info /root/openscap-reports/tailoring.xml

# Test — uruchom skan z tailoringiem (bez zapisu, szybki test)
sudo oscap xccdf eval \
  --profile cis_server_l1_tailored \
  --tailoring-file /root/openscap-reports/tailoring.xml \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml 2>&1 | tail -5
```

## Krok 5: Użycie tailoring w kolejnych krokach

Od tego momentu wszystkie skany i generowanie remediacji używają flagi
`--tailoring-file`:

```bash
# Scan z tailoringiem
oscap xccdf eval \
  --profile cis_server_l1_tailored \
  --tailoring-file /root/openscap-reports/tailoring.xml \
  ...

# Generowanie fixów z tailoringiem
oscap xccdf generate fix \
  --profile cis_server_l1_tailored \
  --tailoring-file /root/openscap-reports/tailoring.xml \
  ...
```

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
