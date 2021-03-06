param($path = [Environment]::GetFolderPath("Desktop")+'\'+'OrphanedGroups-'+(Get-Date -format M-d-yyyy)+'.csv')

$(function ModCheck
{
	Param([string]$modName)
	If (-not(Get-Module -name $modName)) { 
		If (Get-Module -ListAvailable | Where-Object { $_.name -eq $modName }) { 
			Import-Module -Name $modName 
			Write-Host "Loaded " $modName " module."
			}
		else {
			Write-Host $modName " module not available. Unable to continue." 
			}
		}
}

ModCheck ActiveDirectory

$users = (Get-AdUser -Filter * | 
Where-Object {$_.DistinguishedName -notlike "*OU=NetIQRecycleBin,DC=dolby,DC=net"})

foreach($item in $users){
	$Name = $item
	$ObjGUID = ('NetIQRecycleBinObj_{' + (Get-ADUser $Name).ObjectGUID + '}')

	Get-ADGroup -Filter {name -eq $ObjGUID} -SearchBase "OU=NetIQRecycleBin,DC=dolby,DC=net" -Properties description |
	
	ForEach-Object {
		$result = New-Object PSObject
	    Add-Member -input $result NoteProperty 'Group Name' $_.Name
		Add-Member -input $result NoteProperty 'Distinguished Name' $_.DistinguishedName
		Add-Member -input $result NoteProperty 'Linked User Name' $Name.name
		Add-Member -input $result NoteProperty 'Linked User Login' $Name.SamAccountName
	    Write-Output $result
	}
}) | Export-Csv $path -NoTypeInformation

If (Test-Path $path) { 
    Write-Host -NoNewline `n"Export of all orphaned NetIQ Recylce Bin group objects exported to the following file:" `n `n $path `n `n
} Else {
	Write-Host -NoNewline `n"Could not write to the following path:" `n `n $path `n `n"Please check the path and try again."`n `n
}

