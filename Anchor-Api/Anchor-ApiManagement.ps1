#region Credits and Documentation
# Bryan Sullo - bryan@clocktowertech.com
# Anchor API Documentation: http://developer.anchorworks.com/v2/

# Query parameters go in the body, formatted as a hash table @{"parameter_name"="value"}
# Format date parameters like this @{"since"=(Get-Date (Get-Date).AddDays(-1) -Format "yyyy-MM-ddThh:mm:ss")}

#endregion

# General functions

# Activity functions

# File and Folder functions

Function Move-AnchorFile {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Position=0)][int]$root_id,
        [Parameter(ValueFromPipelineByPropertyName,Position=1)][int]$id,
        [Parameter(Position=2)][int]$to_folder_id,
        [Parameter(HelpMessage='If set, all actions are automatically confirmed without user input.')]$Confirm
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiCalls=@()
    }
    process{
        $apiEndpoint = "files/$root_id/$id/move"
        # Create the array of API calls to make.
        $apiQuery = @{
            'to_folder_id'=$(If($to_folder_id){$to_folder_id}Else{''}) # Can't use 0. Must use ''.
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
            Write-Host "You are about to attempt to move the following file(s):"
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
            Write-Host 'Action canceled. No files moved.'
        }
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Rename-AnchorFile {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Position=0)][int]$root_id,
        [Parameter(ValueFromPipelineByPropertyName,Position=1)][int]$id,
        [Parameter(Position=2)][string]$name,
        [Parameter(HelpMessage='If set, all actions are automatically confirmed without user input.')]$Confirm
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiCalls=@()
    }
    process{
        $apiEndpoint = "files/$root_id/$id/rename"
        # Create the array of API calls to make.
        $apiQuery = @{
            'name'=$name
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
            Write-Host "You are about to attempt to rename the following file(s):"
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
            Write-Host 'Action canceled. No files renamed.'
        }
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

Function Save-AnchorFile {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Root ID')][string[]]$root_id, 
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor File ID')][string[]]$id,
        [Parameter(ValueFromPipelineByPropertyName,Position=2,HelpMessage='Local file or folder path (or none for current directory)')][string]$local_path,
        [Parameter(Position=3,HelpMessage='Allow overwriting of existing files!')][switch]$Force
    )
    begin{
        
        #$apiQuery = @{}
    }
    process{
        $rootId = $root_id
        $fileId = $id
        $fileMetadata = Get-AnchorFileMetadata -root_id $rootId -id $fileId
        $fileName = Split-Path $($fileMetadata.path) -Leaf
        $apiEndpoint = "files/$rootId/$fileId/download"
        If($local_path){
            $myLocalPath = $local_path
        }
        Else{
            $myLocalPath = Get-Location
        }
        If(Test-Path $myLocalPath -PathType Container){
            $myLocalPath = Join-Path $myLocalPath $fileName
        }
        try{
            Get-AnchorFile -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery -SavePath $myLocalPath -Force $Force
        }
        catch{
            Switch -regex ($Error[0].Exception){
                default {Write-Host $error[0].Exception}
            }
        }
    }
}

Function New-AnchorFileShare {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=0,HelpMessage='Valid Anchor Root ID')][string]$root_id, 
        [Parameter(ValueFromPipelineByPropertyName,Mandatory,Position=1,HelpMessage='Valid Anchor File ID')][string]$id,
        [Parameter(ValueFromPipelineByPropertyName,Position=2,HelpMessage='Requires/Creates guest account')][switch]$login_required,
        [Parameter(ValueFromPipelineByPropertyName,Position=3,HelpMessage='Expiration Date')][datetime]$expires,
        [Parameter(ValueFromPipelineByPropertyName,Position=4,HelpMessage='list of subscriber email addresses')][string[]]$subscribers,
        [Parameter(ValueFromPipelineByPropertyName,Position=5,HelpMessage='Send an email to subscribers')][switch]$notify_subscribers,
        [Parameter(ValueFromPipelineByPropertyName,Position=6,HelpMessage='Number of times file can be downloaded')][int]$download_limit,
        [Parameter(ValueFromPipelineByPropertyName,Position=7,HelpMessage='Notify authenticated user when file is downloaded')][switch]$download_notify
    )
    begin{
        $expiresValue = If($expires){[string]$(Get-Date($expires) -Format 'yyyy-MM-dd')}Else{$null}
        $apiQuery = @{
            'login_required' = "$(If($login_required){"true"}Else{"false"})"
            'expires' = $expiresValue
            'subscribers'=[string]$($subscribers -join ',')
            'notify_subscribers'= "$(If($notify_subscribers){"true"}Else{"false"})"
            'download_limit'=$download_limit
            'download_notify'= "$(If($download_notify){"true"}Else{"false"})"
        }
    }
    process{
        $rootId = $root_id
        $fileId = $id
        #$fileMetadata = Get-AnchorFileMetadata -root_id $rootId -id $fileId
        #$fileName = Split-Path $($fileMetadata.path) -Leaf
        $apiEndpoint = "files/$rootId/$fileId/share"
        try{
            Post-AnchorApi -OauthToken $Global:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
        }
        catch{
            Switch -regex ($Error[0].Exception){
                default {Write-Host $error[0].Exception}
            }
        }
    }
}

