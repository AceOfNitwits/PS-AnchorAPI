#region Credits and Documentation
# Bryan Sullo - bryan@clocktowertech.com
# Anchor API Documentation: http://developer.anchorworks.com/v2/

# Query parameters go in the body, formatted as a hash table @{"parameter_name"="value"}
# Format date parameters like this @{"since"=(Get-Date (Get-Date).AddDays(-1) -Format "yyyy-MM-ddThh:mm:ss")}

#endregion

# General functions

# Activity functions

Function New-AnchorActivity {
<#
    .LINK
    http://developer.anchorworks.com/v2/#create-an-activity-record
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)][int]$activity_type_id,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=1)][string]$actor_type,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=2)][int]$actor_id,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=3)][string]$acted_on_type,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=4)][int]$acted_on_id,
        [Parameter(ValueFromPipelineByPropertyName,Position=5)][string]$data_text,
        [Parameter(ValueFromPipelineByPropertyName,Position=5)][hashtable]$data_text_vars,
        [Parameter(HelpMessage='If set, all actions are automatically confirmed without user input.')]$Confirm
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiEndpoint = "activity/create"
        $apiCalls=@()
    }
    process{
        # Create the array of API calls to make.
        $apiQuery = @{
            'activity_type_id'=$activity_type_id
            'actor_type'=$actor_type
            'actor_id'=$actor_id
            'actcted_on_type'=$acted_on_type
            'acted_on_id'=$acted_on_id
            'data_text'=$data_text
            #'data_text_vars'=$data_text_vars
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
            Write-Host "You are about to attempt to create the following activity items:"
            $apiCalls | ForEach-Object {Write-Host $($_.ApiQuery | out-string)}
            $confirmation = Read-Host "Confirm: [Y]es, [N]o (Default: No)"
        }
        # End Confirmation
        If($confirmation -eq 'Y'){
            $results = $apiCalls | Invoke-AnchorApiPost
            If($results){
                #$results.GeneratePwLastChangedPsLocal()
                #$results.PopulateCompanyName() #company_name = (Get-AnchorOrg -id $($results.company_id)).name
                $results
            }
        }
        Else {
            Write-Host 'Action canceled. No activity items created.'
        }
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

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

Function New-AnchorGroup {
<#
    .PARAMETER FromCsv
    Values in the members and member_groups fields must be surrounded by square brackets.
    Example: [1234]
    Example: [1234,1235,1236]

    .LINK
    http://developer.anchorworks.com/v2/#create-a-group
#>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName='import')][string]$FromCsv,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=0)][int]$company_id,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=1)][string]$name,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=2)][int[]]$members,
        [Parameter(ParameterSetName='commandLine',ValueFromPipelineByPropertyName,Position=3)][int[]]$member_group,
        [Parameter(HelpMessage='If set, all actions are automatically confirmed without user input.')]$Confirm
    )
    begin{
        Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
        Update-AnchorApiReadiness
        $apiEndpoint = "group/create"
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
                'name'=$name
                'company_id'=$company_id
            }
            If($members){$apiQuery+=@{'members'=("[$($members -join ',')]")}}
            If($member_groups){$apiQuery+=@{'member_groups'=("[$($member_groups -join ',')]")}}
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
            Write-Host "You are about to attempt to create the following groups:"
            $apiCalls | ForEach-Object {Write-Host $($_.ApiQuery | out-string)}
            $confirmation = Read-Host "Confirm: [Y]es, [N]o (Default: No)"
        }
        # End Confirmation
        If($confirmation -eq 'Y'){
            $results = $apiCalls | Invoke-AnchorApiPost
            If($results){
                #$results.GeneratePwLastChangedPsLocal()
                #$results.PopulateCompanyName() #company_name = (Get-AnchorOrg -id $($results.company_id)).name
                $results
            }
        }
        Else {
            Write-Host 'Action canceled. No groups created.'
        }
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

# Guest functions

# Organization functions

# Person functions

Function New-AnchorPerson {
<#
    .PARAMETER FromCsv
    Accepts the path of an existing .csv file that contains the field names and appropriate values

    Notes for csv formatting:
    True/False fields: empty or nonexistent = false. Field should contain only the string 'true' or 'false'. Excel will force this to 'TRUE' and 'FALSE' but the function will convert it to lowercase.
    Fields that accept multiple values: These should be formatted as comma-separated text, enclosed in double quotes (e.g. "12345,54321"). If only passing a single value, formatting in this way is not necessary.

    .PARAMETER Confirm
    Specifies that all actions are implicitly confirmed. i.e. Will not prompt for confirmation.

    .LINK
    http://developer.anchorworks.com/v2/#create-a-person
#>
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
            $arrayParams = @('group_ids','dept_shares') #These are the names of parameters that could possibly contain multiple values (arrays).
            $csvData = Import-Csv -Path $FromCsv
            #$csvFields = Get-Member -InputObject $csvData[0] | Where-Object MemberType -eq NoteProperty
            $csvData | ForEach-Object {
                $apiQuery = @{}
                foreach ($property in $_.PSObject.Properties){
                    If ($property.Name -in $arrayParams){ 
                        # This parameter needs to be formatted as an array so that it can later be passed twice.
                        $apiQuery[$($property.Name)] = $property.Value.Replace('"','').split(',')
                    }
                    Else{
                        $apiQuery[$($property.Name)] = $property.Value
                    }
                }
                # Two of the fields can accept multiple values. You have to pass the same field twice to the API server.
                # You can't have duplicate keys in a hashtable, so we have to convert the hashtable to a URL string.
                If(($apiQuery.group_ids -is [array]) -or ($apiQuery.dept_shares -is [array])) {
                    $apiQueryString=''
                    $first=$true
                    ForEach ($key in $apiQuery.keys){
                        ForEach ($value in $apiQuery[$key]) {
                            If($first){
                                $first=$false
                            }
                            Else{
                                $apiQueryString += '&'
                            }
                            If($value -eq 'TRUE'){$value='true'}
                            $apiQueryString += [System.Web.HttpUtility]::HtmlEncode($Key) + "=" + [System.Web.HttpUtility]::HtmlEncode($value);
                        }
                    }
                    $apiQuery = $apiQueryString
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

            # Two of the fields can accept multiple values. You have to pass the same field twice to the API server.
            # You can't have duplicate keys in a hashtable, so we have to convert the hashtable to a URL string.
            If(($group_ids -is [array]) -or ($dept_shares -is [array])) {
                $apiQueryString=''
                $first=$true
                ForEach ($key in $apiQuery.keys){
                    ForEach ($value in $apiQuery[$key]) {
                        If($first){
                            $first=$false
                        }
                        Else{
                            $apiQueryString += '&'
                        }
                        $apiQueryString += [System.Web.HttpUtility]::HtmlEncode($Key) + "=" + [System.Web.HttpUtility]::HtmlEncode($value);
                    }
                }
                $apiQuery = $apiQueryString
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
            $results = $apiCalls | Invoke-AnchorApiPost
            If($results){
                [AnchorPerson[]]$outObject = $results
                $outObject.GeneratePwLastChangedPsLocal()
                $outObject.PopulateCompanyName() #company_name = (Get-AnchorOrg -id $($results.company_id)).name
                Write-Host "$($outObject.Count) accounts created."
                $outObject
            }
        }
        Else {
            Write-Host 'Action canceled. No accounts created.'
        }
        Write-Verbose "$($MyInvocation.MyCommand) complete at $(Get-Date)"
    }
}

# Root functions
