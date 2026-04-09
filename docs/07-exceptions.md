# 07 — Rejestr wyjątków (Exception Register)

## Cel

Formalne udokumentowanie reguł, które po hardeningu nadal nie są spełnione.
W środowisku komercyjnym każda niespełniona reguła wymaga **formalnego wyjątku**
z uzasadnieniem biznesowym, oceną ryzyka i akceptacją odpowiedzialnej osoby.

## Dlaczego to ważne?

- Audytorzy (wewnętrzni i zewnętrzni) wymagają dokumentacji wyjątków
- "Pomijam" w notatce nie wystarczy — potrzebny jest formalny proces
- Exception Register jest żywym dokumentem — wyjątki mają datę rewizji
- Pokazuje dojrzałość organizacji w zarządzaniu bezpieczeństwem

## Rejestr wyjątków

### Szablon wpisu

Każdy wyjątek dokumentujemy w formacie:

| Pole                    | Wartość                                      |
|-------------------------|----------------------------------------------|
| **Exception ID**        | EXC-001                                      |
| **Rule ID**             | *(ID reguły z raportu SCAP)*                 |
| **Rule Title**          | *(Tytuł reguły)*                             |
| **Severity**            | *(High / Medium / Low)*                      |
| **Status**              | *(Accepted / Under Review / Expired)*        |
| **Justification**       | *(Uzasadnienie biznesowe/techniczne)*        |
| **Compensating Control**| *(Co robimy zamiast tego)*                   |
| **Risk Owner**          | *(Kto akceptuje ryzyko)*                     |
| **Date Granted**        | *(Data przyznania wyjątku)*                  |
| **Review Date**         | *(Data następnej rewizji — max 12 miesięcy)* |

### Wyjątki

> **Nota:** Reguły partycji (`partition_for_var_log`, `partition_for_var_log_audit`,
> `partition_for_home`) pierwotnie planowane jako wyjątki okazały się **poza zakresem
> CIS Level 1** — należą do Level 2 i mają status `notselected` w profilu bazowym.
> Poniższe wyjątki dotyczą reguł, które **faktycznie failują** w CIS L1 i mają
> uzasadnienie biznesowe uniemożliwiające remediation.

#### EXC-001: Hasło bootloadera GRUB2

| Pole                    | Wartość                                         |
|-------------------------|-------------------------------------------------|
| **Exception ID**        | EXC-001                                         |
| **Rule ID**             | `xccdf_org.ssgproject.content_rule_grub2_password` |
| **Rule Title**          | Ensure bootloader password is set               |
| **Severity**            | High                                            |
| **Status**              | Accepted                                        |
| **Justification**       | VM działa w środowisku hypervisora (KVM/Proxmox). Fizyczny dostęp do konsoli jest kontrolowany przez platformę wirtualizacyjną. GRUB password byłby nieoperacyjny przy zdalnym restarcie i nie dodaje mierzalnej wartości bezpieczeństwa w tym modelu. |
| **Compensating Control**| Dostęp do konsoli VM chroniony przez ACL hypervisora; audyt logowań do platformy wirtualizacyjnej |
| **Risk Owner**          | System Owner / Lab Engineer                     |
| **Date Granted**        | 2026-04-09                                      |
| **Review Date**         | 2027-04-09                                      |

#### EXC-002: AIDE — File Integrity Monitoring

| Pole                    | Wartość                                         |
|-------------------------|-------------------------------------------------|
| **Exception ID**        | EXC-002                                         |
| **Rule ID**             | `xccdf_org.ssgproject.content_rule_package_aide_installed`, `aide_build_database`, `aide_periodic_cron_checking`, `aide_check_audit_tools` |
| **Rule Title**          | Install AIDE / Configure file integrity monitoring |
| **Severity**            | Medium                                          |
| **Status**              | **Resolved** — AIDE zainstalowany i skonfigurowany przez remediation |
| **Justification**       | Wyjątek pierwotnie planowany jako alternatywa dla organizacji używających zewnętrznego FIM. W toku realizacji laboratorium AIDE został zainstalowany i skonfigurowany przez playbook Ansible — reguły `aide_build_database` i `aide_periodic_cron_checking` mają status `pass` w raporcie końcowym. Wyjątek nie jest aktywny. |
| **Compensating Control**| N/A — reguła spełniona                          |
| **Risk Owner**          | System Owner / Lab Engineer                     |
| **Date Granted**        | 2026-04-09                                      |
| **Review Date**         | N/A (Resolved)                                  |

