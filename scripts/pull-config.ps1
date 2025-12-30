param(
  [string]$HostIp = '
100.66.215.17
',
  [string]$User = 'administrator',
  [string]$KeyPath = '
C:\Users\adm_manoah
\\.ssh\\id_ed25519_erp'
)

$ssh = 'C:\\Windows\\System32\\OpenSSH\\ssh.exe'
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$outDir = Join-Path  ('..\\inventory\\' + $ts)
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

function Run-Remote([string]$cmd, [string]$outFile){
  & $ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=C:\Users\ADM_MA~1\AppData\Local\Temp\\ssh_known_hosts -i $KeyPath ($User + '@' + $HostIp) $cmd | Out-File -FilePath (Join-Path $outDir $outFile) -Encoding ASCII
}

Run-Remote 'hostname' 'hostname.txt'
Run-Remote 'cat /etc/os-release' 'os-release.txt'
Run-Remote 'uname -a' 'uname.txt'
Run-Remote 'ip addr' 'ip-addr.txt'
Run-Remote 'ip route' 'ip-route.txt'
Run-Remote 'ss -ltnp' 'listening-tcp.txt'
Run-Remote 'systemctl list-units --type=service --state=running' 'services-running.txt'
Run-Remote 'ufw status verbose' 'ufw-status.txt'
Run-Remote 'dpkg -l' 'packages.txt'
Run-Remote 'tailscale status' 'tailscale-status.txt'

Write-Host ('Snapshot complete: ' + $outDir)

