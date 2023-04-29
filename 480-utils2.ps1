
function selecthost{
    $vm_host = Read-Host -Prompt "Enter in the vcenter host or IP you would like to manage:(default is 192.168.7.35)"
    if($vm_host -ne ""){
        Write-Output "You have selected" $vmhost
    }
    else{
        $vm_host="192.168.7.35"
        Write-Output "You have selected" $vmhost
    }
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
    $datastore = Read-Host -Prompt "Enter in where you want to store the VM: (default is DataStore-Super25)"
    if($datastore -ne ""){
	    Write-Output "You have selected" $datastore
    }
    else{
	    $datastore = Get-DataStore -Name "DataStore1-Super1"
	    Write-Output "You have selected" $datastore
    }
    #$vm_host = Get-VMHost -Name "192.168.7.20"
    #$ds = Get-DataStore -Name "DataStore-Super25"
    Write-Output "your esxi host is " $vm_host
    Write-Output "your Datastore is " $datastore
}

function linked{
    $vm_host = Get-VMHost -Name "192.168.7.35"
    $datastore = Get-Datastore -Name "datastore_super25"
    $target_vm = Get-VM "480_fw"
    $snap = Get-Snapshot -VM $target_vm -Name "Base"
    $newvmname = Read-Host -Prompt "what is the new vm"
    $new_vm = New-VM -Name $newvmname -VM $target_vm -LinkedClone -ReferenceSnapshot $snap -VMHost $vm_host -Datastore $datastore
    $new_vm | New-Snapshot -Name "Base"
}
