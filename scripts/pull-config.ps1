param(
  [string]$HostIp = "100.66.215.17",
  [string]$User = "administrator",
  [string]$KeyPath = ($env:USERPROFILE + '\\.' + 'ssh\\id_ed25519_erp')
)

$ssh = 'C:\\Windows\\System32\\OpenSSH\\ssh.exe'
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$outDir = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath ('..\\inventory\\' + $ts)))
$knownHosts = Join-Path ([System.IO.Path]::GetTempPath()) 'ssh_known_hosts'
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

function Run-Remote([string]$cmd, [string]$outFile){
  $args = @('-o','BatchMode=yes','-o','StrictHostKeyChecking=no','-o',('UserKnownHostsFile=' + $knownHosts),'-i',$KeyPath, ($User + '@' + $HostIp), $cmd)
  & $ssh @args | Out-File -FilePath (Join-Path $outDir $outFile) -Encoding ASCII
}

Run-Remote 'hostname' 'hostname.txt'
Run-Remote 'cat /etc/os-release' 'os-release.txt'
Run-Remote 'uname -a' 'uname.txt'
Run-Remote 'ip addr' 'ip-addr.txt'
Run-Remote 'ip route' 'ip-route.txt'
Run-Remote 'ss -ltnp' 'listening-tcp.txt'
Run-Remote 'systemctl list-units --type=service --state=running' 'services-running.txt'
Run-Remote "sh -c 'sudo -n ufw status verbose 2>/dev/null || ufw status verbose 2>/dev/null || true'" 'ufw-status.txt'
Run-Remote 'dpkg -l' 'packages.txt'
Run-Remote 'tailscale status' 'tailscale-status.txt'

Write-Host ('Snapshot complete: ' + $outDir)
