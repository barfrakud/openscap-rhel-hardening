# LAB_RULES.md — Zasady i metodologia laboratorium

## Cel laboratorium

Nauczyć się praktycznego użycia OpenSCAP do audytu i hardeningu systemu RHEL 10,
udokumentować cały proces i opublikować jako projekt portfolio.

## Metodologia pracy

### Zasada 1: Jeden krok na raz

Każde ćwiczenie wykonujemy sekwencyjnie. Nie przechodzimy do kolejnego kroku,
dopóki poprzedni nie jest ukończony i udokumentowany. Kolejność:

1. Przygotowanie środowiska (VM + sieć + subskrypcja)
2. Instalacja Apache + strona testowa
3. Instalacja OpenSCAP + scap-security-guide
4. Audyt bazowy (baseline scan)
5. Analiza raportu — zrozumienie wyników
6. Tailoring — dostosowanie profilu CIS do środowiska
7. Generowanie remediacji (bash + Ansible) z uwzględnieniem tailoringu
8. Przegląd wygenerowanych fixów — decyzja co aplikujemy
9. Aplikacja hardeningu (quick-wins playbook + wygenerowane fixy)
10. Audyt końcowy (post-hardening scan)
11. Dokumentacja wyjątków (Exception Register)
12. Porównanie wyników i wnioski
13. Audyt Lynis — porównanie narzędzi

### Zasada 2: Dokumentuj wszystko

Każdy krok dokumentujemy w odpowiednim pliku w `docs/`:

- **Komenda** — dokładnie co zostało uruchomione
- **Wynik** — co się stało (output, kody wyjścia)
- **Analiza** — co to oznacza, dlaczego to ważne
- **Decyzja** — co robimy dalej i dlaczego

### Zasada 3: Nie aplikuj na ślepo

Wygenerowane skrypty remediacyjne ZAWSZE przeglądamy przed uruchomieniem.
Dla każdej reguły oceniamy:

- Czy fix jest bezpieczny dla naszego Apache?
- Czy rozumiemy co ten fix zmienia?
- Czy jest to zmiana odwracalna?

Jeśli nie rozumiemy reguły — szukamy wyjaśnienia w dokumentacji CIS.

### Zasada 4: Zachowaj porównywalność

Oba skany (bazowy i końcowy) muszą używać:

- Tego samego profilu (`cis_server_l1`)
- Tego samego pliku DataStream (`ssg-rhel10-ds.xml`)
- Tych samych parametrów `oscap`

Dzięki temu porównanie wyników jest miarodajne.

### Zasada 5: Commit po każdym milestonie

Po zakończeniu każdego głównego kroku robimy commit z opisem:

```
docs: add baseline audit results and analysis
feat: add remediation scripts for CIS L1
docs: add post-hardening scan comparison
```

## Profil bezpieczeństwa

### Wybrany profil: CIS Level 1 — Server

- **Standard:** CIS Benchmark for RHEL 10
- **Profil ID w SSG:** `cis_server_l1`
- **Poziom:** Level 1 (podstawowy hardening, minimalne ryzyko wpływu na funkcjonalność)
- **Cel:** Serwer produkcyjny z usługą webową (Apache)

### Dlaczego CIS L1 a nie STIG?

- CIS L1 jest bardziej uniwersalny i stosowany komercyjnie
- STIG jest bardziej restrykcyjny i specyficzny dla sektora rządowego USA
- Dla celów edukacyjnych CIS L1 lepiej pokazuje cykl audit → fix → re-audit
- Po opanowaniu CIS L1 można rozszerzyć ćwiczenie o STIG jako dodatkowe wyzwanie

## Środowisko laboratorium

### Wymagania VM

| Parametr          | Wartość                          |
|-------------------|----------------------------------|
| OS                | RHEL 10 (Minimal Install)        |
| RAM               | min. 2 GB                        |
| Dysk              | min. 20 GB                       |
| Sieć              | NAT lub Bridge (dostęp do repo)  |
| SELinux           | Enforcing (domyślnie)            |
| Firewalld         | Włączony (domyślnie)             |
| Subskrypcja       | Red Hat Developer (darmowa)       |

### Usługi na VM

| Usługa   | Cel                                       |
|----------|-------------------------------------------|
| Apache   | Testowy web server ze stroną statyczną     |
| SSH      | Zdalny dostęp do VM                        |
| Firewalld| Firewall — część audytowanych reguł        |

## Kryteria sukcesu

Laboratorium uznajemy za ukończone, gdy:

- [x] Czysty RHEL 10 zainstalowany i skonfigurowany
- [ ] Apache działa i serwuje stronę testową
- [ ] OpenSCAP zainstalowany i działa
- [ ] Audyt bazowy wykonany, raport zapisany
- [ ] Raport przeanalizowany, kluczowe faile opisane
- [ ] Tailoring file utworzony i zwalidowany
- [ ] Remediacja wygenerowana i przejrzana (z tailoringiem)
- [ ] Hardening zastosowany (quick-wins playbook + wybrane reguły)
- [ ] Audyt końcowy wykonany (z tailoringiem)
- [ ] Exception Register udokumentowany
- [ ] Porównanie baseline vs post-hardening udokumentowane
- [ ] Lynis audit uruchomiony i porównany z OpenSCAP
- [ ] Wszystko w repo na GitHub z sensowną historią commitów

## Kategorie reguł CIS — na co zwracamy uwagę

Podczas analizy raportu grupujemy wyniki w kategorie:

| Kategoria                    | Przykłady reguł                                      |
|------------------------------|-------------------------------------------------------|
| **Filesystem & Partitions**  | Osobne partycje /tmp, /var, /var/log, noexec flags    |
| **Boot & GRUB**              | Hasło GRUB, uprawnienia plików bootloadera            |
| **Kernel & Sysctl**          | ASLR, IP forwarding, SYN cookies                      |
| **Authentication**           | Polityka haseł, PAM, blokada kont, su                 |
| **SSH**                      | PermitRootLogin, MaxAuthTries, ciphers, MACs           |
| **Network**                  | Firewalld, IPv6, DCCP/SCTP/RDS disabled               |
| **Logging & Auditing**       | rsyslog, auditd, logrotate                            |
| **Filesystem Permissions**   | Uprawnienia /etc/passwd, /etc/shadow, SUID/SGID       |
| **Services**                 | Wyłączenie niepotrzebnych usług (avahi, cups)          |
| **Cron & At**                | Uprawnienia crontab, restrykcja dostępu               |

## Notatki i konwencje

- Język dokumentacji: **polski**
- Język kodu/komend/skryptów: **angielski** (standard branżowy)
- Komentarze w skryptach: **angielski**
- Nazwy plików: **angielski**, kebab-case
- Raporty HTML nie trafiają do repo (gitignore)
- Screenshoty raportów trafiają do `assets/`
