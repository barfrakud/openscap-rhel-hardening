# 04 — Remediacja (Hardening)

## Cel

Na podstawie wyników audytu bazowego wygenerować i zastosować fixy
bezpieczeństwa. Podejście hybrydowe: automatyczna generacja + ręczny przegląd.

## Krok 1: Generowanie skryptu remediacyjnego

### Bash — fixy tylko dla reguł które failowały

```bash
sudo oscap xccdf generate fix \
  --fix-type bash \
  --result-id "" \
  --output /root/openscap-reports/remediation.sh \
  /root/openscap-reports/baseline-arf.xml
```

### Ansible — fixy tylko dla reguł które failowały

```bash
sudo oscap xccdf generate fix \
  --fix-type ansible \
  --result-id "" \
  --output /root/openscap-reports/remediation.yml \
  /root/openscap-reports/baseline-arf.xml
```

## Krok 2: Przegląd wygenerowanych fixów

**KRYTYCZNE: Nie uruchamiaj skryptów na ślepo!**

```bash
# Przejrzyj skrypt bash
less /root/openscap-reports/remediation.sh

# Przejrzyj playbook Ansible
less /root/openscap-reports/remediation.yml
```

### Na co zwrócić uwagę:

1. **Fixy partycji** — np. osobna partycja `/tmp` — wymagają przebudowy dysku,
   zazwyczaj je pomijamy w istniejącym systemie
2. **Fixy SSH** — sprawdź czy nie zablokujesz sobie dostępu
3. **Fixy PAM/hasła** — sprawdź czy nie stracisz możliwości logowania
4. **Fixy kernel** — zazwyczaj bezpieczne (sysctl)
5. **Fixy usług** — sprawdź czy nie wyłączysz czegoś potrzebnego

### Decyzje — co aplikujemy, co pomijamy

| Reguła / Kategoria     | Decyzja          | Uzasadnienie                     |
|------------------------|------------------|----------------------------------|
| Partycje /tmp, /var    | ❌ Pomijam        | Wymaga przebudowy dysków         |
| SSH hardening          | ✅ Aplikuję       | Bezpieczne, nie wpływa na Apache |
| Polityka haseł         | ✅ Aplikuję       | Standardowy hardening            |
| Kernel sysctl          | ✅ Aplikuję       | Niskie ryzyko                    |
| Wyłączenie usług       | ⚠️ Selektywnie   | Sprawdzam każdą usługę           |
| Auditd/rsyslog         | ✅ Aplikuję       | Standardowe logowanie            |

*(Zaktualizuj tabelę na podstawie swoich wyników)*

## Krok 3: Aplikacja remediacji

### Opcja A: Skrypt bash

```bash
# PRZED uruchomieniem — zrób snapshot VM!
sudo bash /root/openscap-reports/remediation.sh
```

### Opcja B: Ansible playbook

```bash
sudo ansible-playbook -i "localhost," -c local \
  /root/openscap-reports/remediation.yml
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
