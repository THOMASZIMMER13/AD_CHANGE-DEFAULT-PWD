## SCRIPT DE CHANGEMENT DE MOT DE PASSE POUR LES COMPTES CRÉÉS DEPUIS PLUS DE X JOURS, UTILISANT LE MDP PAR DÉFAUT
## Les comptes devront changer de mot de passe avant l'ouverture de session.

# Créateur : TZ PCS 26/01/2023
# Relecteur et modifications : TS PCS 27/01/2023
# Améliorations : TS PCS 31/01/2023

# MODULES
Import-Module ActiveDirectory

# Variables
$NbJours = 30  # Nombre de jours pour identifier les comptes à modifier
$PasswordFile = ".\ScriptEncryptedPassword.txt"  # Chemin vers le fichier contenant le mot de passe crypté
$LogFolderPath = ".\logs"  # Dossier pour les fichiers de logs
$LogPath = $LogFolderPath + "\" + "AD_CHANGE-DEFAULT-PWD" + (Get-Date -Format "yyyy-MM") + ".csv"  # Nom du fichier log

# En-tête du fichier de log
$logHeader = "DATE;CanonicalName;Action"

# FONCTION : Générer un mot de passe sécurisé aléatoire
function passwordGenerator {
    Add-Type -AssemblyName 'System.Web'
    $Length = 20
    $SpecialCharacters = 5
    # Générer un mot de passe sécurisé avec des caractères spéciaux
    [System.Web.Security.Membership]::GeneratePassword($Length, $SpecialCharacters) | ConvertTo-SecureString -AsPlainText -Force
}

# FONCTION : Créer un fichier de logs
function log($texte) {
    # Création ou ajout au fichier log
    Try {
        if (Test-Path $logPath) {
            $texte = (Get-Date -Format "yyyy/MM/dd HH:mm") + ";" + $texte
            Add-Content $logPath $texte
        }
    } Catch {
        # Si le fichier n'existe pas, le créer avec l'en-tête
        Try {
            New-Item -Path $logPath -ItemType File -Force -ErrorAction Stop
            Add-Content $logPath $logHeader
            $texte = (Get-Date -Format "yyyy/MM/dd HH:mm") + ";" + $texte
            Add-Content $logPath $texte
        } Catch {
            Write-Debug "Erreur lors de la création du fichier log"
        }
    }
}

# CRÉATION DU DOSSIER DE LOG SI INEXISTANT
if (!(Test-Path -Path $LogFolderPath)) {
    New-Item -ItemType Directory -Path $LogFolderPath | Out-Null  # Crée le dossier de log si nécessaire
}

# IMPORT DU MOT DE PASSE PAR DÉFAUT À TESTER
Try {
    $pwd = (Get-Content $PasswordFile -ErrorAction Stop | ConvertTo-SecureString -ErrorAction Stop)
} Catch {
    log("ERREUR;ERREUR CHARGEMENT FICHIER MOT DE PASSE")
}

# Si le mot de passe a été chargé correctement
If ($pwd) {
    # Récupérer la date du jour et définir la date limite (30 jours avant aujourd'hui)
    $date = [DateTime]::Today.AddDays(-$NbJours)

    # Rechercher les utilisateurs actifs créés depuis plus de 30 jours et qui doivent changer leur mot de passe
    Try {
        $userlst = Get-ADUser -filter {pwdLastSet -eq 0 -and enabled -eq $true -and whenCreated -lt $date} -SearchBase "OU=Utilisateurs,DC=chu-lyon,DC=fr" -Properties whenCreated, canonicalName -ErrorAction Stop
        
        foreach ($userschangepwd in $userlst) {
            try {
                # Simulation de la modification du mot de passe (WHATIF à retirer pour appliquer réellement)
                Set-ADAccountPassword -Identity $userschangepwd.samaccountname -OldPassword $pwd -NewPassword (passwordGenerator -Force) -WhatIf -ErrorAction Stop
                
                try {
                    # Simulation de l'obligation de changement de mot de passe à la prochaine connexion (WHATIF à retirer pour appliquer réellement)
                    Set-ADUser -Identity $userschangepwd.samaccountname -ChangePasswordAtLogon $true -WhatIf -ErrorAction Stop
                    log("$($userschangepwd.canonicalname);Mot de passe changé")
                } catch {
                    log("$($userschangepwd.canonicalname);Erreur! Mot de passe changé, mais l'obligation de changement à la prochaine connexion a échoué")
                }
            } catch {
                # Ne pas enregistrer de logs pour les comptes qui n'ont pas le mot de passe par défaut (ex : réinitialisation Helpdesk)
                log("$($userschangepwd.canonicalname);L'utilisateur ne dispose pas du mot de passe par défaut à modifier")
            }
        }
    } catch {
        log("ERREUR;ERREUR CHARGEMENT LISTE UTILISATEURS")
    }
}
