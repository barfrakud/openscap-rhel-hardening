# 05 — Remediacja (Hardening)

## Cel

Na podstawie wyników audytu bazowego wygenerować i zastosować fixy
bezpieczeństwa. Podejście hybrydowe: automatyczna generacja + ręczny przegląd.

## Krok 0: Skan weryfikacyjny — "after tailoring"

Przed wygenerowaniem jakichkolwiek fixów uruchamiamy skan z tailored profilem.
Cel: potwierdzić, że tailoring działa poprawnie, i mieć punkt odniesienia
"stan systemu po tailoringu, przed remediacją".

Ten raport powinien pokazać:
- **wyłączone reguły** (`partition_for_tmp`, `partition_for_var`, `package_httpd_removed`)
  mają status `notselected` — znikają z listy failów
- **zmodyfikowane wartości** (minlen, maxage, tmout) są aktywne
- liczba failów jest niższa niż w baseline — różnica pochodzi wyłącznie z tailoringu,
  nie z żadnych zmian w systemie

```bash
sudo oscap xccdf eval \
  --profile cis_server_l1_tailored \
  --tailoring-file /var/log/openscap/tailoring.xml \
  --results /var/log/openscap/after-tailoring-results.xml \
  --results-arf /var/log/openscap/after-tailoring-arf.xml \
  --report /var/log/openscap/after-tailoring-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml || true
```

> **Trzy raporty w projekcie:**
> `baseline-report` → `after-tailoring-report` → `post-report`
> Każdy raport dokumentuje inny etap: stan surowy / po tailoringu / po remediacji.

### Wyniki porównania: baseline vs after-tailoring

| Metryka | baseline | after-tailoring | zmiana |
|---------|----------|-----------------|--------|
| Score | 73.99% | 85.47% | **+11.5 pp** |
| pass | 341 | 341 | 0 |
| fail | 239 | 235 | −4 |
| notapplicable | 65 | 65 | 0 |
| unknown | 31 | 29 | −2 |

**Kluczowe reguły tailoringu:**

| Reguła | Zmiana w tailoringu | baseline | after-tailoring |
|--------|---------------------|----------|-----------------|
| `partition_for_tmp` | disable | obecna | `notselected` ✅ |
| `partition_for_var` | disable | nieobecna | nieobecna (była `notapplicable`) |
| `package_httpd_removed` | disable | obecna | `notselected` ✅ |
| `accounts_password_pam_minlen` | refine-value: minlen 8→14 | `fail` | `fail` |
| `accounts_maximum_age_login_defs` | refine-value: maxage 365→90 | `fail` | `fail` |
| `accounts_tmout` | refine-value: tmout 600→900 s | `fail` | `fail` |

Reguły `refine-value` pozostają `fail` w obu raportach — tailoring zmienił próg sprawdzania,
ale konfiguracja systemu jeszcze nie została zmieniona (żaden fix nie był aplikowany).
Zmienione progi będą aktywne przy skanowaniu post-remediation.

Wzrost score o ~11.5 pp wynika wyłącznie z usunięcia reguł `disable` z mianownika XCCDF —
żaden fix nie został jeszcze zastosowany.

> **Wniosek:** Tailoring działa poprawnie. Reguły `disable` zniknęły z raportu,
> reguły `refine-value` nadal `fail` z nowymi progami — co potwierdza, że system
> nie był jeszcze modyfikowany. Można przejść do generowania fixów.

## Krok 1: Generowanie skryptu remediacyjnego

Generujemy fixy z DataStream używając tailored profilu — nie z pliku ARF.
Dzięki temu skrypt automatycznie pomija reguły wyłączone w tailoringu
(np. `package_httpd_removed` — Apache nie zostanie usunięty).

> **Co znaczy "generować fixy z DataStream"?**
> Plik DataStream (`ssg-rhel10-ds.xml`) to jeden plik XML zawierający reguły, testy OVAL
> oraz **gotowe skrypty naprawcze** wbudowane dla każdej reguły. Polecenie
> `oscap xccdf generate fix` przechodzi przez reguły tailored profilu i dla każdej
> wyciąga wbudowany fix — składając z nich jeden zbiorczy skrypt wyjściowy.
> Gdybyśmy generowali z pliku ARF (wyniki skanu), dostalibyśmy fixy tylko dla reguł,
> które faktycznie nie przeszły — z DataStream dostajemy fixy dla wszystkich reguł profilu.