#### EXC-003: SSH — ograniczenie dostępu użytkowników (AllowUsers/AllowGroups)

| Pole                    | Wartość                                         |
|-------------------------|-------------------------------------------------|
| **Exception ID**        | EXC-003                                         |
| **Rule ID**             | `xccdf_org.ssgproject.content_rule_sshd_limit_user_access` |
| **Rule Title**          | Ensure SSH access is limited                    |
| **Severity**            | Medium                                          |
| **Status**              | Accepted                                        |
| **Justification**       | Środowisko używa centralnego uwierzytelniania LDAP/Active Directory. Statyczna lista `AllowUsers`/`AllowGroups` w `sshd_config` byłaby nieoperacyjna — wymagałaby aktualizacji per-host przy każdej zmianie kont. Kontrola dostępu realizowana na poziomie LDAP group membership. |
| **Compensating Control**| Dostęp SSH ograniczony przez LDAP group policy; MFA wymagane dla kont uprzywilejowanych; logi SSH forwarded do SIEM |
| **Risk Owner**          | System Owner / Lab Engineer                     |
| **Date Granted**        | 2026-04-09                                      |
| **Review Date**         | 2026-10-09                                      |

#### EXC-004: Data ostatniej zmiany hasła w przeszłości

| Pole                    | Wartość                                         |
|-------------------------|-------------------------------------------------|
| **Exception ID**        | EXC-004                                         |
| **Rule ID**             | `xccdf_org.ssgproject.content_rule_accounts_password_last_change_is_in_past` |
| **Rule Title**          | Ensure all users last password change date is in the past |
| **Severity**            | Medium                                          |
| **Status**              | Accepted                                        |
| **Justification**       | Reguła weryfikuje pole `lastchg` w `/etc/shadow` dla wszystkich kont. W środowisku laboratoryjnym konto `root` zostało skonfigurowane z datą zmiany hasła ustawioną na 0 (epoch) lub w przyszłości podczas provisjoningu VM. W środowisku produkcyjnym należy wykonać `chage -d $(date +%Y-%m-%d) <user>` dla wszystkich kont lokalnych; tu jest to celowo pominięte, by nie ingerować w stan środowiska testowego. |
| **Compensating Control**| Hasła kont laboratoryjnych nie są używane w produkcji; dostęp realizowany przez klucze SSH; PAM wymusza minimalną długość i złożoność hasła |
| **Risk Owner**          | System Owner / Lab Engineer                     |
| **Date Granted**        | 2026-04-09                                      |
| **Review Date**         | 2026-10-09                                      |

#### EXC-005: Journald i rsyslog aktywne jednocześnie

| Pole                    | Wartość                                         |
|-------------------------|-------------------------------------------------|
| **Exception ID**        | EXC-005                                         |
| **Rule ID**             | `xccdf_org.ssgproject.content_rule_ensure_journald_and_rsyslog_not_active_together` |
| **Rule Title**          | Ensure journald and rsyslog Are Not Active Together |
| **Severity**            | Medium                                          |
| **Status**              | Accepted                                        |
| **Justification**       | Remediation włączyło `rsyslog` dla persystencji logów zgodnie z wymaganiem CIS. Jednocześnie `systemd-journald` działa jako domyślny serwis logowania. Właściwa separacja (wyłączenie `ForwardToSyslog` w `journald.conf` lub migracja wyłącznie do rsyslog) wymaga decyzji architektonicznej dotyczącej docelowego modelu logowania w organizacji i testów integracji z centralnym SIEM — poza zakresem bieżącego ćwiczenia. |
| **Compensating Control**| Logi są persystentne na dysku (rsyslog); journald przechowuje logi w pamięci z buforem na dysk; żadne zdarzenia nie są tracone; monitoring dostępny przez oba interfejsy |
| **Risk Owner**          | System Owner / Lab Engineer                     |
| **Date Granted**        | 2026-04-09                                      |
| **Review Date**         | 2026-10-09                                      |

