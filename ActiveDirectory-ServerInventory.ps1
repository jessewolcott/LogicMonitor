# What OUs are we targetting?
$Full_OU_Paths = @(
"contoso.com/Servers",
"contoso.com/Domain Controllers")

# Whats the domain name?
$DomainTLD = ".contoso.com" 

#################### SCRIPT START ####################

# Module Check
# This section has so much room for improvement

#Install-WindowsFeature RSAT-AD-PowerShell
#Install-Module PSWriteHTML
#Install-Module PSWriteExcel

# End Module Check

$Today = (Get-Date -format MMddyyyy)

$OU_Paths = foreach ($Full_OU_Path in $Full_OU_Paths)
{Get-ADOrganizationalUnit -Filter * -Properties CanonicalName,Name,DistinguishedName | Where-Object -FilterScript {$_.CanonicalName -like "*$Full_OU_Path"} | Select-Object -ExpandProperty DistinguishedName}


    $ServerList = foreach ($OU_Path in $OU_Paths){
 ((Get-ADComputer -Filter "OperatingSystem -Like '*Windows Server*' -and Enabled -eq 'True' -and objectClass -eq 'computer'" -SearchBase $OU_Path -SearchScope Subtree -Properties DNSHostName,Name,Enabled,ObjectClass)| Select-Object -ExpandProperty Name)
    }

$LMInventoryCSV = @()

foreach ($Server in $Serverlist){
    Write-Output "Checking $Server"
    if (Test-Connection $Server -Quiet) 
        {$IP = ([System.Net.Dns]::GetHostAddresses($Server)).IPAddressToString}
        Else { $IP = '' }

    $DisplayName = "$Server"+"$DomainTLD"
    $LMInventoryCSV += [PSCustomObject]@{
                'IP'            = $IP
                'DisplayName'   = $DisplayName
                'Group'         = 'Default'
        }
    Write-Output "Next!"
    }


$LMInventoryCSV | Export-CSV -Path "$PSScriptRoot\LogicMonitorImport-$Today.csv" -Force -NoTypeInformation
