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

Function Post-AnchorApi {
# Generic function for posting to an Anchor API endpoint.
# The full uri of the endpoint is passed as a string.
# The query (if needed) is passed as a hash table. This is the information that will be sent in the Body.
#   The function handles pagination, so there is no need to pass the offset in the query hashtable.
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
                $ApiQuery,
                $Tag,
                [int]$PageLimit
            )
            Write-Verbose "Invoke-RestMethod for $apiUri`/$ApiEndpoint begin at $(Get-Date)"
            try{
                $results = Invoke-RestMethod -Uri "$apiUri`/$ApiEndpoint" -Method Post -Headers $headers -Body $ApiQuery
            }
            catch{
                $results = $_.Exception.Response.StatusDescription
            }
            Write-Verbose "Invoke-RestMethod for $apiUri`/$ApiEndpoint complete at $(Get-Date)"

            If ($results.PSobject.Properties.name -eq "results") { # The returned object contains a property named "results" and is therefore a collection. We have to do some magic to extract all the data. 
                $myResults = $results.results
                If($myResults -is [Array]){
                    $tempObj = [pscustomobject]@()
                    foreach ($result in $myResults){
                        $tempObj += [pscustomobject]@{'value' = $result; 'tag' = $Tag}
                    }
                    $myResults = $tempObj
                }
                Else{
                    $myResults | ForEach-Object {
                        $_ | Add-Member -MemberType NoteProperty -Name 'tag' -Value $Tag
                    }
                }
                $myResults # Return the first set of results.
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
                    #$results.results # Return the next batch of results.
                    If($myResults -is [Array]){
                        $tempObj = [pscustomobject]@()
                        foreach ($result in $myResults){
                            $tempObj += [pscustomobject]@{'value' = $result; 'tag' = $Tag}
                        }
                        $myResults = $tempObj
                    }
                    Else{
                        $myResults | ForEach-Object {
                            $_ | Add-Member -MemberType NoteProperty -Name 'tag' -Value $Tag
                        }
                    }
                    $myResults # Return the first set of results.
                    Write-Verbose "Invoke-RestMethod for $apiUri`/$ApiEndpoint complete at $(Get-Date)"
                }

            } Else { #This is an object (or empty, or an error).
                $results | Add-Member -MemberType NoteProperty -Name 'tag' -Value $Tag
                $results
            }
        }
        #endregion
    }
    process{
        #region BLOCK 3: Create runspace and add to runspace pool
        $runspaceParams = @{'headers'=$headers;'apiUri'=$apiUri; 'apiEndpoint'=$InputObject.ApiEndpoint; 'ApiQuery'=$InputObject.ApiQuery; 'Tag'=$InputObject.Tag; 'PageLimit'=$PageLimit}
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
