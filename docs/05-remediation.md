# 05 — Remediacja (Hardening)

## Cel

Na podstawie wyników audytu bazowego wygenerować i zastosować fixy
bezpieczeństwa. Podejście hybrydowe: automatyczna generacja + ręczny przegląd.

## Krok 1: Generowanie skryptu remediacyjnego

Generujemy fixy z DataStream używając tailored profilu — nie z pliku ARF.
Dzięki temu skrypt automatycznie pomija reguły wyłączone w tailoringu
(np. `package_httpd_removed` — Apache nie zostanie usunięty).

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

1. **Fixy partycji** — reguły `partition_for_tmp` i `partition_for_var` są wyłączone
   w tailoringu — nie pojawią się w skrypcie. Reguły `partition_for_var_log` i podobne
   nie są w zakresie CIS L1 — również nie pojawią się w skrypcie
2. **Fixy SSH** — sprawdź czy nie zablokujesz sobie dostępu
3. **Fixy PAM/hasła** — sprawdź czy nie stracisz możliwości logowania
4. **Fixy kernel** — zazwyczaj bezpieczne (sysctl)
5. **Fixy usług** — sprawdź czy nie wyłączysz czegoś potrzebnego

### Decyzje — co aplikujemy, co pomijamy

| Reguła / Kategoria                          | Decyzja                       | Uzasadnienie                                             |
|----------------------------------------------|-------------------------------|----------------------------------------------------------|
| Partycje /tmp, /var                          | ⛔ Wyłączone w tailoringu     | Reguły zdeaktywowane — nie dotyczą środowiska               |
| GRUB2 bootloader password                    | ❌ Pomijam                    | VM zarządzana przez hypervisor; udokumentowane jako EXC-001   |
| AIDE (file integrity monitoring)             | ❌ Pomijam                    | Organizacja używa alternatywnego FIM; udokumentowane jako EXC-002 |
| SSH AllowUsers/AllowGroups                   | ❌ Pomijam                    | Centralne LDAP/AD; udokumentowane jako EXC-003              |
| httpd removal                                | ⛔ Wyłączone w tailoringu     | Rola serwera webowego — Apache jest wymaganym serwisem    |
| Polityka haseł (minlen, maxage, tmout)       | ✅ Aplikuję (refine-value)    | Wartości dostosowane w tailoringu                        |
| SSH hardening                                | ✅ Aplikuję                   | Bezpieczne, nie wpływa na Apache                         |
| Kernel sysctl                                | ✅ Aplikuję                   | Niskie ryzyko                                            |
| Wyłączenie usług                             | ⚠️ Selektywnie              | Sprawdzam każdą usługę — nie wygaszam httpd               |
| Auditd/rsyslog                               | ✅ Aplikuję                   | Standardowe logowanie                                    |

*(Zaktualizuj tabelę na podstawie swoich wyników)*

## Krok 3: Aplikacja remediacji

### Opcja A: Skrypt bash

```bash
# PRZED uruchomieniem — zrób snapshot VM!
sudo bash /var/log/openscap/remediation.sh
```

### Opcja B: Ansible playbook

```bash
sudo ansible-playbook -i "localhost," -c local \
  /var/log/openscap/remediation.yml
```

### Opcja C: Selektywna — ręcznie wybrane fixy

Jeśli chcesz aplikować tylko wybrane kategorie, wyciągnij odpowiednie
sekcje ze skryptu i uruchom osobno.

## Krok 4: Weryfikacja po hardeningu

```bash
# Czy Apache nadal działa?
curl http://localhost
sudo systemctl status httpd

# Czy SSH nadal działa?
# (przetestuj z innego terminala zanim zamkniesz sesję!)
ssh user@<IP_VM>

# Czy system bootuje poprawnie?
# (opcjonalnie — restart i sprawdzenie)
sudo reboot
```

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
