function CreateFirewallRulesForSqlServer() {
    New-NetFirewallRule -DisplayName "SqlServer TCP port 1433" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow -Profile Domain
    New-NetFirewallRule -DisplayName "SqlServer UDP port 1434 (Browser)" -Direction Inbound -Protocol UDP -LocalPort 1434 -Action Allow -Profile Domain
}