# Słownik pojęć (Glossary)

| Termin          | Opis                                                                                         |
|-----------------|----------------------------------------------------------------------------------------------|
| **SCAP**        | Security Content Automation Protocol — zestaw standardów NIST do automatycznego audytu        |
| **OpenSCAP**    | Open-source implementacja SCAP — narzędzie CLI `oscap` + ekosystem                          |
| **SSG**         | SCAP Security Guide — paczka z gotowymi profilami bezpieczeństwa dla różnych systemów         |
| **XCCDF**       | Extensible Configuration Checklist Description Format — XML opisujący reguły ("co sprawdzić")|
| **OVAL**        | Open Vulnerability and Assessment Language — XML opisujący testy ("jak sprawdzić")            |
| **ARF**         | Asset Reporting Format — maszynowy format wyników audytu                                      |
| **DataStream**  | Pojedynczy plik XML zawierający XCCDF + OVAL + CPE w jednym (np. `ssg-rhel10-ds.xml`)       |
| **Profil**      | Zbiór reguł odpowiadający konkretnemu standardowi (np. CIS L1, STIG)                        |
| **CIS**         | Center for Internet Security — organizacja tworząca benchmarki bezpieczeństwa                 |
| **STIG**        | Security Technical Implementation Guide — standard DoD (Departament Obrony USA)               |
| **PCI-DSS**     | Payment Card Industry Data Security Standard — standard dla systemów obsługujących płatności  |
| **CAT I/II/III**| Kategorie ważności reguł STIG (I=krytyczna, II=średnia, III=niska)                            |
| **Tailoring**   | Dostosowanie profilu — wyłączanie reguł, zmiana wartości parametrów                           |
| **Remediacja**  | Proces naprawiania systemu w celu spełnienia reguł bezpieczeństwa                             |
| **Hardening**   | Utwardzanie systemu — usuwanie zbędnych usług, zaostrzanie konfiguracji                       |
| **Compliance**  | Zgodność systemu z wybranym standardem bezpieczeństwa                                         |
| **Baseline**    | Stan bazowy systemu przed hardingiem — punkt odniesienia                                      |
| **Drift**       | Odchylenie konfiguracji od pożądanego stanu (np. ktoś zmienił ustawienie po hardeningu)      |
| **Golden Image**| Obraz systemu z wbudowanym hardingiem, używany jako baza do nowych instancji                  |
| **CPE**         | Common Platform Enumeration — identyfikator platformy (np. `cpe:/o:redhat:enterprise_linux:10`)|
| **CVE**         | Common Vulnerabilities and Exposures — identyfikator znanej podatności                        |
| **CCE**         | Common Configuration Enumeration — identyfikator ustawienia konfiguracyjnego                  |
| **Lynis**       | Alternatywne narzędzie do audytu — heurystyczne, z punktacją hardening index                  |
| **PAM**         | Pluggable Authentication Modules — system zarządzania uwierzytelnianiem w Linuksie            |
| **FIPS 140-2**  | Standard kryptograficzny rządu USA                                                            |
| **Tailoring**   | Plik XML modyfikujący profil SCAP — wyłączanie reguł, zmiana wartości parametrów              |
| **Exception**   | Formalny wyjątek — udokumentowana akceptacja niespełnionej reguły z uzasadnieniem             |
| **Waiver**      | Synonim Exception — formalna zgoda na odstępstwo od wymagania bezpieczeństwa                  |
| **Compensating Control** | Kontrola zastępcza wdrożona gdy główna reguła nie może być spełniona                  |
| **Risk Owner**  | Osoba odpowiedzialna za akceptację ryzyka związanego z wyjątkiem                              |
