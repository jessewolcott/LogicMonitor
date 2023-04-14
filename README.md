# LogicMonitor
LogicMonitor is a cool product, but its as deep as it is customizable. Here are some things I have sorted out.

## ActiveDirectory-ServerInventory.ps1
Set your OU's and domain and get a CSV in the format that LM wants for import.

## Add-SQL-Monitoring-User.sql

Set your Windows user to add to each database you'd like to monitor. If your LogicMonitor databases are complaining about JDBC Connection Strings being missing, its because LogicMonitor assumes (if your WMI user is not in the server) that you are attempting to connect to an Azure DB, Docker, or Linux DB. The error is unhelpful. 

## AlertRuleInventory.ps1

I was configuring escalation chains and found that there was no easy way to output a report of my alert rules. You could definitely spruce this up with PSWriteOffice and output it to Excel. Massive shout-outs to [Steve Villardi](https://github.com/stevevillardi/Logic.Monitor) for his excellent module to help accomplish this.
