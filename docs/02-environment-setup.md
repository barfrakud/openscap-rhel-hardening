# 02 — Przygotowanie środowiska

## Wymagania

| Parametr          | Wartość                          |
|-------------------|----------------------------------|
| Hypervisor        | VirtualBox / KVM / VMware        |
| OS                | RHEL 10 (Minimal Install)        |
| RAM               | min. 2 GB                        |
| Dysk              | min. 20 GB                       |
| Sieć              | NAT lub Bridge                   |
| ISO               | Z portalu Red Hat Developer      |

## Krok 1: Pobranie RHEL 10

1. Zarejestruj się na https://developers.redhat.com (darmowe konto)
2. Pobierz ISO: Red Hat Enterprise Linux 10 Boot/DVD

## Krok 2: Instalacja VM

Profil instalacji: **Minimal Install** (celowo — chcemy zobaczyć ile reguł
CIS failuje na czystym systemie).

Podczas instalacji:

- Ustaw hostname: `openscap-lab`
- Utwórz użytkownika z uprawnieniami administratora
- Włącz sieć (DHCP lub statyczne IP)
- **NIE wybieraj** Security Policy w instalatorze — zrobimy to ręcznie

## Krok 3: Po instalacji — weryfikacja

```bash
# Wersja systemu
cat /etc/redhat-release

# Status subskrypcji
sudo subscription-manager status

# Rejestracja (jeśli nie została wykonana podczas instalacji)
sudo subscription-manager register --username=TWOJ_LOGIN

# SELinux — powinien być enforcing
getenforce

# Firewalld — powinien być aktywny
sudo systemctl status firewalld

# Aktualizacja systemu
sudo dnf update -y
```

## Krok 4: Instalacja Apache

```bash
# Instalacja
sudo dnf install -y httpd

# Strona testowa
sudo tee /var/www/html/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>OpenSCAP Lab</title>
</head>
<body>
    <h1>OpenSCAP Hardening Lab</h1>
    <p>This is a test page running on RHEL 10.</p>
    <p>Server is awaiting security hardening.</p>
</body>
</html>
EOF

# Uruchomienie i autostart
sudo systemctl enable --now httpd

# Otwarcie portu w firewallu
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# Test
curl http://localhost
```

## Krok 5: Instalacja OpenSCAP

```bash
# Instalacja narzędzi
sudo dnf install -y openscap-scanner scap-security-guide

# Weryfikacja
oscap --version

# Sprawdzenie dostępnych profili
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

## Krok 6: Utworzenie katalogu na raporty

```bash
sudo mkdir -p /root/openscap-reports
```

## Wynik

Po wykonaniu tych kroków mamy:

- [x] RHEL 10 z Minimal Install
- [x] Apache serwuje stronę testową na porcie 80
- [x] OpenSCAP + scap-security-guide zainstalowane
- [x] Katalog na raporty utworzony
- [x] System gotowy do pierwszego audytu

---

### Notatki z realizacji

*(Tutaj wklejaj swoje obserwacje, output komend, problemy)*

```
# Twoje notatki:

```
