import-module activedirectory
 
 
$NetBIOS = "example" #NetBIOS domain name
$Domain = "example.local"    #Domain name
$Servername = "dc" #MIM Server Name
$Password = ConvertTo-SecureString "Middleware1" -asplaintext -force #This sets a placeholder password for account creation.  Please change the password for each service account in AD after running this script.
$ServiceAccountOU = "OU=MIM,OU=Service Account,OU=Administration,OU=Production,DC=example,DC=local" #This is where the MIM service accounts will be created in AD, this needs to exist.
$MIMGroupOU = "OU=MIM,OU=Service Account,OU=Administration,OU=Production,DC=example,DC=local" #This is where the MIM groups will be created in AD, this needs to exist.
$MAaccount = "svc_MIMMA" #This is the Management Account agent used for connecting out to systems.
$SyncAccount = "svc_MIMSync" #This is the account used for running the MIM Synchronization Service
$ServiceAccount = "svc_MIMService" #This is the account used for running the MIM Service (aka MIM Portal)
$SSPRaccount = "svc_MIMSSPR" #This account run the Self Service Password Reset components if required.
$SharepointAccount = "svc_MIMSP" #This will account will run the sharepoint services on which the MIM Service relies.
$MIMAdmin = "MIMAdmin" #This will be the primary account used to log in and administer MIM.
 
 
 
#No need to modify anything below this line.
#--------------------------------------------------------------------------------
New-ADUser -SamAccountName $MAaccount -name $MAaccount -userPrincipalName $MAaccount@$Domain -path $ServiceAccountOU -description "This account is used by MIM for creating connections via MIM Management Agents"
Set-ADAccountPassword -identity $MAaccount -NewPassword $Password
Set-ADUser -identity $MAaccount -Enabled 1 -PasswordNeverExpires 1
New-ADUser -SamAccountName $SyncAccount -name $SyncAccount -userPrincipalName $SyncAccount@$Domain -path $ServiceAccountOU -description "This account is used by the MIM Synchronization Service"
Set-ADAccountPassword -identity $SyncAccount -NewPassword $Password
Set-ADUser -identity $SyncAccount -Enabled 1 -PasswordNeverExpires 1
New-ADUser -SamAccountName $ServiceAccount -name $ServiceAccount -userPrincipalName $ServiceAccount@$Domain -path $ServiceAccountOU -description "This account is used by the MIM Service"
Set-ADAccountPassword -identity $ServiceAccount -NewPassword  $Password
Set-ADUser -identity $ServiceAccount -Enabled 1 -PasswordNeverExpires 1
New-ADUser -SamAccountName $SSPRaccount -name $SSPRaccount -userPrincipalName $SSPRaccount@$Domain -path $ServiceAccountOU -description "This account is used by the MIM Self Service Password Reset Service"
Set-ADAccountPassword -identity $SSPRaccount -NewPassword  $Password
Set-ADUser -identity $SSPRaccount -Enabled 1 -PasswordNeverExpires 1
New-ADUser -SamAccountName $SharepointAccount -name $SharepointAccount -userPrincipalName $SharepointAccount@$Domain -path $ServiceAccountOU -description "This account is used by the Sharepoint components required for the MIM Service"
Set-ADAccountPassword -identity $SharepointAccount -NewPassword  $Password
Set-ADUser -identity $SharepointAccount -Enabled 1 -PasswordNeverExpires 1
New-ADUser -SamAccountName $MIMAdmin -name $MIMAdmin -userPrincipalName $MIMAdmin@$Domain -path $ServiceAccountOU -description "This account is used to log in to and administer MIM"
Set-ADAccountPassword -identity $MIMAdmin -NewPassword  $Password
Set-ADUser -identity $MIMAdmin -Enabled 1 -PasswordNeverExpires 1
 
#Create the MIM Management Groups
New-ADGroup -name MIMSyncAdmins -GroupCategory Security -GroupScope Global -SamAccountName MIMSyncAdmins -path $MIMGroupOU
New-ADGroup -name MIMSyncOperators -GroupCategory Security -GroupScope Global -SamAccountName MIMSyncOperators -path $MIMGroupOU
New-ADGroup -name MIMSyncJoiners -GroupCategory Security -GroupScope Global -SamAccountName MIMSyncJoiners -path $MIMGroupOU
New-ADGroup -name MIMSyncBrowse -GroupCategory Security -GroupScope Global -SamAccountName MIMSyncBrowse -path $MIMGroupOU
New-ADGroup -name MIMSyncPasswordReset -GroupCategory Security -GroupScope Global -SamAccountName MIMSyncPasswordReset -path $MIMGroupOU
 
#Add members
Add-ADGroupMember -identity MIMSyncAdmins -Members $MIMAdmin
Add-ADGroupmember -identity MIMSyncAdmins -Members $ServiceAccount
 
#Set SPN's
setspn -S http/$ServerName.$Domain $NetBIOS\$SharepointAccount
setspn -S http/$ServerName $NetBIOS\$SharepointAccount
setspn -S FIMService/$ServerName.$Domain $NetBIOS\$ServiceAccount
setspn -S FIMSynchronizationService/$ServerName.$Domain $NetBIOS\$SyncAccount
 
#create Local Security Policy text file
'----------------------------------------------------------------------------------------------------------------------------' | Out-File .\LocalSecurityPolicies.txt
'On your MIM Server, open Local Security Policy from Administrative Tools, expand out Local Policies > User Rights Assignment' | Out-File .\LocalSecurityPolicies.txt -append
'Assign the users to the associated policies below:' | Out-File .\LocalSecurityPolicies.txt -append
'----------------------------------------------------------------------------------------------------------------------------' | Out-File .\LocalSecurityPolicies.txt -append
'' | Out-File .\LocalSecurityPolicies.txt -append
'Log on as a service' | Out-File .\LocalSecurityPolicies.txt -append
$NetBIOS + '\' + $SyncAccount + '; ' + $NetBIOS + '\' + $MAaccount + '; ' + $NetBIOS + '\' + $ServiceAccount + '; ' + $NetBIOS + '\' + $SharepointAccount + '; ' + $NetBIOS + '\' + $SSPRaccount | Out-File .\LocalSecurityPolicies.txt -append
'' | Out-File .\LocalSecurityPolicies.txt -append
'Deny access to this computer from the network' | Out-File .\LocalSecurityPolicies.txt -append
$NetBIOS + '\' + $SyncAccount + '; ' + $NetBIOS + '\' + $ServiceAccount | Out-File .\LocalSecurityPolicies.txt -append
'' | Out-File .\LocalSecurityPolicies.txt -append
'Deny log on locally' | Out-File .\LocalSecurityPolicies.txt -append
$NetBIOS + '\' + $SyncAccount + '; ' + $NetBIOS + '\' + $ServiceAccount | Out-File .\LocalSecurityPolicies.txt -append