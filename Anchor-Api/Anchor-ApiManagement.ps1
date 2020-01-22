#region Credits and Documentation
# Bryan Sullo - bryan@clocktowertech.com
# Anchor API Documentation: http://developer.anchorworks.com/v2/

# Query parameters go in the body, formatted as a hash table @{"parameter_name"="value"}
# Format date parameters like this @{"since"=(Get-Date (Get-Date).AddDays(-1) -Format "yyyy-MM-ddThh:mm:ss")}

#endregion


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
            Get-AnchorFile -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery -SavePath $myLocalPath -Force $Force
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
            'login_required' = $login_required
            'expires' = $expiresValue
            'subscribers'=[string]$($subscribers -join ',')
            'notify_subscribers'=$notify_subscribers
            'download_limit'=$download_limit
            'download_notify'=$download_notify
        }
    }
    process{
        $rootId = $root_id
        $fileId = $id
        #$fileMetadata = Get-AnchorFileMetadata -root_id $rootId -id $fileId
        #$fileName = Split-Path $($fileMetadata.path) -Leaf
        $apiEndpoint = "files/$rootId/$fileId/share"
        try{
            Post-AnchorApi -OauthToken $Script:anchorOauthToken -ApiEndpoint $apiEndpoint -ApiQuery $apiQuery
        }
        catch{
            Switch -regex ($Error[0].Exception){
                default {Write-Host $error[0].Exception}
            }
        }
    }
}


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
