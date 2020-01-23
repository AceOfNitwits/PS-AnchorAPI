#region Credits and Documentation
# Bryan Sullo - bryan@clocktowertech.com
# Anchor API Documentation: http://developer.anchorworks.com/v2/
#endregion

$oauthUri = "https://syncedtool.com/oauth/token"

Function Set-AnchorOauthUri{
<#
    .SYNOPSIS
    Sets the URI for obtaining Anchor Oauth tokens for this session.
#>
    [Parameter(HelpMessage='URI for obtaining Anchor Oauth token')][string]$Uri
    Write-Host "Current URI:"
    Write-Host $oauthUri
    $newUri = Read-Host "New URI (default: no change)"
    If($newUri){$oauthUri=$newUri}
}

Function Register-AnchorAccount{
    param(
        [Parameter(Position=0)][string]$Username, 
        [Parameter(Position=1)][string]$Password
    )
    $Script:anchorOauthToken = New-AnchorOauthToken -Username $Username -Password $Password
}

Function Get-AnchorOauthToken{
    $Script:anchorOauthToken
}

Function Set-AnchorOauthToken{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline,Mandatory)][object]$InputObject
    )
    If($InputObject){
        Write-Host "Oauth token set. Token will expire on $($InputObject.expires_on)`." -BackgroundColor Black -ForegroundColor Green
        $Script:anchorOauthToken = $InputObject
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
param([string]$Username, [string]$Password)
    $grantType = "password"
    $clientId = "anchor"
    Do {
        If (-not ($Username -and $Password)){
            $credentials = Get-Credential -UserName $Username -Message "Anchor Credentials"
            $Username = $credentials.GetNetworkCredential().UserName
            $Password = $credentials.GetNetworkCredential().Password
        }
        #If (-not $Password){$Password = Read-Host -Prompt "Anchor password for $Username"}
        # At this point, we're assuming the account has 2-step auth.
        #   In the future, we should test for this and only prompt if it's necessary.
        $authCode = Read-Host -Prompt "Time-based token for $Username"
        $payload = @{
            "grant_type" = $grantType
            "client_id" = $clientId
            "username" = $Username
            "password" = $password
            "auth_code" = $authCode
            "dns_name" = $env:COMPUTERNAME
        }
        try {
            $oauthToken = Invoke-RestMethod -Uri $oauthUri -Body $payload -Method Post
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
        $oauthToken | Select-Object *, @{N='expires_on';E={$oauthExpiry}}, @{N='refresh_after';E={$oauthRefresh}}

        Write-Host "Oauth token obtained. New token will expire on $($oauthExpiry)`." -BackgroundColor Black -ForegroundColor Green
    }
    Else {
        Write-Host "Oauth token not obtained!" -BackgroundColor Black -ForegroundColor Red
    }
    #$Script:anchorOauthToken
}

Function Get-AnchorOAuthState{
    If($Script:anchorOauthToken){
        $expiryTimespan = New-TimeSpan -Start (Get-Date) -End $Script:anchorOauthToken.expires_on
        Switch ($expiryTimespan -gt 0)  {
            $True {[pscustomobject]@{'auth_status'='valid';'expires_on'=($Script:anchorOauthToken.expires_on)}}
            $False {[pscustomobject]@{'auth_status'='false';'expires_on'=($Script:anchorOauthToken.expires_on)}}
        }
    }
    Else{
        [pscustomobject]@{'auth_status'='not_authenticated';'expires_on'=$null}
    }
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
    $oauthToken = Invoke-RestMethod -Uri $oauthUri -Body $payload -Method Post
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
    #Write-Host $OauthToken.refresh_token
    $tokenStatus = Get-AnchorOauthStatus $OauthToken
    Switch ($tokenStatus){
        "empty_token" {
            Write-Host "Not authenticated." -ForegroundColor Red -BackgroundColor Black
            Register-AnchorAccount
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
            Register-AnchorAccount
            #$OauthToken = New-AnchorOauthToken            
        }
    }
    If ($ForceRefresh){Refresh-AnchorOauthToken $OauthToken}
}
