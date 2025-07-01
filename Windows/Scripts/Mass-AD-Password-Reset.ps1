import-module activedirectory

$ouname = read-host -prompt 'Name of the OU where your users are'
$oupath = (get-adorganizationalunit -filter "name -like '$ouname'").distinguishedname
$filepath = "$env:USERPROFILE\Desktop"

#Required Assembly to Generate Passwords
Add-Type -Assembly System.Web
$date = (get-date -f yyyy-MM-dd-hh-mm-ss)
$users = get-aduser -filter * -SearchBase $oupath -properties * -SearchScope OneLevel

foreach($Name in $users.samaccountname){
$NewPassword=[Web.Security.Membership]::GeneratePassword(8,1)

Set-ADAccountPassword -Identity $Name -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)
Get-ADUser -Identity $Name |Set-ADUser -ChangePasswordAtLogon:$true

# Append the username and generated password to the output file
Add-Content -Path "$filepath\NewPass$date.txt" -Value "UserID:$Name`tPassword:$NewPassword"
}

Read-Host "File NewPass$date.txt with the user list and their new passwords has been saved to your desktop. Please press any key to exit..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
