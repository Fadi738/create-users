# Automatisk användarhantering med Terraform och PowerShell

**GitHub:** https://github.com/Fadi738/create-users

## Mål
(Fylls i senare)

## Metod
- **WSL2 + Ubuntu** som miljö
- **Terraform (local-provider)** skapar mappstruktur och `users.json` med användarlistan
- **PowerShell 7** läser filen, skapar användarna, verifierar dem och loggar
- **Git/GitHub** för versionshantering

Kedjan: Terraform → PowerShell (skapa) → PowerShell (verifiera)

Kör så här:

```bash
terraform init
terraform apply
sudo pwsh -File ./create-users.ps1
sudo pwsh -File ./create-users.ps1 -Remove
```

## Resultat
(Fylls i senare)

## Reflektion
(Fylls i senare)

## GitHub-länk
https://github.com/Fadi738/create-users