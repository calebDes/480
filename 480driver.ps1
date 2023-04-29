Import-Module '480-utils' -Force

#l
480Banner
#$conf = Get-480Config -config_path = "/home/caleb/480/480.json"
#480Connect -server $conf.vcenter_server
#Write-Host "Selecting your VM: "
#Select-vm -folder "BASEVM"

for ($i=1;$i -le 3; $i++){
    cloner
}