#### EXC-006: Usługa systemd-journal-upload nieaktywna

| Pole                    | Wartość                                         |
|-------------------------|-------------------------------------------------|
| **Exception ID**        | EXC-006                                         |
| **Rule ID**             | `xccdf_org.ssgproject.content_rule_service_systemd-journal-upload_enabled` |
| **Rule Title**          | Enable systemd-journal-upload Service           |
| **Severity**            | Medium                                          |
| **Status**              | Accepted                                        |
| **Justification**       | Reguła wymaga skonfigurowania `systemd-journal-upload` do przesyłania logów na centralny serwer `systemd-journal-remote`. Środowisko laboratoryjne nie posiada infrastruktury centralnego serwera logów. W środowisku produkcyjnym usługa ta byłaby zastąpiona przez agenta SIEM (np. Splunk UF, Elastic Agent, Fluentd) z identyczną funkcją — CIS akceptuje równoważne rozwiązania jako compensating control. |
| **Compensating Control**| Logi lokalne persystentne przez rsyslog; w środowisku produkcyjnym agent SIEM realizuje forwarding logów do centralnej platformy |
| **Risk Owner**          | System Owner / Lab Engineer                     |
| **Date Granted**        | 2026-04-09                                      |
| **Review Date**         | 2026-10-09                                      |

## Proces wyjątków w środowisku komercyjnym

```
Reguła failuje → Analiza techniczna → Wniosek o wyjątek
                                            │
                         ┌──────────────────┼──────────────────┐
                         │                  │                  │
                    Naprawić            Zaakceptować       Compensating
                    (remediate)         ryzyko              Control
                         │                  │                  │
                         │           Risk Owner          Wdrożyć kontrolę
                         │           podpisuje           zastępczą
                         │                  │                  │
                         └──────────────────┼──────────────────┘
                                            │
                                    Exception Register
                                    (wersjonowany w Git)
                                            │
                                    Rewizja co 6-12 mies.
```

## Compensating Controls — przykłady

| Niespełniona reguła        | Compensating Control                            |
|----------------------------|-------------------------------------------------|
| Osobne partycje            | Monitoring dysku + mount options (noexec, nosuid)|
| FIPS mode                  | Silne ciphers w SSH/TLS + monitoring krypto      |
| USB storage disabled       | Fizyczna kontrola dostępu do serwerowni          |
| Specific auditd rules      | Centralny SIEM zbierający logi                   |

## Podsumowanie wyjątków

| Severity   | Liczba wyjątków | Akceptowane | Do rewizji |
|------------|----------------|-------------|------------|
| High       | 1              | 1           | 0          |
| Medium     | 4              | 4           | 0          |
| Low        | 0              | 0           | 0          |
| **Razem**  | **5**          | **5**       | **0**      |

> EXC-001: `grub2_password` (High) · EXC-003: `sshd_limit_user_access` (Medium) ·
> EXC-004: `accounts_password_last_change_is_in_past` (Medium) ·
> EXC-005: `ensure_journald_and_rsyslog_not_active_together` (Medium) ·
> EXC-006: `service_systemd-journal-upload_enabled` (Medium)
>
> EXC-002 (`aide_*`) — status: **Resolved** (AIDE zainstalowany przez remediation).

---

### Notatki z realizacji

```
# Twoje notatki:

```