# Group functions

# Guest functions

# Machine functions

# Organization functions

# Person functions

Function New-AnchorPerson {
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName='import')][string]$FromCsv,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=0)][int]$company_id,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=1)][string]$email,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=2)][string]$first_name,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=3)][string]$last_name,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=4)][string]$password,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=5)][switch]$generate_password,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=6)][datetime]$pw_expires,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=7)][switch]$webdav,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=8)][long]$space_quota,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=9)][string]$mobile_phone,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=10)][switch]$site_admin,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=11)][switch]$system_admin,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=12)][switch]$create_root,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=13)]$dept_shares, #unsure of the datatype or format here
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=14)]$group_ids, #unsure of datatype or format
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=15)][switch]$quota_50,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=16)][switch]$quota_80,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=17)][switch]$quota_85,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=18)][switch]$quota_90,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=19)][switch]$quota_95,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=20)][switch]$quota_100,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=21)][switch]$send_welcome_email,
        [Parameter(HelpMessage='If set, all actions are automatically confirmed without user input.')]$Confirm
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiEndpoint = "person/create"
        $apiCalls=@()
    }
    process{
        If($FromCsv){
            #File processing
            $csvData = Import-Csv -Path $FromCsv
            #$csvFields = Get-Member -InputObject $csvData[0] | Where-Object MemberType -eq NoteProperty
            $csvData | ForEach-Object {
                $apiQuery = @{}
                foreach ($property in $_.PSObject.Properties){
                    $apiQuery[$($property.Name)] = $property.Value
                }
            $apiCall = @{'ApiEndpoint'=$apiEndpoint;'ApiQuery'=$apiQuery}
            $apiCalls += $apiCall
            }
        }
        Else{
            # Create the array of API calls to make.
            $apiQuery = @{
                'company_id'=$company_id
                'email'=$email
                'first_name'=$first_name
                'last_name'=$last_name
                'password'=$password
                'generate_password'=$(If($generate_password){'true'}Else{'false'})
                'pw_expires'=$(If($pw_expires){$(Get-Date($pw_expires) -format 'yyyy-MM-ddThh:mm:ss')})
                'webdav'=$(If($webdav){'true'}Else{'false'})
                'space_quota'=$(If($space_quota){$space_quota}Else{''}) #$space_quota is an [int], which will become 0 if we don't supply a value.
                'mobile_phone'=$mobile_phone
                'site_admin'=$(If($site_admin){'true'}Else{'false'})
                'system_admin'=$(If($system_admin){'true'}Else{'false'})
                'create_root'=$(If($create_root){'true'}Else{'false'})
                'dept_shares'=$dept_shares
                'group_ids'=$group_ids
                'quota_50'=$(If($quota_50){'true'}Else{'false'})
                'quota_80'=$(If($quota_80){'true'}Else{'false'})
                'quota_85'=$(If($quota_85){'true'}Else{'false'})
                'quota_90'=$(If($quota_90){'true'}Else{'false'})
                'quota_95'=$(If($quota_95){'true'}Else{'false'})
                'quota_100'=$(If($quota_100){'true'}Else{'false'})
                'send_welcome_email'=$(If($send_welcome_email){'true'}Else{'false'})
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
            Write-Host "You are about to attempt to create the following user accounts:"
            $apiCalls | ForEach-Object {Write-Host $($_.ApiQuery | out-string)}
            $confirmation = Read-Host "Confirm: [Y]es, [N]o (Default: No)"
        }
        # End Confirmation
        If($confirmation -eq 'Y'){
            [AnchorPerson[]]$results = $apiCalls | Invoke-AnchorApiPost
            If($results){
                $results.GeneratePwLastChangedPsLocal()
                $results.PopulateCompanyName() #company_name = (Get-AnchorOrg -id $($results.company_id)).name
                $results
            }
        }
        Else {
            Write-Host 'Action canceled. No accounts created.'
        }
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

# Root functions

# Helper functions

# Generic function for returning data from an Anchor API endpoint.
# The full uri of the endpoint is passed as a string.
# The query (if needed) is passed as a hash table. This is the information that will be sent in the Body.
#   The function handles pagination, so there is no need to pass the offset in the query hashtable.
# The OauthToken is an object, returned from the Oauth function.
Function Get-AnchorFile {
    param(
        [Parameter(Mandatory,Position=0)][AllowNull()][object]$OauthToken,
        [Parameter(Mandatory,Position=1)][string]$ApiEndpoint, 
        [Parameter(Position=2)]$ApiQuery,
        [Parameter(Position=3)][string]$SavePath,
        [Parameter(Position=4,HelpMessage='Allow overwriting of existing file!')][switch]$Force,
        [Parameter(Position=5)][switch]$NoRefreshToken
    )
    Validate-AnchorOauthToken -OauthToken $OauthToken -NoRefresh $NoRefreshToken #Check to make sure the Oauth token is valid and refresh if needed.
    
    $tokenType = $OauthToken.token_type
    $accessToken = $OauthToken.access_token
    $headers = @{'Authorization' = "$tokenType $accessToken"}
    $body = $ApiQuery

    $results = Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Get -Headers $headers -Body $body -OutFile $savePath
    
    If ($results.PSobject.Properties.name -eq "results") { # The returned object contains a property named "results" and is therefore a collection. We have to do some magic to extract all the data. 
        #Write-Host "Collection"
        $results.results # Return the first set of results.
        $resultsCount = $results.results.count
        $totalResults = $results.total #The call will only return 100 objects at a time. This tells us if there are more to get.
        $body+=@{'offset' = '0'} #Because we're going to need to increment the offset, and we didn't have an offset as part of the query to begin, we have to add a zero-value offset before we can increment it.
        While ($totalResults -gt $resultsCount){ # Keep calling the endpoint until we've squeezed out all the data.
            $PageOffset+=100 # We want to get the next 100 results
            $body.offset = "$PageOffset" # Update the offset value for the next Api call.
            $results = Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Get -Headers $headers -Body $body
            $results.results # Return the next batch of results.
            $resultsCount+=$results.results.count
        }

    } Else { #This is an object (or empty). We can just return the results.
        #Write-Host "Object"
        $results
    }
}

# Generic function for posting to an Anchor API endpoint.
# The full uri of the endpoint is passed as a string.
# The query (if needed) is passed as a hash table. This is the information that will be sent in the Body.
#   The function handles pagination, so there is no need to pass the offset in the query hashtable.
Function Post-AnchorApi {
    param(
        [Parameter(Mandatory,Position=0)][AllowNull()][object]$OauthToken,
        [Parameter(Mandatory,Position=1)][string]$ApiEndpoint, 
        [Parameter(Position=2)]$ApiQuery,
        [Parameter(Position=3)][switch]$NoRefreshToken
    )
    Validate-AnchorOauthToken -OauthToken $OauthToken -NoRefresh $NoRefreshToken #Check to make sure the Oauth token is valid and refresh if needed.
    
    $tokenType = $OauthToken.token_type
    $accessToken = $OauthToken.access_token
    $headers = @{'Authorization' = "$tokenType $accessToken"}
    $body = $ApiQuery
    #Write-Host "$apiUri`/$ApiEndpoint"
    #Write-Host ($headers | out-string)
    #Write-Host ($body | out-string)
    Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Post -Headers $headers -Body $body
}

Function Invoke-AnchorApiPost { #New one!
<#
#>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName='byPipeline',ValueFromPipeline)]$InputObject,
        [Parameter(ParameterSetName='byParameter',Mandatory,Position=0)][string]$ApiEndpoint, 
        [Parameter(ParameterSetName='byParameter',Position=1)][hashtable]$ApiQuery,
        #[Parameter(HelpMessage='Limits the number of times an endpoint will be queried.')][int]$PageLimit,
        [Parameter()][int]$MaxThreads=([int]$env:NUMBER_OF_PROCESSORS + 1)
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        #Stuff that will be the same for all requests...
        $tokenType = $Global:anchorOauthToken.token_type
        $accessToken = $Global:anchorOauthToken.access_token
        $headers = @{'Authorization' = "$tokenType $accessToken"}
        If(!$InputObject){$InputObject = @{'ApiEndpoint'=$ApiEndpoint;'ApiQuery'=$ApiQuery}}

        #region BLOCK 1: Create and open runspace pool, setup runspaces array with min and max threads
        #   Special thanks to Chrissy LeMaire (https://blog.netnerds.net/2016/12/runspaces-simplified/) for helping me to (sort of) understand how to utilize runspaces.

        # Custom functions are not available to runspaces. 🤦‍
        # We need to import some custom functions and script variables into the runspacepool, so we'll have to jump through hoops now.
        #   https://stackoverflow.com/questions/51818599/how-to-call-outside-defined-function-in-runspace-scriptblock
        $bagOfFunctions = @(
        )
        $bagOfVariables = @(
            'headers'
            'apiUri',
            'ApiEndpoint',
            'ApiQuery'
        )

        $InitialSessionState = [initialsessionstate]::CreateDefault() #CreateDefault is important. If we just use Create, it creates a blank-slate session that has almost no functionality.
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
        # End Hoops

        # Now back to our regularly scheduled runspace pool creation
        Write-Verbose "Creating runspace pool with $MaxThreads concurrent threads."
        $pool = [RunspaceFactory]::CreateRunspacePool(1,$MaxThreads,$InitialSessionState,$Host)
        $pool.ApartmentState = "MTA"
        $pool.Open()
        $runspaces = @()
        #endregion

        #region BLOCK 2: Create reusable scriptblock. This is the workhorse of the runspace. Think of it as a function.
        
        $scriptblock = {
            Param (
                [hashtable]$headers,
                [string]$apiUri,
                [string]$ApiEndpoint,
                [hashtable]$ApiQuery,
                [int]$PageLimit
            )
            Write-Verbose "Invoke-RestMethod for $apiUri`/$ApiEndpoint begin at $(Get-Date)"
            $results = Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Post -Headers $headers -Body $ApiQuery
            Write-Verbose "Invoke-RestMethod for $apiUri`/$ApiEndpoint complete at $(Get-Date)"

            If ($results.PSobject.Properties.name -eq "results") { # The returned object contains a property named "results" and is therefore a collection. We have to do some magic to extract all the data. 
                $results.results # Return the first set of results.
                $resultsCount = $results.results.count
                $totalResults = $results.total #The call will only return 100 objects at a time. This tells us if there are more to get.
                $neededCallCount = [Math]::Ceiling($totalResults/100) #We would need this many API calls to return all the data.
                If($PageLimit -gt 0 -and $PageLimit -lt $neededCallCount){
                    $additionalCallCount = $PageLimit - 1 #We've already called it once.
                }
                Else{
                    $additionalCallCount = $neededCallCount - 1 #We've already called it once.
                }
                $body+=@{'offset' = '0'} #Because we're going to need to increment the offset, and we didn't have an offset as part of the query to begin, we have to add a zero-value offset before we can increment it.
                for ($offset=100; $offset -le $additionalCallCount; $offset+=100){
                    $body.offset = "$offset" # Update the offset value for the next Api call.
                    Write-Verbose "Invoke-RestMethod for $apiUri`/$ApiEndpoint begin at $(Get-Date)"
                    $results = Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Get -Headers $headers -Body $ApiQuery
                    $results.results # Return the next batch of results.
                    Write-Verbose "Invoke-RestMethod for $apiUri`/$ApiEndpoint complete at $(Get-Date)"
                }

            } Else { #This is an object (or empty). We can just return the results.
                $results
            }
        }
        #endregion
    }
    process{
        #region BLOCK 3: Create runspace and add to runspace pool
        $runspaceParams = @{'headers'=$headers;'apiUri'=$apiUri; 'apiEndpoint'=$InputObject.ApiEndpoint; 'ApiQuery'=$InputObject.ApiQuery; 'PageLimit'=$PageLimit}
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
    end{
        #region BLOCK 5: Wait for runspaces to finish
        Write-Verbose "Created $($runspaces.Count) PowerShell runspaces. Awaiting completion of all runspaces."
        while ($runspaces.Status -ne $null){
            $completed = $runspaces | Where-Object { $_.Status.IsCompleted -eq $true }

            #Monitor
            $notCompleted = $runspaces | Where-Object { $_.Status.IsCompleted -eq $false }
            [int]$notCompletedCount = $notCompleted.Count
            Write-Progress -Activity "Runspaces remaining to complete (out of $($runspaces.Count))..." -Status $($notCompletedCount) -PercentComplete (($notCompletedCount / $runspaces.Count) * 100) -ErrorAction SilentlyContinue
            #Write-Verbose $(Get-Runspace | out-string)
            #End Monitor

            foreach ($runspace in $completed)
            {
                $runspace.Pipe.EndInvoke($runspace.Status)
                $runspace.Status = $null
            }
        }
        Write-Verbose "All runspaces complete."
        #endregion

        #region BLOCK 6: Clean up
        $pool.Close() 
        $pool.Dispose()
        #endregion
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}
