# Automatisk användarhantering med Terraform och PowerShell

**GitHub:** https://github.com/Fadi738/create-users

## Mål

Målet med projektet är att automatisera skapandet av användarkonton, en uppgift som en IT-tekniker ofta gör för hand. Att skapa många konton manuellt tar tid och ger lätt skillnader och misstag. Med automatisering blir resultatet likadant varje gång, och det går snabbt att upprepa eller återskapa.

Projektet visar hela kedjan från konfiguration till färdigt resultat:

1. **Terraform** läser en lista med användare från en fil och skapar en mappstruktur med en konfigurationsfil.
2. **PowerShell** läser konfigurationsfilen, skapar användarna i Linux och verifierar att de finns.

## Metod

**Miljö och verktyg**

- Windows med **WSL2 (Ubuntu)**, där allt arbete görs via VS Code
- **Terraform** med `local`-providern
- **PowerShell 7** (`pwsh`)
- **Git och GitHub** för versionshantering

**Filer i projektet**

| Fil | Syfte |
| --- | --- |
| `users.csv` | Listan med användare (namn och beskrivning) |
| `main.tf` | Läser `users.csv` och skapar `output/config/users.json` samt loggmappen |
| `create-users.ps1` | Läser `users.json`, skapar användarna, verifierar dem och loggar |
| `.gitignore` | Håller state-filer och genererade filer utanför Git |

**Kedjan:** `users.csv` → Terraform → `users.json` → PowerShell (skapa) → PowerShell (verifiera)

**Terraform** använder två resources (`users_config` och `logs_dir`), två variabler (`base_dir` och `users_file`) och tre outputs. Användarna ligger i `users.csv` och inte i koden, så man kan lägga till eller byta användare utan att ändra något i Terraform.

**PowerShell-skriptet** har sex funktioner med parametrar (`Write-Log`, `Get-UserList`, `Test-UserExists`, `New-SystemUser`, `Verify-User`, `Remove-SystemUser`). Det använder `foreach`-loopar, `if/else` och `try/catch`. Eftersom Linux-kommandon som `useradd` inte kastar undantag av sig själva kontrollerar skriptet felkoden (`$LASTEXITCODE`) och gör `throw` vid fel.

**Så körs projektet**

```bash
terraform init
terraform apply
sudo pwsh -File ./create-users.ps1
sudo pwsh -File ./create-users.ps1 -Remove   # städar bort användarna igen
```

## Resultat
Terraform skapade konfigurationsfilen och loggmappen, och PowerShell-skriptet skapade och verifierade användarna.

**Utskrift från `terraform apply`:**

```
local_file.logs_dir: Refreshing state... [id=c2309ef318757cc4abe23a1c140f5a886db7debf]
local_file.users_config: Refreshing state... [id=ddf56715c82d2d23b18b1d52770711db90ea55fd]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

config_file = "./output/config/users.json"
logs_directory = "output/logs"
users_to_create = [
  "fadi.akrawi",
  "gabriel.touma",
  "lahoud.touma",
]
```

**Utskrift från PowerShell-skriptet:**

```
sudo pwsh ./create-users.ps1
[2026-11-14 20:13:35] [INFO] Found 3 users in the configuration
[2026-11-14 20:13:35] [INFO] Created user 'fadi.akrawi'
[2026-11-14 20:13:35] [INFO] Created user 'gabriel.touma'
[2026-11-14 20:13:35] [INFO] Created user 'lahoud.touma'
[2026-11-14 20:13:35] [INFO] OK: 'fadi.akrawi' exists and has home directory /home/fadi.akrawi
[2026-11-14 20:13:35] [INFO] OK: 'gabriel.touma' exists and has home directory /home/gabriel.touma
[2026-11-14 20:13:35] [INFO] OK: 'lahoud.touma' exists and has home directory /home/lahoud.touma
[2026-11-14 20:13:35] [INFO] Verification done: 3 of 3 users OK


sudo pwsh ./create-users.ps1
[2026-11-14 20:29:43] [INFO] Found 3 users in the configuration
[2026-11-14 20:29:43] [WARN] User 'fadi.akrawi' already exists, skipping
[2026-11-14 20:29:43] [WARN] User 'gabriel.touma' already exists, skipping
[2026-11-14 20:29:43] [WARN] User 'lahoud.touma' already exists, skipping
[2026-11-14 20:29:43] [INFO] OK: 'fadi.akrawi' exists and has home directory /home/fadi.akrawi
[2026-11-14 20:29:43] [INFO] OK: 'gabriel.touma' exists and has home directory /home/gabriel.touma
[2026-11-14 20:29:43] [INFO] OK: 'lahoud.touma' exists and has home directory /home/lahoud.touma
[2026-11-14 20:29:43] [INFO] Verification done: 3 of 3 users OK
```

**Kontroll i Linux:**

```
uid=1001(fadi.akrawi) gid=1001(fadi.akrawi) groups=1001(fadi.akrawi)
uid=1002(gabriel.touma) gid=1002(gabriel.touma) groups=1002(gabriel.touma)
uid=1003(lahoud.touma) gid=1003(lahoud.touma) groups=1003(lahoud.touma)

ls /home/
fadi.akrawi  firo  gabriel.touma  lahoud.touma
```

Om skriptet körs en gång till hoppar det över användare som redan finns och loggar `already exists, skipping`, så det går att köra flera gånger utan fel.

## Reflektion


## GitHub-länk
https://github.com/Fadi738/create-users