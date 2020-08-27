$download_folder = "C:\\temp_downloads"
new-item $download_folder -itemtype directory
$Project_Key = <ProjectKey>
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$WebClient = New-Object System.Net.WebClient
# --- install agent
$agent_installer_path = "$download_folder\\CloudLensInstaller.exe"
$agent_url="https://agent.ixia.cloud/updates/windows/latest"
$WebClient.DownloadFile($agent_url, $agent_installer_path)
Start-Sleep -s 30
Start-Process -FilePath $agent_installer_path -ArgumentList "/install /quiet Server_host=ixiacom/cloudlens-agent API_Key=$Project_Key"  -Wait
Start-Sleep -s 10
# --- update agent with custom tags
# --- custom tags created in agent.yml file 
$agent_yml_dld = "$download_folder\\agent.yml"
$agent_yml_url="https://raw.githubusercontent.com/cristianior/cloudlens/master/agent.yml"
$agent_yml_path = "C:\ProgramData\CloudLens\Config\"
$WebClient.DownloadFile($agent_yml_url, $agent_yml_dld)
Stop-Service -Name CloudLens
Remove-Item -path $agent_yml_path -include *.*
Copy-Item -path $agent_yml_dld -Destination $agent_yml_path
Start-Service -Name CloudLens
