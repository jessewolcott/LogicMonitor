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
    if (Test-Connection $Server -Quiet) {
        $IPCheck = ([System.Net.Dns]::GetHostAddresses($Server)).IPAddressToString | Where-Object {$_ -like "*.*.*.*"}
        if ($null -ne $IPCheck) {
            $DisplayName = "$Server"+"."+"$DomainTLD"
            if (($IPCheck.Count) -gt 1){               
                    $LMInventoryCSV += [PSCustomObject]@{
                        'IP'            = $IPCheck[0]
                        'DisplayName'   = $DisplayName
                        'Group'         = 'Default'
                        }
                        }
                    Else {
                        $LMInventoryCSV += [PSCustomObject]@{
                            'IP'            = $IPCheck
                            'DisplayName'   = $DisplayName
                            'Group'         = 'Default'
                            }
                    }
                }
            Else { Write-Output "$Server does not have an IP. Skipping."}
                }
        Else { Write-Output "$Server not reachable" }
            Write-Output "Next!"
        }

    


$LMInventoryCSV | Export-CSV -Path "$PSScriptRoot\LogicMonitorImport-$Today.csv" -Force -NoTypeInformation