Mamy dwie opcje generowania skryptu remediacyjnego — wybierz jedną lub obie:
- **Bash** — skrypt `.sh` uruchamiany bezpośrednio na systemie
- **Ansible** — playbook `.yml` uruchamiany przez Ansible (lepsza idempotentność, czytelny, nadaje się do pipeline CI/CD)

### Bash

```bash
sudo oscap xccdf generate fix \
  --fix-type bash \
  --profile cis_server_l1_tailored \
  --tailoring-file /var/log/openscap/tailoring.xml \
  --output /var/log/openscap/remediation.sh \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

### Ansible

```bash
sudo oscap xccdf generate fix \
  --fix-type ansible \
  --profile cis_server_l1_tailored \
  --tailoring-file /var/log/openscap/tailoring.xml \
  --output /var/log/openscap/remediation.yml \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

## Krok 2: Przegląd wygenerowanych fixów

**KRYTYCZNE: Nie uruchamiaj skryptów na ślepo!**

```bash
# Przejrzyj skrypt bash
less /var/log/openscap/remediation.sh

# Przejrzyj playbook Ansible
less /var/log/openscap/remediation.yml
```

### Na co zwrócić uwagę:

1. **Fixy partycji** — `partition_for_tmp`, `partition_for_var` wyłączone w tailoringu —
   nie ma ich w skrypcie. Brak ryzyka.

2. **Fixy SSH** — skrypt ustawia: `PermitRootLogin no`, `PermitEmptyPasswords no`,
   `IgnoreRhosts yes`, `ClientAliveInterval`, `MaxAuthTries`, `MaxSessions`,
   `LogLevel VERBOSE`, banner. **Bezpieczne dla tego środowiska.**
   `sshd_limit_user_access` (EXC-003) — fix oznaczony jako `FIX IS MISSING` — skrypt
   nie wykona żadnej zmiany. Brak ryzyka.

3. **Fixy PAM/hasła** — skrypt konfiguruje: minlen=14, TMOUT=900, PASS_MAX_DAYS=90,
   faillock (lockout po N nieudanych logowaniach), historię haseł, SHA-512.
   ⚠️ **faillock** — ryzyko zablokowania konta przy błędnym haśle. Sprawdź progi
   przed uruchomieniem (`faillock --user root --reset` aby odblokować w razie blokady).

4. **Fixy kernel** — 44 reguły sysctl: wyłączenie forwardingu IPv4/IPv6, odrzucanie
   przekierowań ICMP, filtrowanie źródła pakietów. **Niskie ryzyko dla serwera webowego.**

5. **Fixy usług** — skrypt **wyłącza**: `bluetooth`, `autofs`, `avahi-daemon`, `dnsmasq`,
   `rpcbind`, `nfs`, `cups`. **Bezpieczne na VM bez tych usług.**
   ⚠️ **firewalld** — skrypt **włącza** firewalld. Upewnij się, że reguły przepuszczają
   port 80 (Apache) i 22 (SSH) zanim zaaplikujesz fixy.

6. **AIDE** — ⚠️ Mimo EXC-002 (pomijamy AIDE), fix 1-4 w skrypcie **zainstaluje i
   skonfiguruje AIDE** (`dnf install aide`). Wymagana selektywna decyzja — patrz tabela.

### Decyzje — co aplikujemy, co pomijamy

| Reguła / Kategoria | Fix w skrypcie? | Decyzja | Uzasadnienie |
|--------------------|-----------------|---------|---------------|
| Partycje /tmp, /var | ⛔ Brak (tailoring) | ⛔ Wyłączone | Reguły zdeaktywowane — nie ma ich w skrypcie |
| GRUB2 bootloader password | ⚠️ `FIX IS MISSING` | ❌ Pomijam | Brak automatyzacji w skrypcie; EXC-001 |
| AIDE (FIM) | ✅ Jest — fix 1-4 | ❌ Pomijam | Skrypt zainstaluje AIDE — **nie uruchamiać tych fixów**; EXC-002 |
| SSH AllowUsers/AllowGroups | ⚠️ `FIX IS MISSING` | ❌ Pomijam | Brak automatyzacji; EXC-003 |
| httpd removal | ⛔ Brak (tailoring) | ⛔ Wyłączone | Reguła zdeaktywowana w tailoringu |
| Polityka haseł (minlen=14, maxage=90, tmout=900) | ✅ Jest | ✅ Aplikuję | Wartości zgodne z tailoringiem |
| PAM faillock (lockout) | ✅ Jest | ✅ Aplikuję | Sprawdzić progi; `faillock --user root --reset` na wypadek blokady |
| SSH hardening (bez AllowUsers) | ✅ Jest | ✅ Aplikuję | Bezpieczne; nie blokuje dostępu przy obecnej konfiguracji |
| firewalld (enable) | ✅ Jest | ⚠️ Selektywnie | Włącza firewalld — najpierw otworzyć porty 22 i 80 |
| Usługi: bluetooth, autofs, avahi, dnsmasq, rpcbind, nfs, cups | ✅ Jest | ✅ Aplikuję | Nieużywane na VM — bezpieczne do wyłączenia |
| Kernel sysctl (44 reguły) | ✅ Jest | ✅ Aplikuję | Hardening sieci — niskie ryzyko dla serwera webowego |
| Auditd / rsyslog | ✅ Jest | ✅ Aplikuję | Standardowe logowanie |
| Pozostałe (~300 reguł: DCONF, crypto, bannery, uprawnienia plików itp.) | ✅ Jest | ➡️ Aplikuję (lab) | Środowisko laboratoryjne — stosujemy cały skrypt bez szczegółowej analizy każdej reguły. **W środowisku produkcyjnym każda reguła wymaga indywidualnego przeglądu.** |

