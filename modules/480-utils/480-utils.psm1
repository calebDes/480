function 480Banner()
{
    write-Host "hello"
    Write-Host $480Banner
}
Function 480Connect([string] $server){
    $conn = $global:DefaultVIServer
    if($conn){
        $msg= "already connected to : {0}" -f $conn
        write-Host -ForegroundColor Green $msg
    }
    else{
        $conn = Connect-VIServer -server $server
        
    }
}

function  Get-480Config([string] $config_path) {
Write-Host "Reading " $config_path
$conf=$null
if(Test-Path $config_path)
{
    $conf = (Get-Content -Raw -Path $config_path | ConvertFrom-Json)
    $msg = "Using Configuration at {0}" -f $config_path
    Write-Host -ForegroundColor "Green" $msg
} else
{
    Write-Host -ForegroundColor "yellow" "No Configuration"
}
return $conf
}

function  Select-VM([string] $folder){
    $selected_vm=$null
    try {
        $vms = Get-VM -Location $folder
        $index =1
        foreach($vm in $vms)
        {
            Write-Host [$index] $vm.Name
            $index+=1
        }
        $pick_index = Read-Host "which index number [x] do you wish to pick?"
        $selected_vm = $vms[$pick_index -1]
        Write-Host "You picked " $selected_vm.Name
        return $selected_vm
    }
    catch {
        Write-Host "Invalid Folder: $folder" -ForegroundColor "Red"
    }
    }
    function linked{
        $vm_host = Get-VMHost -Name "192.168.7.35"
        $datastore = Get-Datastore -Name "datastore_super25"
        $target_vm = Get-VM "480-fw"
        $snap = Get-Snapshot -VM $target_vm -Name "base"
        $newvmname = Read-Host -Prompt "what is the new vm"
        $new_vm = New-VM -Name $newvmname -VM $target_vm -LinkedClone -ReferenceSnapshot $snap -VMHost $vm_host -Datastore $datastore
        $new_vm | New-Snapshot -Name "Base"
    }

    function gather{
        $vm_host = Read-Host -Prompt "Enter in the vcenter host or IP you would like to manage:(default is 192.168.7.35)"
        if($vm_host -ne ""){
            Write-Output "You have selected" $vmhost
        }
        else{
            $vm_host="192.168.7.35"
            Write-Output "You have selected" $vmhost
        }
        $datastore = Read-Host -Prompt "Where do you want to store the VM: (default is datastore_super25)"
        if($datastore -ne ""){
            Write-Output "You have selected" $datastore
        }
        else{
            $datastore = Get-DataStore -Name "datastore_super25"
            Write-Output "You have selected" $datastore
        }
        Write-Output "your esxi host is " $vm_host
        Write-Output "your Datastore is " $datastore
    }

    function networkswitch{
        $vmhost=Get-VMHost -Name "192.168.7.35"
        $newswitch = Read-Host "switch name?"
        $currentswitches = Get-VirtualSwitch
        #Check to see if the Switch Exists
        while ($currentswitches){
            if($currentswitches -contains $newswitch){
                    Write-host "A virtual switch with the name '$newswitch' already exists. Please enter a new name:"
                    $currentswitches = $false
            }
            else{
                try{
                    New-VirtualSwitch -VMHost $vmhost -Name $newswitch
                    break
                }
                catch [VMware.VimAutomation.ViCore.Validation.ValidationException]{
                    Write-Error "Error: $($_.Exception.Message)"
            }
            }
        }
        }
        function Get-IP{
            Get-VM
            $vmList = Get-VM
            $vmName = Read-Host "What VM IP address do you want"
            foreach ($vm in $vmList) {
                if ($vm.Name -eq $vmName) {
                    Write-Host "The VM $vmName has been found."
                    break
                }
            }
            $IpAddress = Get-VM $vmName -ErrorAction SilentlyContinue | Select-Object @{N="IP Address";E={@($_.Guest.IPAddress[0])}} | Select-Object -ExpandProperty "IP Address"
            $Mac = Get-VM $vmName -ErrorAction SilentlyContinue | Get-NetworkAdapter -Name "Network adapter 1" | Select-Object -ExpandProperty MacAddress
        
            $msg = "{0} hostname={1} mac={2}" -f $IpAddress,$vmName,$Mac
        
            Write-Host $msg
            if ($vm.Name -ne $vmName) {
                Read-Host "The VM '$vmName' was not found. Press Enter to try again."
            }   
        }

        function power{
            $vmlist = @(Get-VM | Select-Object -ExpandProperty Name)
            Get-VM
            $Selected_VM = Read-Host "what VM do you want on"
            while ($vmlist -notcontains $Selected_VM) {
                Write-Host $Selected_VM "try again"
                $Selected_VM = Read-Host "what VM do you want on"
            }
            $powerstate = Read-Host "Would you like to turn the VM on? (yes/no)"
        
            if($powerstate -like "yes"){
                Start-VM -VM $Selected_VM
                Get-VM $Selected_VM | Select-Object Name,powerstate
            }
            elseif($powerstate -like "no"){
                exit
            }
                Write-Host "try again:"
                power
            }   
    
            function network{
                $vmlist = @(Get-VM | Select-Object -ExpandProperty Name)
                Get-VM
                $vmList = Get-VM
                $vmName = Read-Host "What VM would you like the IP address for"
                foreach ($vm in $vmList) {
                if ($vm.Name -eq $vmName) {
                    # VM is found, write message and end loop
                    Write-Host "The VM '$vmName' has been found."
                    break
                }
            }
                if ($vm.Name -ne $vmName) {
                    Write-Host "Name for VM is not valid"
                    $vmName = Read-Host "What VM would you like the IP address for"
                }
                
                write-host -ForegroundColor Red "Available Networks"
                $networklist = Get-VirtualNetwork | Select-Object Name
                Get-VirtualNetwork | Select-Object Name
    $networkSelection = Read-Host "Choose your network"
    foreach($network in $networklist){
        if ($network.Name -eq $networklist){
            Write-Host "The Network '$networkSelection' has been found"
            break
        }
    }
    if ($network.Name -eq $networklist) {
        Write-Host "Invalid Network"
        $networkSelection = Read-Host "Choose your network" 
    }

    Get-NetworkAdapter -VM $vmName | Select-Object -ExpandProperty Name
    
    $networkadapterlist = Get-NetworkAdapter -VM $vmName | Select-Object -ExpandProperty Name
    Get-NetworkAdapter -VM $vmName | Select-Object -ExpandProperty Name
    $networkadapter = Read-Host "Select a network adapter"
    foreach($adapter in $networkadapterlist){
        if($networkadapter -eq $networkadapterlist){
            Write-Host "The Network Adapter'$networkadapter' has been found"
            break
        }
    }

    Get-VM $vmName | Get-NetworkAdapter -Name $networkadapter | Set-NetworkAdapter -NetworkName $networkSelection
}

