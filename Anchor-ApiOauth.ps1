#region Credits and Documentation
# Bryan Sullo - bryan@clocktowertech.com
# Anchor API Documentation: http://developer.anchorworks.com/v2/
#endregion

$oauthUri = "https://clocktowertech.syncedtool.com/oauth/token"

Function Get-AnchorOauthToken{
<#
    .LINK
    http://developer.anchorworks.com/oauth2/#request-an-access-token
#>
param($Username, $Password)
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
        $Script:anchorOauthToken = $oauthToken | Select-Object *, @{N='expires_on';E={$oauthExpiry}}, @{N='refresh_after';E={$oauthRefresh}}

        Write-Host "Oauth token obtained. New token will expire on $($Script:anchorOauthToken.expires_on)`." -BackgroundColor Black -ForegroundColor Green
    }
    Else {
        Write-Host "Oauth token not obtained!" -BackgroundColor Black -ForegroundColor Red
    }
    #Return $newToken
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
    If(-not $OauthToken){$status = "No Token Provided"}
    If((Get-Date) -gt $OauthToken.refresh_after){$status = "Refresh Required"}
    If((Get-Date) -gt $OauthToken.expires_on){$status = "Token Expired"}
    Return $status
}


Function Validate-AnchorOauthToken {
    param(
        $OauthToken, 
        [switch]$ForceRefresh,
        [switch]$NoRefresh
    )
    #Write-Host $OauthToken.refresh_token
    $tokenStatus = Get-AnchorOauthStatus $OauthToken
    Switch ($tokenStatus){
        "No Token Provided" {
            Write-Host "Not authenticated." -ForegroundColor Red -BackgroundColor Black
            Get-AnchorOauthToken
        }
        "Refresh Required" {
            If(!$NoRefresh){
                Refresh-AnchorOauthToken $OauthToken
            }
        }
        "Token Expired" {
            Write-Host "Token Expired. Must Reauthenticate" -ForegroundColor Yellow -BackgroundColor Black
            Get-AnchorOauthToken            
        }
    }
    If ($ForceRefresh){Refresh-AnchorOauthToken $OauthToken}
    #Return $OauthToken
}
