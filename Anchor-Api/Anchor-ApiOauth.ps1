#region Credits and Documentation
# Bryan Sullo - bryan@clocktowertech.com
# Anchor API Documentation: http://developer.anchorworks.com/v2/
#endregion

$oauthUri = "https://syncedtool.com/oauth"

Function Set-AnchorOauthUri{
<#
    .SYNOPSIS
    Sets the URI for obtaining Anchor Oauth tokens for this session.
#>
    [Parameter(HelpMessage='URI for managing Anchor Oauth tokens')][string]$Uri
    Write-Host "Current URI:"
    Write-Host $oauthUri
    $newUri = Read-Host "New URI (default: no change)"
    If($newUri){$oauthUri=$newUri}
}

Function Connect-AnchorApiSession{
    [CmdletBinding()]
    [Alias('AnchorLogin')]
    [Alias('AnchorLogon')]
    [Alias('AnchorSignin')]
    param(
        [Parameter(ParameterSetName='up',Position=0)][string]$Username, 
        [Parameter(ParameterSetName='up',Position=1)][string]$Password,
        [Parameter(ParameterSetName='up',Position=3,HelpMessage='Time-based, one-time password')][string]$Totp,
        [Parameter(ValueFromPipeline)][PSCredential]$InputObject
    )
    If($InputObject){
        $Username = $InputObject.UserName
        # Extracting the password from a PSCredential object is a two-step process.
        $PasswordBstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($InputObject.Password)
        $Password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($PasswordBstr)
        # 🧹 Cleanup
        [Runtime.InteropServices.Marshal]::FreeBSTR($PasswordBstr)
    }
    [AnchorOauth]$Global:anchorOauthToken = New-AnchorOauthToken -Username $Username -Password $Password -Totp $Totp
}

Function Update-AnchorApiSession{
    [Alias('AnchorRefresh')]
    param()
    Refresh-AnchorOauthToken -CurrentToken $Global:anchorOauthToken
}

Function Disconnect-AnchorApiSession {
    [Alias('AnchorLogout')]
    [Alias('AnchorLogoff')]
    [Alias('AnchorSignout')]
    param()
    Revoke-AnchorOauthToken -oauthToken $Global:anchorOauthToken -tokenType access_token
    Revoke-AnchorOauthToken -oauthToken $Global:anchorOauthToken -tokenType refresh_token
    Remove-Variable -Name 'anchorOauthToken' -Scope 'Global'
}


Function Revoke-AnchorOauthToken{
    param(
        [Parameter(Mandatory,Position=0)][object]$oauthToken,
        [Parameter(Mandatory,Position=1)][ValidateSet('access_token','refresh_token')][string]$tokenType
    )
    $clientId = 'anchor'
    $payload = @{
        "client_id" = $clientId
        "token" = $oauthToken.$tokenType
        "token_type_hint" = $tokenType
    }
    $oauthToken = Invoke-RestMethod -Uri "$oauthUri`/revoke" -Body $payload -Method Post
}

Function Get-AnchorOauthToken{
    $Global:anchorOauthToken
}

Function Set-AnchorOauthToken{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline,Mandatory)][object]$InputObject
    )
    If($InputObject){
        Write-Host "Oauth token set. Token will expire on $($InputObject.expires_on)`." -BackgroundColor Black -ForegroundColor Green
        $Global:anchorOauthToken = $InputObject
        Update-AnchorApiReadiness
    }
    Else{
        Write-Host "No Oauth Token supplied." -BackgroundColor Black -ForegroundColor Yellow
    }
}

