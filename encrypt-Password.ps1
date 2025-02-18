# Demande à l'utilisateur de saisir un mot de passe et génère un mot de passe crypté

# Demander à l'utilisateur de saisir un mot de passe
$pwd = Read-Host "Merci d'écrire le mot de passe"

# Convertir le mot de passe en une chaîne sécurisée
$password = ConvertTo-SecureString -AsPlainText "$pwd" -Force

# Crypter la chaîne sécurisée et l'enregistrer dans un fichier
$password | ConvertFrom-SecureString | Set-Content ".\scripts\encrypted_password1.txt"

Write-Host "Le mot de passe a été crypté et enregistré avec succès dans le fichier 'encrypted_password1.txt'."
