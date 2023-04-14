<# Use TLS 1.2 #>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

<# account info #>
$accessId = ''
$accessKey = ''
$company = ''

Connect-LMAccount -AccessId $accessId -AccessKey $accessKey -AccountName $company

$AlertRuleInventory  = Get-LMAlertRule
$EscalationInventory = Get-LMEscalationChain

$EscalationPathsInUse = foreach ($ID in (($AlertRuleInventory.escalatingChainId) | Select-Object -Unique)){
    Get-LMEscalationChain -id $ID
                        }

$Results = @()

foreach ($Alertrule in $AlertRuleInventory){
    
    $AlertID        = [int]($Alertrule.escalatingChainID)
    $EscalationName = ($EscalationPathsInUse | Where-Object {$_.Name -like $AlertID})

    $Results += [PSCustomObject]@{
        'Alert ID'                      = ($Alertrule.id)
        'Alert Rule'                    = ($Alertrule.name)
        'Priority'                      = ($Alertrule.priority)
        'Minimum Alert Severity'        = ($Alertrule.levelstr)
        'Alert Throttling Period (min)' = ($EscalationPathsInUse | Where-Object {$_.id -EQ ($Alertrule.escalatingChainId)}).throttlingPeriod
        'Alert Throttling Count'        = ($EscalationPathsInUse | Where-Object {$_.id -EQ ($Alertrule.escalatingChainId)}).throttlingalerts
        'Escalation Chain Name'         = ($EscalationPathsInUse | Where-Object {$_.id -EQ ($Alertrule.escalatingChainId)}).Name
        'Escalation Chain Description'  = ($EscalationPathsInUse | Where-Object {$_.id -EQ ($Alertrule.escalatingChainId)}).description
        'Escalation Interval'           = ($Alertrule.escalationInterval)
        }
    }

$Results | Out-GridView
            
