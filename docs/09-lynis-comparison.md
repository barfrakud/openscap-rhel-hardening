# 09 — Porównanie z Lynis

## Cel

Uruchomienie audytu Lynis na tym samym systemie (po hardeningu OpenSCAP)
i porównanie podejść. Pokazuje znajomość obu narzędzi i umiejętność
oceny, kiedy które jest bardziej odpowiednie.

## Czym jest Lynis?

Lynis to open-source'owe narzędzie do audytu bezpieczeństwa systemów Unix/Linux.
W odróżnieniu od OpenSCAP:

- **Nie wymaga profilu** — skanuje "wszystko co znajdzie"
- **Heurystyczne** — ocenia stan systemu na podstawie własnej bazy reguł
- **Hardening Index** — wynik 0-100 (im wyżej, tym lepiej)
- **Advisory** — podpowiada co naprawić, ale nie generuje auto-fixów
- **Multi-platform** — Linux, macOS, FreeBSD, inne Unixy

## Krok 1: Instalacja Lynis

```bash
# Opcja A: Z repozytorium EPEL
sudo dnf install -y epel-release
sudo dnf install -y lynis

# Opcja B: Z Git (najnowsza wersja)
cd /opt
sudo git clone https://github.com/CISOfy/lynis.git
cd lynis
sudo ./lynis audit system
```

## Krok 2: Uruchomienie audytu

```bash
# Pełny audyt systemu
sudo lynis audit system --no-colors 2>&1 | tee /root/openscap-reports/lynis-report.txt

# Tylko podsumowanie
sudo lynis audit system --quick
```

## Krok 3: Analiza wyników

### Hardening Index

```bash
# Wyciągnij Hardening Index z raportu
grep "Hardening index" /root/openscap-reports/lynis-report.txt
```

Interpretacja:
- **0-49** — system wymaga znacznego hardeningu
- **50-69** — podstawowy poziom zabezpieczeń
- **70-84** — dobry poziom
- **85-100** — bardzo dobrze zahardowany

### Sugestie Lynis

```bash
# Lista sugestii do naprawy
grep "suggestion\[\]" /var/log/lynis-report.dat | head -20
```

### Ostrzeżenia

```bash
# Lista ostrzeżeń
grep "warning\[\]" /var/log/lynis-report.dat
```

## Krok 4: Porównanie OpenSCAP vs Lynis

### Wyniki na naszym systemie

| Metryka              | OpenSCAP (CIS L1)      | Lynis                  |
|----------------------|------------------------|------------------------|
| Wynik                | *(score %)*            | *(Hardening Index)*    |
| Reguły sprawdzone    | *(liczba)*             | *(liczba testów)*      |
| Problemy znalezione  | *(fail count)*         | *(warnings + suggestions)* |
| Czas skanu           | *(sekundy)*            | *(sekundy)*            |

### Co znalazł Lynis, a OpenSCAP nie?

| Kategoria Lynis        | Znalezisko                    | Czy CIS to pokrywa? |
|------------------------|-------------------------------|---------------------|
| *(np. Malware)*        | *(opis)*                      | *(Tak/Nie)*         |
| *(np. Networking)*     | *(opis)*                      | *(Tak/Nie)*         |
| *(np. Software)*       | *(opis)*                      | *(Tak/Nie)*         |

*(Uzupełnij na podstawie swoich wyników)*

### Co znalazł OpenSCAP, a Lynis nie?

| Kategoria CIS          | Reguła                        | Czy Lynis to pokrywa? |
|------------------------|-------------------------------|----------------------|
| *(np. Partitions)*     | *(opis)*                      | *(Tak/Nie)*          |
| *(np. PAM)*            | *(opis)*                      | *(Tak/Nie)*          |

*(Uzupełnij na podstawie swoich wyników)*

## Wnioski

### Kiedy użyć OpenSCAP?

- Formalny audyt compliance (CIS, STIG, PCI-DSS)
- Wymagany raport dla audytora zewnętrznego
- Środowisko RHEL/CentOS/Fedora
- Potrzeba automatycznej remediacji (bash/Ansible)
- Integracja z Red Hat Satellite/Insights

### Kiedy użyć Lynis?

- Szybka ocena bezpieczeństwa nowego serwera
- System spoza ekosystemu Red Hat (Debian, Ubuntu, macOS)
- Odkrywanie problemów, których profile SCAP nie pokrywają
- Audyt wewnętrzny bez wymagań formalnych
- Dodatkowa warstwa weryfikacji po hardeningu

### Rekomendacja

*(Opisz własnymi słowami, jak widzisz zastosowanie obu narzędzi
w codziennej pracy administratora)*

---

### Notatki z realizacji

```
# Twoje notatki:

```
