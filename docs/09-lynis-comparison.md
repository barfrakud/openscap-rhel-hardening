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
# Pełny audyt systemu (z /opt/lynis — instalacja z Git)
cd /opt/lynis
sudo ./lynis audit system

# Logi i raport zapisane automatycznie:
#   /var/log/lynis.log          — szczegółowy log
#   /var/log/lynis-report.dat   — dane maszynowe
```

## Krok 3: Analiza wyników

### Hardening Index

```bash
# Wyciągnij Hardening Index z raportu
grep "hardening_index" /var/log/lynis-report.dat
# hardening_index=72
```

Interpretacja:
- **0-49** — system wymaga znacznego hardeningu
- **50-69** — podstawowy poziom zabezpieczeń
- **70-84** — dobry poziom ← **nasz wynik (72)**
- **85-100** — bardzo dobrze zahardowany

### Sugestie Lynis

```bash
# Lista sugestii do naprawy (28 znalezionych)
grep "suggestion\[\]" /var/log/lynis-report.dat
```

### Ostrzeżenia

```bash
# Lista ostrzeżeń (0 znalezionych)
grep "warning\[\]" /var/log/lynis-report.dat
# (brak wyników — system po hardeningu nie ma ostrzeżeń Lynis)
```

## Krok 4: Porównanie OpenSCAP vs Lynis

### Wyniki na naszym systemie

| Metryka              | OpenSCAP (CIS L1)                    | Lynis 3.1.6                     |
|----------------------|--------------------------------------|----------------------------------|
| Wynik                | 95.45% score (post-hardening)        | Hardening Index: **72**/100      |
| Reguły/testy         | 288 reguł (tailored profile)         | 271 testów wykonanych            |
| Problemy znalezione  | 5 fail                               | 0 warnings, 28 suggestions      |
| Czas skanu           | ~2-3 minuty                          | ~18 sekund                       |
| Format wyniku        | HTML/XML/ARF (formalny, audytowalny) | Tekst + plik .dat (wewnętrzny)   |

### Co znalazł Lynis, a OpenSCAP nie?

| Kategoria Lynis    | Znalezisko                                              | Czy CIS to pokrywa? |
|--------------------|---------------------------------------------------------|---------------------|
| Apache (HTTP)      | Brak `mod_evasive` (ochrona przed DoS)                  | Nie                 |
| Apache (HTTP)      | Brak `modsecurity` (WAF — ochrona przed atakami webowymi)| Nie                |
| Malware            | Brak skanera malware (rkhunter, chkrootkit, OSSEC)      | Nie                 |
| Hardening          | Kompilator (`as`) dostępny dla wszystkich użytkowników   | Nie                 |
| Accounting         | Brak process accounting (`acct`/`sysstat`)               | Nie                 |
| Accounting         | Auditd z pustym rulesetem                                | Częściowo (auditd config) |
| Kernel (sysctl)    | `dev.tty.ldisc_autoload=1` (prefval: 0)                 | Nie                 |
| Kernel (sysctl)    | `kernel.modules_disabled=0` (prefval: 1)                | Nie                 |
| Kernel (sysctl)    | `kernel.sysrq=16` (prefval: 0)                          | Nie                 |
| SSH                | AllowTcpForwarding, X11Forwarding, AllowAgentForwarding  | Nie (CIS nie wymaga)|
| SSH                | Sugestia zmiany portu SSH z 22                           | Nie (security through obscurity)|
| DNS/Name           | Brak FQDN w `/etc/hosts`                                | Nie                 |
| Packages           | Brak narzędzia do automatycznych aktualizacji            | Nie                 |

### Co znalazł OpenSCAP, a Lynis nie?

| Kategoria CIS         | Reguła                                        | Czy Lynis to pokrywa? |
|------------------------|-----------------------------------------------|----------------------|
| Boot & GRUB            | `grub2_password` — hasło bootloadera           | Nie                  |
| Authentication (PAM)   | Szczegółowa konfiguracja faillock, pwhistory   | Częściowo (ogólnie)  |
| SSH                    | `sshd_limit_user_access` (AllowUsers/Groups)   | Nie                  |
| Logging                | journald + rsyslog konflikt (aktywne jednocześnie)| Nie               |
| Logging                | `systemd-journal-upload` (centralny log)        | Częściowo (LOGG-2154)|
| File Integrity         | AIDE: build database, periodic cron checking    | Wykrywa AIDE, nie sprawdza konfiguracji |
| Crypto                 | Custom crypto policy dla CIS                    | Nie                  |
| Partitions             | Formalne reguły CIS z konkretnymi rule ID       | Sugestie (bez pass/fail) |

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

Oba narzędzia uzupełniają się nawzajem:

- **OpenSCAP** jest narzędziem **compliance-driven** — odpowiada na pytanie "czy system
  spełnia wymogi konkretnego standardu?" (CIS, STIG, PCI-DSS). Generuje formalne raporty
  akceptowane przez audytorów i auto-fixy (bash/Ansible). Najlepszy dla środowisk
  wymagających formalnej zgodności.

- **Lynis** jest narzędziem **advisory-driven** — odpowiada na pytanie "co jeszcze można
  poprawić?" Wykrywa problemy spoza zakresu standardów CIS/STIG (WAF, malware scanner,
  kompilatory, dodatkowe sysctl). Szybki (18s vs minuty), nie wymaga profilu. Najlepszy
  jako dodatkowa warstwa weryfikacji.

**W praktyce:** po osiągnięciu 95%+ w OpenSCAP warto uruchomić Lynis, żeby wychwycić
sugestie poza zakresem profilu CIS — w tym przypadku Lynis wskazał 28 dodatkowych
obszarów do poprawy (mod_evasive, modsecurity, malware scanner, dodatkowe sysctl),
których OpenSCAP nie sprawdza.

### Sugestie Lynis — podsumowanie

| Kategoria       | Liczba sugestii | Przykłady                                           |
|-----------------|----------------|-----------------------------------------------------|
| SSH             | 7              | AllowTcpForwarding, MaxSessions, X11Forwarding, Port|
| Partitions      | 3              | /home, /tmp, /var na osobnych partycjach             |
| Apache          | 2              | mod_evasive, modsecurity                             |
| Authentication  | 3              | password hashing rounds, min age, expired accounts   |
| Kernel (sysctl) | 1 (8 detali)   | ldisc_autoload, modules_disabled, sysrq, bpf        |
| Logging         | 1              | Remote syslog                                        |
| Accounting      | 3              | process accounting, sysstat, auditd ruleset          |
| Banners         | 2              | /etc/issue, /etc/issue.net                           |
| Hardening       | 2              | Kompilator, malware scanner                          |
| DNS/Network     | 1              | FQDN w /etc/hosts                                    |
| Packages        | 1              | Automatyczne aktualizacje                            |
| Services        | 1              | systemd-analyze security                             |
| File perms      | 1              | Restrict file permissions                            |