function clone{
    $vmhost=Get-VMHost -Name "192.168.7.35"
    $ds = Get-DataStore -Name "datastore_super25"
    Get-VM
    $vmList = Get-VM
    $vmName = Read-Host "What VM would you like to pick"
    foreach ($vm in $vmList) {
    if ($vm.Name -eq $vmName) {
        # VM is found, write message and end loop
        Write-Host "The VM '$vmName' has been found."
        break
    }
    }
    if ($vm.Name -ne $vmName){
        write-Host "Invalid Request"
        $vmName = Read-Host "What VM would you like to pick"
    }
    #selectfolder
    $snapshot = Get-Snapshot -VM $vm -Name "Base"
    $linkedclone = "{0}.linked" -f $vm.name
    $linkedvm = New-VM -LinkedClone -Name $linkedclone -VM $vmName -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds	
    Get-VM
    Write-Output "Moving on to creating Full VM"

    $newvmname = Read-host -Prompt "What is the new VM name"
    $newvm = New-VM -Name $newvmname -VM $linkedvm -VMHost $vmhost -Datastore $ds
    $newvm | New-Snapshot -Name "base"
    Get-VM
    pause
    Write-Output "Removing LinkedVM now"
    $linkedvm | Remove-VM
    Get-VM
    } 
    function switch{
        $vmhost=Get-VMHost -Name "192.168.7.35"
        $newswitch = Read-Host "What would you like to name the new switch?"
        $currentswitches = Get-VirtualSwitch
        while ($currentswitches){
            if($currentswitches -contains $newswitch){
                    Write-host "$newswitch already exists. enter a new name:"
                    $currentswitches = $false
            }
            else{
                try{
                    New-VirtualSwitch -VMHost $vmhost -Name $newswitch
                    break
                }
                catch {
                    Write-Error "Error: $($_.Exception.Message)"
            }
            }
        }
    }

    function port{
        $currentportgroups = Get-VirtualPortGroup
        $newportgroup = Read-Host "name port group?"
        while ($currentportgroups -contains $newportgroup){
            $newportgroup = Read-Host "$newportgroup already existsenter a new name"
            $currentportgroups = Get-VirtualPortGroup -Name $newportgroup -ErrorAction SilentlyContinue
        }
        Get-VirtualSwitch
        $switch = Read-Host "What Virtual Switch would you like to make the port group for"
    
        New-VirtualPortGroup -VirtualSwitch $switch -Name $newportgroup
    }

    function cloner{
        $vm_host = Get-VMHost -Name "192.168.7.35"
        $datastore = Get-Datastore -Name "datastore_super25"
        $target_vm = Get-Vm "rocky.9.1.base"
        $snap = Get-Snapshot -VM $target_vm -Name "Base"
        $newvmname = Read-Host -Prompt "what is the new vm"
        $new_vm = New-VM -Name $newvmname -VM $target_vm -LinkedClone -ReferenceSnapshot $snap -VMHost $vm_host -Datastore $datastore -NetworkName "480_LAN"
        #$new_vm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "480_LAN"
        $new_vm | New-Snapshot -Name "Base"
        Start-VM -VM $newvmname
    }