$currentOauthToken = Get-AnchorOauthToken
$currentOauthToken | Export-Clixml C:\test\token.xml
Import-Module Anchor-Api -Force
$currentOauthToken | Set-AnchorOauthToken
