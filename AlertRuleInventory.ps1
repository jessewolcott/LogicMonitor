# Output an "inventory" of your Alert Rules. Built on the Logic.Monitor module by Steve Villardi at https://github.com/stevevillardi/Logic.Monitor

Update-Module Logic.Monitor -Confirm:$false
Update-Module PSMarkdown

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
    $EscalationInventory | Where-Object {$_.id -eq  $ID}
                        }

$Results = @()

foreach ($Alertrule in $AlertRuleInventory){
    
    $Results += [PSCustomObject]@{
        'Alert ID'                      = ($Alertrule.id)
        'Alert Rule'                    = ($Alertrule.name)
        'Priority'                      = ($Alertrule.priority)
        'Minimum Alert Severity'        = ($Alertrule.levelstr)
        'Alert Throttling Period (min)' = ($EscalationPathsInUse | Where-Object {$_.id -EQ ($Alertrule.escalatingChainId)}).throttlingPeriod
        'Alert Throttling Count'        = ($EscalationPathsInUse | Where-Object {$_.id -EQ ($Alertrule.escalatingChainId)}).throttlingalerts
        'Escalation Chain Name'         = ($EscalationPathsInUse | Where-Object {$_.id -EQ ($Alertrule.escalatingChainId)}).Name
        'Escalation Chain Description'  = ($EscalationPathsInUse | Where-Object {$_.id -EQ ($Alertrule.escalatingChainId)}).description
        'Escalation Chain Stages'       = @(((($EscalationPathsInUse | Where-Object {$_.id -EQ ($Alertrule.escalatingChainId)}).destinations).stages).addr)
        'Escalation Interval'           = ($Alertrule.escalationInterval)
        }
    }

$Results | Out-GridView
#$Results | ConvertTo-Excel -FilePath "$Psscriptroot\LogicMonitor-AlertRulesInventory.xlsx" -AutoFilter -AutoFit -FreezeTopRow -ExcelWorkSheetName "Alert Rules"
#$Results | ConvertTo-Markdown | Out-File -filePath "LogicMonitor-AlertRulesInventory.md"
