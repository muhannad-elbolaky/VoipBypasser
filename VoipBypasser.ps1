Set-PSDebug -Off
Write-host ""
Write-host ""
Write-host "(--> Getting things done... please wait!! <--)"
Write-host ""
Write-host ""

$SettingsREPO = "https://raw.githubusercontent.com/Majoramari/VoipBypasser/master/settings.json"
$routeREPO = "https://raw.githubusercontent.com/Majoramari/VoipBypasser/master/route.bat"
try {
    $Settings = Get-Content -Path $pwd"\settings.json" -erroraction stop | ConvertFrom-Json 
}
catch {
    Invoke-WebRequest -Uri $SettingsREPO -OutFile $pwd"\settings.json"
    $Settings = Get-Content -Path $pwd"\settings.json" | ConvertFrom-Json
}

# ? Global Variables
$vpnName = $Settings.vpnName
$vpnServerAddress = $Settings.ServerAddress
$vpnUserName = $Settings.Username
$vpnPassword = $Settings.Password

# ? Get hostname
if (!$vpnServerAddress) { 
    Write-host ""
    Write-host ""
    Write-host "You have to define a vpn hostname to continue"
    $Settings.ServerAddress = Read-Host 'please visit https://www.vpngate.net/ and get one...'
    Write-host "(Right-click or CTRL+V to paste)"
    Write-host ""
    Write-host ""
    $vpnServerAddress = $Settings.ServerAddress
    $Settings | ConvertTo-Json -depth 100 | Out-File  $pwd"\settings.json"
}

function Connect-VPN {
    $cmd = $env:WINDIR + "\System32\rasdial.exe"
    $expression = "$cmd $vpnName $vpnUserName $vpnPassword"
    Invoke-Expression -Command $expression -erroraction silentlycontinue
}

function Disconnect-VPN {
    $cmd = $env:WINDIR + "\System32\rasdial.exe"
    $expression = "$cmd $vpnName /disconnect"
    Invoke-Expression -Command $expression -erroraction silentlycontinue
}

$vpn = Get-VpnConnection -Name $vpnName -erroraction silentlycontinue
if ($vpn) { 
    Disconnect-VPN
    Remove-VpnConnection -Name $vpnName -Force -erroraction silentlycontinue 
}

# ? Setup VPN network
Add-VpnConnection -RememberCredential -Name $vpnName -ServerAddress $vpnServerAddress -SplitTunneling
    (Get-Content $env:USERPROFILE"\AppData\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk") -Replace 'IpInterfaceMetric=.*', 'IpInterfaceMetric=200' | Set-Content $env:USERPROFILE"\AppData\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk"
    (Get-Content $env:USERPROFILE"\AppData\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk") -Replace 'Ipv6InterfaceMetric=.*', 'Ipv6InterfaceMetric=200' | Set-Content $env:USERPROFILE"\AppData\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk"
Connect-VPN

if ($vpn.ConnectionStatus -eq "Disconnected") { Connect-VPN }

Start-Sleep 5 
Invoke-WebRequest -Uri $routeREPO -OutFile $pwd"\route.bat"
Start-Process -FilePath $pwd"\route.bat" -Verb RunAs
Clear-Host

Write-host ""
Write-host "DONE!"
Write-host ""
Write-host "(--> After you finish playing press any key to close the VPN <--)"
Write-host ""
Write-host ""

pause

Disconnect-VPN
Remove-VpnConnection -Name $vpnName -Force -erroraction silentlycontinue 