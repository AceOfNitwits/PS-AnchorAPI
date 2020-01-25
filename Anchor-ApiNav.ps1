#If(!$Script:anchorNav){$Script:anchorNav = @{}}
#If(!$Script:anchorNavParents){$Script:anchorNavParents = @{0=0}}

Function Confirm-AnchorNavValues{
    param(
        [switch]$all,
        [switch]$org,
        [switch]$root,
        [switch]$folder
    )
    If(!$Script:anchorNav){
        $Script:anchorNav = @{}
        $topOrgId = (Get-AnchorOrg -Top).id
        $Script:anchorNav.CurrentOrgId = $topOrgId
    }
    If(!$Script:anchorNavParents){$Script:anchorNavParents = @{0=0}}
    If($org -or $all){
        If(!$Script:anchorNav.CurrentOrgId){
            $Script:anchorNav.CurrentOrgId = (Get-AnchorOrg -Top).id
        }
    }
    If($root -or $all){
        If(!$Script:anchorNav.CurrentRootId){
            Set-AnchorNavRoot
        }
    }
    If($folder -or $all){
        If(!$Script:anchorNav.CurrentFolderId){
            $Script:anchorNav.CurrentFolderId = 0
        }
    }
}

Function Get-AnchorNavChildItem {
    [CmdletBinding()]
    [Alias('adir')]
    [Alias('als')]
    param(
        [Parameter()][switch]$d
    )
    Confirm-AnchorNavValues -all
    Get-AnchorNavPath
    $myChildren = Get-AnchorFolderMetadata -root_id $Script:anchorNav.CurrentRootId -id $Script:anchorNav.CurrentFolderId -IncludeChildren | Select-Object -ExpandProperty children
    If ($d){
        $myChildren | Add-Member -MemberType ScriptProperty -Name 'name' -Value {Split-Path $this.path -Leaf} -PassThru | Where-Object type -eq 'folder' | FT -Property id, type, name, modified
    }
    Else{
        #$myChildren | Select-Object *, @{Name='name';Expression={Split-Path $_.path -Leaf}} | FT -Property id, name, created, modified
        $myChildren | Add-Member -MemberType ScriptProperty -Name 'name' -Value {Split-Path $this.path -Leaf} -PassThru | FT -Property id, type, name, modified
    }
}

Function Get-AnchorNavPath{
    [CmdletBinding()]
    [Alias('apwd')]
    param()
    Confirm-AnchorNavValues -all
    $orgName = (Get-AnchorOrg -id $Script:anchorNav.CurrentOrgId).name
    $rootName = (Get-AnchorRootMetadata -id $Script:anchorNav.CurrentRootId).name
    $folderPath = (Get-AnchorFolderMetadata -root_id $Script:anchorNav.CurrentRootId -id $Script:anchorNav.CurrentFolderId).path
#    [pscustomobject]@{'Current_Path'=[string]$("[$orgName]`:$rootName`:$folderPath")}
    [pscustomobject]@{'Organization'=$orgName;'Root'=$rootName;'Folder'=$folderPath} | FT -Wrap
}

Function Set-AnchorNavRoot {
    [CmdletBinding()]
    [Alias('acr')]
    param($target)
    Confirm-AnchorNavValues -org
    While([string]::IsNullOrEmpty($target)){
        Get-AnchorOrgRoots -id $anchorNav.CurrentOrgId | Select-Object id, name | Out-String
        $target = Read-Host "Select a root by id"
    }
    $Script:anchorNav.CurrentRootId = $target
    $Script:anchorNav.CurrentFolderId = 0
    Clear-Parents
    Get-AnchorNavPath
}

Function Get-AnchorNavRoots {
    [CmdletBinding()]
    [Alias('alr')]
    param()
    Confirm-AnchorNavValues -org
    Get-AnchorOrgRoots -id $Script:anchorNav.CurrentOrgId | FT -Property id, name
}

Function Get-AnchorNavOrgs {
    [CmdletBinding()]
    [Alias('alo')]
    [Alias('alc')]
    param()
    Confirm-AnchorNavValues -org
    Get-AnchorOrgChildren -id $Script:anchorNav.CurrentOrgId | FT -Property id, name
}

Function Set-AnchorNavOrg {
    [CmdletBinding()]
    [Alias('aco')]
    [Alias('acc')]
    param($target)
    Confirm-AnchorNavValues -org

    While([string]::IsNullOrEmpty($target)){
        Get-AnchorNavOrgs
        $target = Read-Host "Select an organization by id or enter '..' to go up."
    }

    If($target -eq '..'){ # Go up.
        $target = (Get-AnchorOrg -id $Script:anchorNav.CurrentOrgId).parent_id
    }
    $Script:anchorNav.CurrentOrgId = $target
    Set-AnchorNavRoot
    $Script:anchorNav.CurrentFolderId = 0
    Get-AnchorNavPath
}

Function Set-AnchorNavFolder {
    [CmdletBinding()]
    [Alias('acd')]
    param($target)
    Confirm-AnchorNavValues -org -root

    If($target -eq '..'){ # Go up.
        $target = $Script:anchorNavParents[$($Script:anchorNav.CurrentFolderId)]
    }


    If($target -eq $null){
        Write-Host "Usage:`n`r   acd <folder_id> : Go to specified folder.`n`r   acd .. : Go up one folder.`n`r   acd 0 : Go to root folder.`n`r   `n`r   Use als -d to get a list of folders in the current folder."
    }
    Else{
        $Script:anchorNav.CurrentFolderId = $target
    }
    Add-Parents -rootId $Script:anchorNav.CurrentRootId -folderId $Script:anchorNav.CurrentFolderId
    Get-AnchorNavPath
}

Function Add-Parents {
    [CmdletBinding()]
    param($rootId, $folderId)
    Get-AnchorFolderMetadata -root_id $rootId -id $folderId -IncludeChildren | Select-Object -ExpandProperty children | Where-Object type -eq folder | ForEach-Object {
        $Script:anchorNavParents[$($_.id)] = $folderId
    }
}

Function Clear-Parents {
    $Script:anchorNavParents = @{0=0}
}

Function Save-AnchorNavFile{
    [CmdletBinding()]
    [Alias('aget')]
    param(
        [Parameter(Mandatory,Position=0)]$file_id
    )
    Save-AnchorFile -root_id $Script:anchorNav.CurrentRootId -id $file_id
}