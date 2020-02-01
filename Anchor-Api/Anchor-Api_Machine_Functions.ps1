# Functions that take machine objects as input.

Function Get-AnchorMachine {
<#
    .SYNOPSIS
    Returns one or more AnchorMachine objects for a given AnchorMachine id or set of id's.

    .DESCRIPTION
    Returns one or more AnchorMachine objects.
    Accepts one or more AnchorMachine id's via argument or a colleciton of AnchorMachine objects from the pipeline.

    .NOTES
    
    .PARAMETER id
    One or more AnchorMachine id's.

    .INPUTS
    A collection of AnchorMachine objects

    .OUTPUTS
    A collection of AnchorMachine objects


    .LINK
    http://developer.anchorworks.com/v2/#get-a-machine

#>
    [CmdletBinding()]
    [Alias('AnchorMachine')]
    param(
        [Parameter(ParameterSetName='ById',Position=0,ValueFromPipelineByPropertyName)][string[]]$id
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        ForEach ($machineId in $id){
            $apiEndpoint = "machine/$machineId"
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
            # If there are no results, we don't want to return an empty object with just the organization property populated.
            If($results){
                # If more than one object is returned, we have to itterate.
                $results | ForEach-Object {
                    $_ | Add-Member -MemberType NoteProperty -Name 'last_login(local_offset)' -Value (Convert-UtcDateStringToLocalDateTime $_.last_login)
                    $_ | Add-Member -MemberType NoteProperty -Name 'created(local_offset)' -Value (Convert-UtcDateStringToLocalDateTime $_.created)
                    $_ | Add-Member -MemberType NoteProperty -Name 'last_disconnect(local_offset)' -Value (Convert-UtcDateStringToLocalDateTime $_.last_disconnect)
                    $_ | Add-Member -MemberType NoteProperty -Name 'company_id' -Value $orgId
                }
                $results
            }
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

Function Get-AnchorMachineBackup {
<#
    .SYNOPSIS
    Returns a collection of AnchorBackup objects for a given AnchorMachine id and AnchorRoot id.

    .DESCRIPTION
    Returns one or more AnchorBackup objects.
    Accepts one AnchorMachine id and one AnchorRoot id via argument or a colleciton of machine_id, root_id pairs from the pipeline.

    .NOTES
    
    .PARAMETER machine_id
    One or more AnchorMachine id's.

    .PARAMETER root_id
    One or more AnchorRoot id's.

    .INPUTS
    A collection of machine_id, root_id value pairs.

    .OUTPUTS
    A collection of AnchorBackup objects.

    .LINK
    http://developer.anchorworks.com/v2/#get-a-backup

#>
    [CmdletBinding()]
    [Alias('AnchorMachineBackup')]
    param(
        [Parameter(Position=0,ValueFromPipelineByPropertyName)][int]$machine_id,
        [Parameter(Position=1,ValueFromPipelineByPropertyName)][int]$root_id,
        [Parameter(Position=2)][switch]$Expand
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiQuery = @{
        }
    }
    process{
        # Get the expanded data we can get before calling the Api
        If($Expand){
            $myMachine = Get-AnchorMachine -id $machine_id
            $myMachineName = $myMachine.dns_name
            $myRoot = Get-AnchorRootMetadata -id $root_id
            $myRootName = $myRoot.name
        }
        $apiEndpoint = "machine/$machine_id/backup/$root_id"
        $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint #-ApiQuery $apiQuery
        # Process Results
        If($results){
            $classedResults = [pscustomobject]@()
            $results | ForEach-Object {
                # Get the rest of the expanded results
                If($Expand){}

                $classedObject = [AnchorBackup]$_
                $classedObject.machine_name = $myMachineName
                $classedObject.root_name = $myRootName
                $classedObject.root_data = $myRoot
                $classedObject.api_exception = $false
                $classedObject.queried_on = (Get-Date)
                $classedResults+=$classedObject
            }
            $classedResults
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

Function Get-AnchorMachineBackups {
# Accepts a number of Anchor machine id's or a piped collection of machine objects with .id properties.
# Returns the backup roots associated with each machine ID.
# It was a 500% increase in the lines of code, but it runs 210% faster using runspaces when passing all machines.
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor machine id')][string[]]$id
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        #region BLOCK 1: Create and open runspace pool, setup runspaces array with min and max threads
        #   Special thanks to Chrissy LeMaire (https://blog.netnerds.net/2016/12/runspaces-simplified/) for helping me to (sort of) understand how to utilize runspaces.

        # Custom functions are not available to runspaces. 🤦‍
        # We need to import some custom functions and script variables into the runspacepool, so we'll have to jump through hoops now.
        #   https://stackoverflow.com/questions/51818599/how-to-call-outside-defined-function-in-runspace-scriptblock
        $bagOfFunctions = @(
            'Get-AnchorData',
            'Validate-AnchorOauthToken',
            'Refresh-AnchorOauthToken',
            'Get-AnchorOauthStatus'
        )
        $bagOfVariables = @(
            'apiUri'
        )
        $InitialSessionState = [initialsessionstate]::Create()
        foreach ($function in $bagOfFunctions){
            #Get body of function
            $functionDefinition = Get-Content "Function:\$function" -ErrorAction Stop
            #Create a sessionstate function entry
            $SessionStateFunction = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList "$function", $functionDefinition
            #Create a SessionStateFunction
            $InitialSessionState.Commands.Add($SessionStateFunction)
        }
        foreach ($varName in $bagOfVariables){
            #Get variable
            $variable = Get-Variable -Name $varName
            #Create a sessionstate variable entry
            $SessionStateVariable = New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry($variable.Name, $variable.Value, $null)
            #Create a SessionStateVariable
            $InitialSessionState.Variables.Add($SessionStateVariable)
        }
            $InitialSessionState.LanguageMode = 'FullLanguage' #Without this, you get an error when you try to call EndInvoke at the end.

        # Now back to our regularly scheduled runspace pool creation
        $pool = [RunspaceFactory]::CreateRunspacePool(1,[int]$env:NUMBER_OF_PROCESSORS+1,$InitialSessionState,$Host)
        $pool.ApartmentState = "MTA"
        $pool.Open()
        $runspaces = @() #$results = @()
        #endregion

        #region BLOCK 2: Create reusable scriptblock. This is the workhorse of the runspace. Think of it as a function.
        $scriptblock = {
            Param (
                [string]$machineId,
                [object]$OauthToken
            )
            $apiEndpoint = "machine/$machineId/backups"
            $results = Get-AnchorData -OauthToken $OauthToken -ApiEndpoint $apiEndPoint -NoRefreshToken #Adding NoRefreshToken, because it doesn't work within a runspace.
            $results
        }
        #endregion
    }
    process{
        foreach ($machineId in $id){
            #region BLOCK 3: Create runspace and add to runspace pool
            $runspaceParams = @{'machineId'="$machineId";'OauthToken'=$Global:anchorOauthToken}
            $runspace = [PowerShell]::Create()
            $null = $runspace.AddScript($scriptblock)
            $null = $runspace.AddParameters($runspaceParams)
            $runspace.RunspacePool = $pool
            #endregion

            #region BLOCK 4: Add runspace to runspaces collection and "start" it
            # Asynchronously runs the commands of the PowerShell object pipeline
            $runspaces += [PSCustomObject]@{ Pipe = $runspace; Status = $runspace.BeginInvoke() }
            #endregion
        }
    }
    end{
        #region BLOCK 5: Wait for runspaces to finish
        while ($runspaces.Status -ne $null){
            $completed = $runspaces | Where-Object { $_.Status.IsCompleted -eq $true }
            #Monitor
            $notCompleted = $runspaces | Where-Object { $_.Status.IsCompleted -eq $false }
            [int]$notCompletedCount = $notCompleted.Count
            Write-Progress -Activity "Roots remaining to analyze (out of $($runspaces.Count))..." -Status $($notCompletedCount) -PercentComplete (($notCompletedCount / $runspaces.Count) * 100) -ErrorAction SilentlyContinue
            foreach ($runspace in $completed)
            {
                $runspace.Pipe.EndInvoke($runspace.Status)
                $runspace.Status = $null
            }
        }
        #endregion

        #region BLOCK 6: Clean up
        $pool.Close() 
        $pool.Dispose()
        #endregion
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Get-AnchorMachineLocalFolders {
<#
    .SYNOPSIS
    Returns a collection of folder names for a given AnchorMachine id or set of id's.

    .DESCRIPTION
    Returns an array of one or more folder names.
    Accepts one or more AnchorMachine id's via argument or a colleciton of AnchorMachine objects from the pipeline.

    .NOTES
    API Notes:
    - This is a POST request, not a GET, despite the fact that it does not move, add, or change anything.
    
    .PARAMETER id
    One or more AnchorMachine id's.

    .PARAMETER path
    The local (to the machine) path to enumerate.
    If not specified, local drives are enumerated.

    .PARAMETER username
    The username if path is a network path and requires authentication. Default none.

    .PARAMETER password
    The password if path is a network path and requires authentication. Default none.
    *** CAUTION ***
    Storing this parameter value in a script will reduce security and may violate security compliance policies.

    .INPUTS
    A collection of AnchorMachine objects

    .OUTPUTS
    An array of folder names.

    .LINK
    http://developer.anchorworks.com/v2/#list-files-on-a-file-server-enabled-machine

#>
    [CmdletBinding()]
    [Alias('AnchorLocalFolders')]
    param(
        [Parameter(Position=0,ValueFromPipelineByPropertyName)][string[]]$id,
        [Parameter(Position=1)][string]$path,
        [Parameter(Position=1)][string]$username,
        [Parameter(Position=1)][string]$password
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiQuery = @{
            'path' = "$path"
            'username' = "$username"
            'password' = "$password"
        }
        $apiCalls=@()
    }
    process{
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        ForEach ($machineId in $id){
            $apiEndpoint = "machine/$machineId/ls"
            #$results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint -ApiQuery $apiQuery
            $apiCall = @{'ApiEndpoint'=$apiEndpoint;'ApiQuery'=$apiQuery; 'Tag'=$machineId}
            $apiCalls += $apiCall
        }
    }
    end{
        $results = $apiCalls | Invoke-AnchorApiPost
        If($results){
            $results | ForEach-Object{
                $_ | Add-Member -MemberType NoteProperty -Name 'parent' -value $path
                $_ | Add-Member -MemberType AliasProperty -Name 'folder' -value value
                $_ | Add-Member -MemberType AliasProperty -Name 'machine_id' -value tag
            }
        }
        $results | Select-Object machine_id, parent, folder
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

Function Get-AnchorMachineFseMap {
<#
    .SYNOPSIS
    Returns a collection of AnchorMachineMap objects for a given AnchorMachine id or set of id's.

    .DESCRIPTION
    Returns one or more AnchorMachineMap objects.
    Accepts one or more AnchorMachine id's via argument or a colleciton of AnchorMachineMap objects from the pipeline.

    .NOTES
    
    .PARAMETER id
    One or more AnchorMachine id's.

    .INPUTS
    A collection of AnchorMachine objects

    .OUTPUTS
    A collection of AnchorMachineMap objects.

    .LINK
    http://developer.anchorworks.com/v2/#get-a-machine-mapping

#>
    [CmdletBinding()]
    [Alias('AnchorFseMap')]
    param(
        [Parameter(Position=0,ValueFromPipelineByPropertyName)][int]$machine_id,
        [Parameter(Position=1,ValueFromPipelineByPropertyName)][int]$mapping_id,
        [Parameter(Position=2)][switch]$Expand
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiQuery = @{
        }
    }
    process{
        # Get the expanded data we can get before calling the Api
        If($Expand){
            $myMachine = Get-AnchorMachine -id $machine_id
            $myMachineName = $myMachine.dns_name
        }
        $apiEndpoint = "machine/$machine_id/mapping/$mapping_id"
        $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint #-ApiQuery $apiQuery
        # Process Results
        If($results){
            $classedResults = [pscustomobject]@()
            $results | ForEach-Object {
                # Get the rest of the expanded results
                If($Expand){
                    $myRoot = Get-AnchorRootMetadata -id $_.root_id
                    $myRootName = $myRoot.name
                    $myPerson = Get-AnchorPerson -id $_.person_id
                    $myPersonName = $myPerson.display_name
                }
                $classedObject = [AnchorFseMap]$_
                $classedObject.machine_name = $myMachineName
                $classedObject.person_display_name = $myPersonName
                $classedObject.root_name = $myRootName
                $classedObject.root_data = $myRoot
                $classedObject.api_exception = $false
                $classedObject.queried_on = (Get-Date)
                $classedResults+=$classedObject
            }
            $classedResults
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

Function Get-AnchorMachineFseMaps {
<#
    .SYNOPSIS
    Returns a collection of AnchorMachineMap objects for a given AnchorMachine id or set of id's.

    .DESCRIPTION
    Returns one or more AnchorMachineMap objects.
    Accepts one or more AnchorMachine id's via argument or a colleciton of AnchorMachineMap objects from the pipeline.

    .NOTES
    
    .PARAMETER id
    One or more AnchorMachine id's.

    .INPUTS
    A collection of AnchorMachine objects

    .OUTPUTS
    A collection of AnchorMachineMap objects.

    .LINK
    http://developer.anchorworks.com/v2/#list-mapped-paths-on-a-file-server-enabled-machine

#>
    [CmdletBinding()]
    [Alias('AnchorFseMaps')]
    param(
        [Parameter(Position=0,ValueFromPipelineByPropertyName)][string[]]$id,
        [Parameter(Position=1)][switch]$Expand
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiQuery = @{
        }
    }
    process{
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        ForEach ($machineId in $id){
            # Get the expanded data we can get before calling the Api
            If($Expand){
                $myMachine = Get-AnchorMachine -id $machineId
                $myMachineName = $myMachine.dns_name
            }
            $apiEndpoint = "machine/$machineId/mappings"
            $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint #-ApiQuery $apiQuery
            # If there are no results, we don't want to return an empty object with just the organization property populated.
            If($results){
                $classedResults = [pscustomobject]@()
                $results | ForEach-Object {
                    # Get the rest of the expanded results
                    If($Expand){
                        $myRoot = Get-AnchorRootMetadata -id $_.root_id
                        $myRootName = $myRoot.name
                        $myPerson = Get-AnchorPerson -id $_.person_id
                        $myPersonName = $myPerson.display_name
                    }
                    $classedObject = [AnchorFseMap]$_
                    $classedObject.machine_name = $myMachineName
                    $classedObject.person_display_name = $myPersonName
                    $classedObject.root_name = $myRootName
                    $classedObject.root_data = $myRoot
                    $classedObject.api_exception = $false
                    $classedObject.queried_on = (Get-Date)
                    $classedResults+=$classedObject
                }
                $classedResults
            }
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

Function Get-AnchorMachineStatus {
<#
    .SYNOPSIS
    Returns one or more AnchorMachineStatus objects for a given AnchorMachine id or set of id's.

    .DESCRIPTION
    Returns one or more AnchorMachineStatus objects.
    Accepts one or more AnchorMachine id's via argument or a colleciton of AnchorMachine objects from the pipeline.

    .NOTES
    
    .PARAMETER id
    One or more AnchorMachine id's.

    .INPUTS
    A collection of AnchorMachine objects

    .OUTPUTS
    A collection of AnchorStatus objects


    .LINK
    http://developer.anchorworks.com/v2/#get-a-machine's-status

#>
    [CmdletBinding()]
    [Alias('AnchorMachineStatus')]
    param(
        [Parameter(ParameterSetName='ById',Position=0,ValueFromPipelineByPropertyName)][string[]]$id
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) begun at $(Get-Date)"
        Update-AnchorApiReadiness
    }
    process{
        # We might have multiple $id values passed via a function parameter . . . and that's okay.
        ForEach ($machineId in $id){
            $apiEndpoint = "machine/$machineId/status"
            try{
                $results = Get-AnchorData -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndPoint
                $exceptionResults = $null
            }
            catch{
                $exception = $_.Exception
                Switch ($exception.Response.StatusCode.value__){
                    503 {$exceptionResults = [pscustomobject]@{exception_id=503;exception_tag='no_status';exception_hint='This is probably a mobile device.'}}
                    default {$exceptionResults = [pscustomobject]@{exception_id=$($exception.Response.StatusCode.value__);exception_tag='unknown';exception_hint='Unknown exception'}}
                }
                $results = [pscustomobject]@{}
                #$exceptionResults
                #Break
            }
            # If there are no results, we don't want to return an empty object with just the calculated properties populated.
            If($results){
                # If more than one object is returned, we have to itterate.
                $results | ForEach-Object {
                    $_ | Add-Member -MemberType NoteProperty -Name 'machine_id' -Value $machineId
                    If($Expand){
                        $machineName = (Get-AnchorMachine -id $machineId).dns_name
                        $_ | Add-Member -MemberType NoteProperty -Name 'dns_name' -Value "$machineName"
                        #$_ | Add-Member -MemberType NoteProperty -Name 'last_disconnect(local_offset)' -Value (Convert-UtcDateStringToLocalDateTime $_.last_disconnect)
                        #$_ | Add-Member -MemberType NoteProperty -Name 'company_id' -Value $orgId
                    }
                    $_ | Add-Member -MemberType NoteProperty -Name 'apiException' -Value $exceptionResults
                }
                $results
            }
        }
    }
    end{
        Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
    }
}

Function New-AnchorMachineBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)][int]$id,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=1)][string]$path,
        [Parameter(ValueFromPipelineByPropertyName,Position=2)][string]$username,
        [Parameter(ValueFromPipelineByPropertyName,Position=3)][string]$password,
        [Parameter(HelpMessage='If set, all actions are automatically confirmed without user input.')]$Confirm
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiCalls=@()
    }
    process{
        ForEach ($machineId in $id){
            $apiEndpoint = "machine/$machineId/backups/create"
            # Create the array of API calls to make.
            $apiQuery = @{
                'path'=$path
            }
            $apiCall = @{'ApiEndpoint'=$apiEndpoint;'ApiQuery'=$apiQuery}
            $apiCalls += $apiCall
        }
    }
    end{
        # Confirmation
        If($Confirm){
            $confirmation='Y'
        }
        Else {
            Write-Host "You are about to attempt to create the following machine backups:"
            $apiCalls | ForEach-Object {Write-Host $($_.ApiQuery | out-string)}
            $confirmation = Read-Host "Confirm: [Y]es, [N]o (Default: No)"
        }
        # End Confirmation
        If($confirmation -eq 'Y'){
            [AnchorBackup[]]$results = $apiCalls | Invoke-AnchorApiPost
            If($results){
                $results.GeneratePwLastChangedPsLocal()
                $results.PopulateCompanyName() #company_name = (Get-AnchorOrg -id $($results.company_id)).name
                $results
            }
        }
        Else {
            Write-Host 'Action canceled. No machine backups created.'
        }
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Remove-AnchorMachineBackup {
<#
    .LINK
    http://developer.anchorworks.com/v2/#delete-a-backup
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0,HelpMessage='ID of the Backup root')][int]$id,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=1)][int]$machine_id,
        [Parameter(HelpMessage='If set, all actions are automatically confirmed without user input.')]$Confirm
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiCalls=@()
    }
    process{
        $apiEndpoint = "machine/$machine_id/backup/$id/delete"
        # Create the array of API calls to make.
        $apiQuery = @{
        }
        $apiCall = @{'ApiEndpoint'=$apiEndpoint;'ApiQuery'=$apiQuery}
        $apiCalls += $apiCall
    }
    end{
        # Confirmation
        If($Confirm){
            $confirmation='Y'
        }
        Else {
            Write-Host "You are about to attempt to DELETE the following machine backups:" -ForegroundColor Red
            $apiCalls | ForEach-Object {Write-Host $($_.ApiQuery | out-string)}
            $confirmation = Read-Host "Confirm: [Y]es, [N]o (Default: No)"
        }
        # End Confirmation
        If($confirmation -eq 'Y'){
            $results = $apiCalls | Invoke-AnchorApiPost
            If($results){
                $results
            }
        }
        Else {
            Write-Host 'Action canceled. No machine backups deleted.'
        }
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}