## Krok 3: Aplikacja remediacji

### Porównanie opcji

| | Opcja A: Skrypt bash | Opcja B: Ansible | Opcja C: Selektywna |
|---|---|---|---|
| **Zalety** | Szybki, zero zależności, działa offline | Idempotentny, czytelny, skalowalny, audytowalny | Pełna kontrola, minimalne ryzyko side-effectów |
| **Wady** | Nie jest idempotentny, błąd = niespójny stan | Wymaga Ansible, wolniejszy niż bash | Czasochłonne, podatne na błędy ludzkie |
| **Kiedy używać** | Jednorazowe środowisko testowe / VM której nie szkoda | **Preferowane** — produkcja, wielokrotne uruchamianie, CI/CD | Gdy nie ufasz całemu zestawowi fixów i stosujesz tylko wybrane reguły |

> **TL;DR:** Zalecane na tej maszynie laboratoryjnej — **Opcja B**. Opcja A gdy nie masz Ansible. Opcja C gdy masz konkretne, znane reguły z wyjątkami produkcyjnymi.

### Opcja A: Skrypt bash

```bash
# PRZED uruchomieniem — zrób snapshot VM!
sudo bash /var/log/openscap/remediation.sh
```

### Opcja B: Ansible playbook

> Uruchamiasz **na tej samej maszynie** — flagi `-i "localhost," -c local` oznaczają połączenie lokalne bez SSH.

**Krok 0: Test łączności przed remediają**

```bash
# Zainstaluj Ansible (jeśli nie ma)
sudo dnf install ansible-core -y

# Sprawdź czy Ansible działa
ansible -i "localhost," -c local all -m ping
# Oczekiwany wynik: localhost | SUCCESS => { "ping": "pong" }

```

**Krok 1: Instalacja wymaganych kolekcji Ansible**

```bash
# Wymagane przez wygenerowany playbook (community.general i ansible.posix)
sudo ansible-galaxy collection install community.general ansible.posix
```

**Krok 2: Uruchomienie remediacji**

```bash
sudo ansible-playbook -i "localhost," -c local /var/log/openscap/remediation.yml
```

**Wynik dziłania playbooka:**

```
PLAY RECAP *************************************************************************************************************************************
localhost                  : ok=1193 changed=155  unreachable=0    failed=0    skipped=559  rescued=0    ignored=0   
```

### Opcja C: Selektywna — ręcznie wybrane fixy

Jeśli chcesz aplikować tylko wybrane kategorie, wyciągnij odpowiednie
sekcje ze skryptu i uruchom osobno.

## Krok 4: Weryfikacja po hardeningu

```bash
# Czy Apache nadal działa?
curl http://localhost
sudo systemctl status httpd

# Dostęp do strony testowej z innego hosta w sieci z przeglądarki
http://<IP_ADDRESS>

# Czy SSH nadal działa?
# (przetestuj z innego terminala zanim zamkniesz sesję!)
ssh user@<IP_VM>

# Czy system bootuje poprawnie?
# (opcjonalnie — restart i sprawdzenie)
sudo reboot
```

### Testy 

Testy wykonano pomyślnie.

## Krok 5: Rozwiązywanie problemów

Jeśli coś się zepsuło po hardeningu:

1. Przywróć snapshot VM
2. Zidentyfikuj która reguła spowodowała problem
3. Wyklucz ją z remediacji i uruchom ponownie

---

### Notatki z realizacji

```
# Twoje notatki:

```