Function New-AnchorOauthToken{
<#
    .LINK
    http://developer.anchorworks.com/oauth2/#request-an-access-token
#>
param([string]$Username, [string]$Password, [String]$Totp)
    $grantType = "password"
    $clientId = "anchor"
    [AnchorOauth]$oauthToken = @{}
    Do {
        If (-not ($Username -and $Password)){
            $credentials = Get-Credential -Message "Anchor Credentials"
            $Username = $credentials.GetNetworkCredential().UserName
            $Password = $credentials.GetNetworkCredential().Password
        }
        #If (-not $Password){$Password = Read-Host -Prompt "Anchor password for $Username"}
        # At this point, we're assuming the account has 2-step auth.
        #   In the future, we should test for this and only prompt if it's necessary.
        If($Totp){
            $authCode = $Totp
        }
        Else{
            $authCode = Read-Host -Prompt "Time-based token for $Username"
        }
        $payload = @{
            "grant_type" = $grantType
            "client_id" = $clientId
            "username" = $Username
            "password" = $password
            "auth_code" = $authCode
            "dns_name" = $env:COMPUTERNAME
        }
        try {
            $oauthToken = Invoke-RestMethod -Uri "$oauthUri`/token" -Body $payload -Method Post
        } 
        catch {
            $failCount++
            $myError = ConvertFrom-Json $Error[0].ErrorDetails
            #Write-host $myError
            $myDescription = $myError.error_description
            #Write-host $myDescription
            Switch ($myDescription) {
                "Invalid credentials given." {Write-Host $myDescription -ForegroundColor Red; $Username = $null; $Password = $null;}
                "Account temporarily locked due to repeated failed login attempts." {Write-Host $myDescription -ForegroundColor Red; $failCount = 5}
                "Invalid authentication code." {Write-Host $myDescription -ForegroundColor Red}
                default {Write-Host $myDescription -ForegroundColor Red}
            }
        }
    } Until ($oauthToken -or $failCount -ge 4)
    If ($oauthToken){
        $refreshWindow = $oauthToken.expires_in
        [datetime]$oauthExpiry = (Get-Date).AddSeconds($refreshWindow)
        [datetime]$oauthRefresh = (Get-Date).AddSeconds($refreshWindow / 2)
        $oauthToken.expires_on=$oauthExpiry
        $oauthToken.refresh_after=$oauthRefresh
        $oauthToken #Return the token.
        #$oauthToken | Select-Object *, @{N='expires_on';E={$oauthExpiry}}, @{N='refresh_after';E={$oauthRefresh}}

        Write-Host "Oauth token obtained. New token will expire on $($oauthExpiry)`." -BackgroundColor Black -ForegroundColor Green
        Write-Host "Best practice: use Disconnect-AnchorApiSession (AnchorLogoff) when finished to revoke the Oauth token from the server." -ForegroundColor DarkYellow
        Write-Host "This is an open-source project, not associated with Axcient."
        Write-Host "Warning: The commands contained in this module can delete or modify configurations and data, and have not been tested in all scenarios." -ForegroundColor Red
        Write-Host "Use or misuse of this code could result in disruption, security violations, or data loss." -ForegroundColor Red
        Write-Host "Always test your workflows before deploying to live systems." -ForegroundColor Red -BackgroundColor Black
    }
    Else {
        Write-Host "Oauth token not obtained!" -BackgroundColor Black -ForegroundColor Red
    }
    #$Global:anchorOauthToken
}

Function Get-AnchorOAuthState{
    Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
    If($Global:anchorOauthToken.access_token){
        $expiryTimespan = New-TimeSpan -Start (Get-Date) -End $Global:anchorOauthToken.expires_on
        $refreshTimespan = New-TimeSpan -Start (Get-Date) -End $Global:anchorOauthToken.refresh_after
        $authState = If ($expiryTimespan -gt 0){'valid'}Else{'expired'}
        $refreshState = If ($refreshTimespan -gt 0){'not_suggested'}Else{ If($expiryTimespan -gt 0){'suggested'}Else{'expired'} }
        $state = [pscustomobject]@{}
        $state | Add-Member -MemberType NoteProperty -Name 'auth_token_state' -Value $authState
        $state | Add-Member -MemberType NoteProperty -Name 'token_expires' -Value $Global:anchorOauthToken.expires_on
        $state | Add-Member -MemberType NoteProperty -Name 'refresh_suggestion' -Value $refreshState
        $state | Add-Member -MemberType NoteProperty -Name 'refresh_suggested' -Value $Global:anchorOauthToken.refresh_after
    }
    Else{
        $state = [pscustomobject]@{}
        $state | Add-Member -MemberType NoteProperty -Name 'auth_token_state' -Value 'not_present'
        $state | Add-Member -MemberType NoteProperty -Name 'token_expires' -Value $null
        $state | Add-Member -MemberType NoteProperty -Name 'refresh_suggestion' -Value 'not_possible'
        $state | Add-Member -MemberType NoteProperty -Name 'refresh_suggested' -Value $null
    }
    $state
    Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
}

