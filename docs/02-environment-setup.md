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
sudo dnf install -y openscap-scanner openscap-utils scap-security-guide

# Weryfikacja
oscap --version

# Sprawdzenie dostępnych profili
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

## Krok 6: Utworzenie katalogu na raporty

```bash
sudo mkdir -p /var/log/openscap
```

## Wynik

Po wykonaniu tych kroków mamy:

- [x] RHEL 10 z Minimal Install
- [x] Apache serwuje stronę testową na porcie 80
- [x] OpenSCAP + openscap-utils + scap-security-guide zainstalowane
- [x] Katalog na raporty utworzony
- [x] System gotowy do pierwszego audytu

---

### Notatki z realizacji


```
# Wersja systemu
cat /etc/redhat-release
Red Hat Enterprise Linux release 10.1 (Coughlan)

# Wersja Apache
httpd -v
Server version: Apache/2.4.63 (Red Hat Enterprise Linux)
Server built:   Dec 10 2025 00:00:00

# Wersja OSCAP
oscap --version
OpenSCAP command line tool (oscap) 1.4.3
Copyright 2009--2023 Red Hat Inc., Durham, North Carolina.

==== Supported specifications ====
SCAP Version: 1.3
XCCDF Version: 1.2
OVAL Version: 5.11.3
CPE Version: 2.3
Asset Identification Version: 1.1
Asset Reporting Format Version: 1.1

==== Capabilities added by auto-loaded plugins ====
No plugins have been auto-loaded...

==== Paths ====
Schema files: /usr/share/openscap/schemas
Default CPE files: /usr/share/openscap/cpe

==== Inbuilt CPE names ====
Linux - cpe:/o:linux:linux_kernel:-

==== Supported OVAL objects and associated OpenSCAP probes ====
OVAL family   OVAL object                  OpenSCAP probe              
----------    ----------                   ----------                  
independent   environmentvariable          probe_environmentvariable
independent   environmentvariable58        probe_environmentvariable58
independent   family                       probe_family
independent   filehash58                   probe_filehash58 (SHA-224, SHA-256, SHA-384, SHA-512)
independent   system_info                  probe_system_info
independent   textfilecontent              probe_textfilecontent
independent   textfilecontent54            probe_textfilecontent54
independent   variable                     probe_variable
independent   xmlfilecontent               probe_xmlfilecontent
independent   yamlfilecontent              probe_yamlfilecontent
linux         iflisteners                  probe_iflisteners
linux         inetlisteningservers         probe_inetlisteningservers
linux         partition                    probe_partition
linux         rpminfo                      probe_rpminfo
linux         rpmverify                    probe_rpmverify
linux         rpmverifyfile                probe_rpmverifyfile
linux         rpmverifypackage             probe_rpmverifypackage
linux         selinuxboolean               probe_selinuxboolean
linux         selinuxsecuritycontext       probe_selinuxsecuritycontext
linux         systemdunitdependency        probe_systemdunitdependency
linux         systemdunitproperty          probe_systemdunitproperty
linux         fwupdsecattr                 probe_fwupdsecattr
unix          dnscache                     probe_dnscache
unix          file                         probe_file
unix          fileextendedattribute        probe_fileextendedattribute
unix          interface                    probe_interface
unix          password                     probe_password
unix          process                      probe_process
unix          process58                    probe_process58
unix          routingtable                 probe_routingtable
unix          runlevel                     probe_runlevel
unix          shadow                       probe_shadow
unix          symlink                      probe_symlink
unix          sysctl                       probe_sysctl
unix          uname                        probe_uname
unix          xinetd                       probe_xinetd

```
# Twoje notatki:

```
