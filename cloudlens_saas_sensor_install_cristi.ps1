$download_folder = "C:\\temp_downloads"
new-item $download_folder -itemtype directory
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v0.0.19.0/OpenSSH-Win64.zip"
$download_ssh_sv_path = "C:\\temp_downloads\\win64-openssh.zip"
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($url, $download_ssh_sv_path)
# --- unzip
$ssh_extracted_dir = "C:\\Program Files\\OpenSSH"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($download_ssh_sv_path, $ssh_extracted_dir)
$openssh_install_folder="$ssh_extracted_dir\\OpenSSH-Win64"
# --- configure ssh
powershell -ExecutionPolicy Bypass -File "$openssh_install_folder\\install-sshd.ps1"
cd $openssh_install_folder
.\\ssh-keygen.exe -A
.\\FixHostFilePermissions.ps1 -Confirm:$false
New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH
Start-service sshd
Set-Service sshd -StartupType Automatic
# --- install python
$python_installer_path = "$download_folder\\python-2.7.7.amd64.msi"
$python_url = "https://www.python.org/ftp/python/2.7.7/python-2.7.7.amd64.msi"
$WebClient.DownloadFile($python_url, $python_installer_path)
Start-Process "msiexec.exe" -ArgumentList "/i $python_installer_path ALLUSERS=1 /quiet" -Wait
# --- install SSM
$ssm_agent_url = "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe"
$ssm_agent_location = "$download_folder\\AmazonSSMAgentSetup.exe"
$WebClient.DownloadFile($ssm_agent_url, $ssm_agent_location)
Restart-Service AmazonSSMAgent
# --- install pip AND python packets
$pip_url = "https://bootstrap.pypa.io/get-pip.py"
$pip_installer_path = "$download_folder\\get_pip.py"
$WebClient.DownloadFile($pip_url, $pip_installer_path)
C:\\Python27\\python.exe $pip_installer_path
C:\\Python27\\Scripts\\pip.exe install psutil
C:\\Python27\\Scripts\\pip.exe install netifaces
C:\\Python27\\Scripts\\pip.exe install dpkt
# --- install iperf
$iperf_url="https://iperf.fr/download/windows/iperf-3.1.3-win64.zip"
$iperf_installer_path="$download_folder\\iperf-3.1.3-win64.zip"
$WebClient.DownloadFile($iperf_url, $iperf_installer_path)
[System.IO.Compression.ZipFile]::ExtractToDirectory($iperf_installer_path, "C:\\Iperf3\")
[Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\\Python27\\;C:\\Python27\\Scripts\\;C:\\Iperf3\\iperf-3.1.3-win64\\", "User")
New-NetFirewallRule -Protocol TCP -LocalPort 5201 -Direction Inbound -Action Allow -DisplayName iPerfP1
New-NetFirewallRule -Protocol TCP -LocalPort 5202 -Direction Inbound -Action Allow -DisplayName iPerfP2
New-NetFirewallRule -Protocol TCP -LocalPort 5203 -Direction Inbound -Action Allow -DisplayName iPerfP3
New-NetFirewallRule -Protocol TCP -LocalPort 8080 -Direction Inbound -Action Allow -DisplayName CloudlensProfiling
# --- install agent
# --- cloud-update import
$agent_installer_path = "$download_folder\\CloudLensInstaller.exe"
$agent_url="https://agent.ixia-sandbox.cloud/updates/windows/latest"

$WebClient.DownloadFile($agent_url, $agent_installer_path)
Start-Sleep -s 60
Start-Process -FilePath $agent_installer_path -ArgumentList "/install /quiet Server_host=ixiacom/cloudlens-sandbox-agent API_Key=seU5zH68tQp4es3kmIOMhsanRBAUD6HFR2lnkDmhO"  -Wait
Start-Sleep -s 10