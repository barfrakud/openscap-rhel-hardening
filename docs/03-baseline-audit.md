# 03 — Audyt bazowy (Baseline Scan)

## Cel

Uruchomienie pierwszego skanu CIS Level 1 Server na czystym RHEL 10
z działającym Apache. Zebranie wyników "przed hardingiem" jako punkt odniesienia.

## Komendy

### Wylistowanie dostępnych profili

```bash
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml

# Output:
Title: CIS Red Hat Enterprise Linux 10 Benchmark for Level 1 - Server
Id: xccdf_org.ssgproject.content_profile_cis_server_l1
```

### Uruchomienie skanu

```bash
sudo oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis_server_l1 \
  --results /var/log/openscap/baseline-results.xml \
  --results-arf /var/log/openscap/baseline-arf.xml \
  --report /var/log/openscap/baseline-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

**Co robi ta komenda:**
- `--profile xccdf_org.ssgproject.content_profile_cis_server_l1` — używa profilu CIS Level 1 Server
- `--results /var/log/openscap/baseline-results.xml` — zapisuje surowe wyniki w formacie XCCDF (do dalszego przetwarzania)
- `--results-arf /var/log/openscap/baseline-arf.xml` — zapisuje wyniki w formacie ARF (Asset Reporting Format, używany przez compliance tools)
- `--report /var/log/openscap/baseline-report.html` — generuje czytelny raport HTML do przeglądania w przeglądarce
- Ostatni argument to ścieżka do pliku z definicjami reguł CIS (SSG — Security Scanned Guides)

**Uwaga:** Profil ID może się różnić — użyj dokładnego ID z `oscap info`.

### Przeglądanie raportu w terminalu (Lynx)

Na serwerze bez GUI zainstaluj przeglądarkę tekstową:

```bash
sudo dnf install -y lynx
lynx /var/log/openscap/baseline-report.html
```

Nawigacja w Lynx:
- **↑/↓** — przewijanie
- **Enter** — wejście w link
- **B** — powrót
- **Q** — wyjście

### Transfer raportu HTML na maszynę lokalną (opcjonalnie)

```bash
# Z maszyny lokalnej (nie z VM):
scp root@<IP_VM>:/var/log/openscap/baseline-report.html .
```

## Analiza raportu

Po otwarciu `baseline-report.html` w przeglądarce:

1. **Nagłówek** — data skanu, profil, wersja SSG
2. **Score** — procent zgodności (spodziewany ~40-60% na czystym systemie)
3. **Tabela reguł** — status każdej reguły:
   - 🟢 **pass** — reguła spełniona
   - 🔴 **fail** — reguła niespełniona (wymaga naprawy)
   - ⚪ **notapplicable** — reguła nie dotyczy tego systemu
   - 🟡 **notchecked** — brak testu dla tej reguły

### Wynik skanu

Podsumowanie skanu:
- 289 reguł łącznie
- 170 pass (58.8%) / 119 fail (41.2%)
- Score: 73.99%

### Kategoryzacja wyników

Pogrupuj faile według kategorii (patrz LAB_RULES.md):

| Kategoria              | Liczba fail | Przykłady reguł |
|------------------------|-------------|-----------------|
| Authentication         | 30          | Require Re-Authentication for sudo, Login Warning Banners, password policy |
| Kernel & Sysctl        | 23          | Custom Crypto Policy for CIS, GRUB config permissions (0600), IPv6 sysctl |
| SSH                    | 14          | SSH Client Alive Count/Interval, Disable Host-Based Auth, Root Login |
| Network                | 12          | Firewalld loopback trust, IPv6 Router Advertisements, ICMP Redirects |
| Logging & Auditing     | 11          | Install AIDE, Build AIDE Database, Configure AIDE for Audit Tools |
| Filesystem & Partitions| 10          | /tmp na osobnej partycji, Disable cramfs/freevxfs mounting |
| Services               | 9           | /etc/at.allow, /etc/cron.allow, usunąć /etc/cron.deny |
| Filesystem Permissions | 1           | SSH Server Config File permissions |
| Inne (umask, coredumps)| 9           | Default umask, Core dumps disabled, httpd do odinstalowania |

