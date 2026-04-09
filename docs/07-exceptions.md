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
| **Risk Owner**          | *(imię/rola)*                                   |
| **Date Granted**        | *(data)*                                        |
| **Review Date**         | *(data + 12 miesięcy)*                          |

#### EXC-002: AIDE — File Integrity Monitoring

| Pole                    | Wartość                                         |
|-------------------------|-------------------------------------------------|
| **Exception ID**        | EXC-002                                         |
| **Rule ID**             | `xccdf_org.ssgproject.content_rule_package_aide_installed`, `aide_build_database`, `aide_periodic_cron_checking`, `aide_check_audit_tools` |
| **Rule Title**          | Install AIDE / Configure file integrity monitoring |
| **Severity**            | Medium                                          |
| **Status**              | Accepted                                        |
| **Justification**       | Organizacja używa alternatywnego rozwiązania FIM (Red Hat Insights Advisor lub zewnętrzny SIEM z agentem). Instalacja AIDE spowodowałaby duplikację funkcji i konflikty z istniejącym rozwiązaniem. |
| **Compensating Control**| Aktywny agent FIM dostarczany przez centralną platformę bezpieczeństwa; alerty przy zmianach plików systemowych |
| **Risk Owner**          | *(imię/rola)*                                   |
| **Date Granted**        | *(data)*                                        |
| **Review Date**         | *(data + 6 miesięcy)*                           |

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
| **Risk Owner**          | *(imię/rola)*                                   |
| **Date Granted**        | *(data)*                                        |
| **Review Date**         | *(data + 6 miesięcy)*                           |

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

| Severity | Liczba wyjątków | Akceptowane | Do rewizji |
|----------|----------------|-------------|------------|
| High     |                |             |            |
| Medium   |                |             |            |
| Low      |                |             |            |
| **Razem**|                |             |            |

*(Uzupełnij po zakończeniu audytu)*

---

### Notatki z realizacji

```
# Twoje notatki:

```