Function Refresh-AnchorOauthToken{
<#
    .LINK
    http://developer.anchorworks.com/oauth2/#refresh-an-access-token
#>

param($CurrentToken)
    $grantType = "refresh_token"
    $clientId = "anchor"
    $payload = @{
        "grant_type" = $grantType
        "client_id" = $clientId
        "refresh_token" = $($currentToken.refresh_token)
        "dns_name" = $env:COMPUTERNAME
    }
    #Write-Host $CurrentToken.refresh_token
    $oauthToken = Invoke-RestMethod -Uri "$oauthUri`/token" -Body $payload -Method Post
    $refreshWindow = $oauthToken.expires_in
    [datetime]$oauthExpiry = (Get-Date).AddSeconds($refreshWindow)
    [datetime]$oauthRefresh = (Get-Date).AddSeconds($refreshWindow / 2)
    $newToken = $oauthToken | Select-Object *, @{N='expires_on';E={$oauthExpiry}}, @{N='refresh_after';E={$oauthRefresh}}
    #Replace the values in the current token that was passed to the function.
    $CurrentToken.access_token = $newToken.access_token
    $currentToken.expires_in = $newToken.expires_in
    $CurrentToken.guid = $newToken.guid
    $CurrentToken.refresh_token = $newToken.refresh_token
    $CurrentToken.expires_on = $newToken.expires_on
    $CurrentToken.refresh_after = $newToken.refresh_after
    Write-Host "Oauth token refreshed. New token will expire on $($CurrentToken.expires_on)`." -BackgroundColor Black -ForegroundColor Green
}

# $OauthToken must be an object, not just the token ID
Function Get-AnchorOauthStatus {
param($OauthToken)
    $status = "Valid"
    If(-not $OauthToken){$status = "empty_token"}
    ElseIf((Get-Date) -gt $OauthToken.expires_on){$status = "token_expired"}
    ElseIf((Get-Date) -gt $OauthToken.refresh_after){$status = "refresh_required"}
    $status
}

Function Validate-AnchorOauthToken {
    param(
        [AllowNull()][object]$OauthToken, 
        [switch]$ForceRefresh,
        [switch]$NoRefresh
    )
#    If (!$OauthToken){
#        $OauthToken = $Global:anchorOauthToken
#    }
    $tokenStatus = Get-AnchorOauthStatus $OauthToken
    Switch ($tokenStatus){
        "empty_token" {
            Write-Host "Not authenticated." -ForegroundColor Red -BackgroundColor Black
            Connect-AnchorApiSession
            #$OauthToken = New-AnchorOauthToken
            #$OauthToken
        }
        "refresh_required" {
            If(!$NoRefresh){
                Refresh-AnchorOauthToken $OauthToken
            }
        }
        "token_expired" {
            Write-Host "Token Expired. Must Reauthenticate" -ForegroundColor Yellow -BackgroundColor Black
            Connect-AnchorApiSession
            #$OauthToken = New-AnchorOauthToken            
        }
    }
    If ($ForceRefresh){Refresh-AnchorOauthToken $OauthToken}
}

Function Update-AnchorApiReadiness{
    Write-Verbose "$($MyInvocation.MyCommand) started at $(Get-Date)"
    $oauthState = Get-AnchorOAuthState
    Switch ($oauthState.auth_token_state){
        'valid'{
            Switch ($oauthState.refresh_suggestion){
                'not_suggested' {} # Nothing to do here
                'suggested' {Update-AnchorApiSession}
            }
        }
        'expired'{
            Connect-AnchorApiSession
            # The Oauth State may have changed, so we need to update it before another function is called.
            $oauthState = Get-AnchorOAuthState
        }
        'not_present'{
            Connect-AnchorApiSession
            # The Oauth State may have changed, so we need to update it before another function is called.
            $oauthState = Get-AnchorOAuthState
        }
    }
    Write-Verbose "$($MyInvocation.MyCommand) completed at $(Get-Date)"
}