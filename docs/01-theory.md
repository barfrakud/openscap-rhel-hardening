# 01 — Teoria: OpenSCAP, standard SCAP i profile bezpieczeństwa

## Co to jest SCAP?

SCAP (Security Content Automation Protocol) to zestaw standardów opracowanych
przez NIST (National Institute of Standards and Technology) do automatycznego
zarządzania bezpieczeństwem systemów IT.

SCAP definiuje:

- **Jak opisywać** reguły bezpieczeństwa (w formacie maszynowym)
- **Jak sprawdzać** systemy pod kątem zgodności z tymi regułami
- **Jak raportować** wyniki audytu

## Składniki SCAP

| Komponent | Nazwa pełna                                      | Rola                                      |
|-----------|--------------------------------------------------|--------------------------------------------|
| XCCDF     | Extensible Configuration Checklist Description   | Opis reguł — "co sprawdzić"               |
| OVAL      | Open Vulnerability and Assessment Language       | Testy techniczne — "jak sprawdzić"         |
| CPE       | Common Platform Enumeration                      | Identyfikacja platformy (np. RHEL 10)      |
| CVE       | Common Vulnerabilities and Exposures             | Identyfikacja znanych podatności           |
| CCE       | Common Configuration Enumeration                 | Identyfikacja ustawień konfiguracyjnych    |
| ARF       | Asset Reporting Format                           | Format wyników audytu                      |
| DataStream| SCAP DataStream                                  | Wszystko w jednym pliku XML                |

## Co to jest OpenSCAP?

OpenSCAP to open-source'owa implementacja standardu SCAP. Składa się z:

- **`oscap`** — narzędzie CLI do skanowania i generowania raportów
- **`scap-security-guide` (SSG)** — paczka z gotowymi profilami dla różnych OS
- **`scap-workbench`** — GUI do przeglądania profili i uruchamiania skanów
- **`oscap-anaconda-addon`** — integracja z instalatorem RHEL

## Profile bezpieczeństwa

Profil to zbiór reguł odpowiadający konkretnemu standardowi.

### CIS Benchmark (Center for Internet Security)

- Organizacja non-profit, niezależna od dostawców
- Benchmarki dostępne dla większości OS i platform chmurowych
- Dwa poziomy:
  - **Level 1** — podstawowy hardening, niskie ryzyko wpływu na funkcjonalność
  - **Level 2** — zaawansowany hardening, może wymagać testów aplikacji
- Popularne w sektorze komercyjnym, bankach, ubezpieczeniach

### DISA STIG (Security Technical Implementation Guide)

- Opracowany przez Departament Obrony USA (DoD)
- Obowiązkowy dla systemów rządowych i wojskowych USA
- Trzy kategorie ważności:
  - **CAT I (High)** — bezpośrednie zagrożenie, natychmiastowa naprawa
  - **CAT II (Medium)** — może prowadzić do kompromitacji
  - **CAT III (Low)** — pogarsza postawę bezpieczeństwa
- Bardziej restrykcyjny niż CIS

### Inne profile w SSG

- **PCI-DSS** — dla systemów przetwarzających dane kart płatniczych
- **HIPAA** — dla sektora ochrony zdrowia (USA)
- **ANSSI** — francuski standard rządowy
- **E8 (Essential Eight)** — australijski standard

## Jak działa skan OpenSCAP?

```
                    ┌─────────────────┐
                    │  DataStream XML  │
                    │  (ssg-rhel10-ds) │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Wybór profilu   │
                    │  (cis_server_l1) │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   oscap xccdf   │
                    │     eval        │
                    │                 │
                    │  Dla każdej     │
                    │  reguły:        │
                    │  - czyta XCCDF  │
                    │  - uruchamia    │
                    │    test OVAL    │
                    │  - zapisuje     │
                    │    wynik        │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼───┐  ┌──────▼─────┐  ┌─────▼──────┐
     │ Raport HTML │  │ Wyniki ARF │  │ Wyniki XML │
     │ (człowiek)  │  │ (maszyna)  │  │ (maszyna)  │
     └─────────────┘  └────────────┘  └────────────┘
```

## Metody hardeningu

### 1. Podczas instalacji (Anaconda + oscap-anaconda-addon)

Najczystsza metoda — system rodzi się już zhardowany.
W kickstarcie: `%addon com_redhat_oscap` z wybranym profilem.

### 2. Automatyczna remediacja po instalacji

OpenSCAP generuje skrypty naprawcze:

- **Bash:** `oscap xccdf generate fix --fix-type bash`
- **Ansible:** `oscap xccdf generate fix --fix-type ansible`

Można generować fixy dla pełnego profilu lub tylko dla reguł które failowały.

### 3. Gotowe Ansible role z SSG

Pakiet `scap-security-guide` zawiera gotowe playbooki w:
`/usr/share/scap-security-guide/ansible/`

### 4. Ręczna remediacja

Przeglądanie raportu reguła po regule i selektywne stosowanie fixów.
Najbezpieczniejsza metoda dla systemów produkcyjnych.

### 5. Tailoring (dostosowanie profilu)

Tworzenie tailoring file — nadpisywanie wartości reguł, wyłączanie reguł
nieistotnych dla danego środowiska.

## OpenSCAP vs Lynis — porównanie

| Cecha                | OpenSCAP                           | Lynis                              |
|----------------------|------------------------------------|------------------------------------|
| Podejście            | Compliance-driven (pass/fail)      | Advisory-driven (scoring)          |
| Standardy            | XCCDF/OVAL (formalne)              | Własna baza reguł                  |
| Profile              | CIS, STIG, PCI-DSS...             | Uniwersalny (jeden skan)           |
| Wynik                | Zgodność z profilem (%)            | Hardening Index (0-100)            |
| Raport               | HTML/XML/ARF (audytowalny)         | Tekst + sugestie                   |
| Remediation          | Generuje bash/Ansible automatycznie| Podpowiedzi, brak auto-fixów       |
| Wsparcie Red Hat     | Oficjalne                          | Community                          |
| Złożoność            | Wyższa (standardy, profile, XML)   | Niższa (zainstaluj i uruchom)      |
| Najlepszy dla        | Audyty formalne, compliance        | Szybka ocena, hardening ogólny     |
| Wieloplatformowość   | Linux (głównie RHEL/CentOS/Fedora) | Linux, macOS, Unix                 |

**Kiedy co wybrać?**

- Audytor pyta "czy system jest zgodny z CIS?" → **OpenSCAP**
- Chcesz szybko ocenić bezpieczeństwo serwera → **Lynis**
- W praktyce → używaj obu, uzupełniają się nawzajem
