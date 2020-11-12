Import-Module ActiveDirectory 

(Get-Content C:\scripts\AD\Lista.csv).replace(';' ,',') | Set-Content C:\scripts\AD\Lista.csv
Import-Csv "C:\scripts\AD\Lista.csv" | ForEach-Object {
$upn = $_.Login + “@techne.com.br”
$uname = $_.PrimeiroNome + " " + $_.UltimoNome


New-ADUser -Name $uname `
-DisplayName $_.NomeCompleto `
-GivenName $_.PrimeiroNome `
-Surname $_.UltimoNome `
-SamAccountName $_.Login `
-OfficePhone $_.Telefone `
-Department $_.Setor `
-EmailAddress $_.Email `
-City $_.Cidade `
-State $_.Estado `
-Description $_.Cargo `
-Office $_.Escritorio `
-UserPrincipalName $upn `
-Path $_.OU `
-AccountPassword (ConvertTo-SecureString $_.Senha -AsPlainText -force) -Enabled $true
}