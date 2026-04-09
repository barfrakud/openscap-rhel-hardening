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

#### EXC-001: Osobna partycja /tmp

| Pole                    | Wartość                                         |
|-------------------------|-------------------------------------------------|
| **Exception ID**        | EXC-001                                         |
| **Rule ID**             | *(uzupełnij)*                                   |
| **Rule Title**          | Ensure /tmp is a separate partition              |
| **Severity**            | Medium                                          |
| **Status**              | Accepted                                        |
| **Justification**       | System zainstalowany bez osobnych partycji. Przebudowa dysku wymaga pełnej reinstalacji i migracji danych. |
| **Compensating Control**| Monitoring użycia dysku (df alerts), noexec/nosuid na /tmp via systemd tmp.mount |
| **Risk Owner**          | *(imię/rola)*                                   |
| **Date Granted**        | *(data)*                                        |
| **Review Date**         | *(data + 6 miesięcy)*                           |

#### EXC-002: *(kolejna reguła)*

| Pole                    | Wartość                                         |
|-------------------------|-------------------------------------------------|
| **Exception ID**        | EXC-002                                         |
| **Rule ID**             | *(uzupełnij)*                                   |
| **Rule Title**          | *(uzupełnij)*                                   |
| **Severity**            | *(uzupełnij)*                                   |
| **Status**              | Accepted                                        |
| **Justification**       | *(uzupełnij)*                                   |
| **Compensating Control**| *(uzupełnij)*                                   |
| **Risk Owner**          | *(uzupełnij)*                                   |
| **Date Granted**        | *(uzupełnij)*                                   |
| **Review Date**         | *(uzupełnij)*                                   |

*(Powtórz dla każdej reguły, której nie spełniamy)*

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
