﻿@{
    ModuleVersion = '0.1'
    GUID = 'd4c837c2-5f26-4f08-8dfd-e1a1eb1a9d91'
    RootModule = '.\Anchor-Api.psm1'
    NestedModules = @(
        '.\Anchor-ApiOauth.ps1',
        '.\Anchor-ApiReporting.ps1',
        '.\Anchor-ApiManagement.ps1',
        '.\Anchor-ApiNav.ps1'
    )
    FunctionsToExport = @(
        'Convert-UtcDateStringToLocalDateTime', #Remove after testing
        'Request-AnchorAuthorization',
        'Revoke-AnchorAuthorization',
        'Request-AnchorAuthorizationRefresh',
        'Find-RootFilesAndFolders',
        'Get-AnchorActivityTypes',
        'Get-AnchorApiVersion',
        'Get-AnchorFolderMetadata',
        'Get-AnchorFileMetadata',
        'Get-AnchorGroup',
        'Get-AnchorGroupMembers',
        'Get-AnchorGuest',
        'Get-AnchorGuestFileShares',
        'Get-AnchorMachine',
        'Get-AnchorMachineBackups',
        'Get-AnchorMachineStatus',
        'Get-AnchorOauthState',
        'Get-AnchorOauthToken',
        'Set-AnchorOauthToken',
        'Get-AnchorOrg',
        'Get-AnchorOrgActivity',
        'Get-AnchorOrgAuthSources',
        'Get-AnchorOrgChildren',
        'Get-AnchorOrgGroups',
        'Get-AnchorOrgGuests',
        'Get-AnchorOrgMachines',
        'Get-AnchorOrgRoots',
        'Get-AnchorOrgShare',
        'Get-AnchorOrgShares',
        'Get-AnchorOrgShareSubscribers',
        'Get-AnchorOrgUsers',
        'Get-AnchorOrgUsage',
        'Get-AnchorPerson',
        'Get-AnchorPersonActivity',
        'Get-AnchorRootFilesModifiedSince',
        'Get-AnchorRootLastModified',
        'Get-AnchorRootMetadata',
        'New-AnchorFileShare',
        'Save-AnchorFile',
        'Set-AnchorOauthUri',
        'Get-AnchorNavChildItem',
        'Get-AnchorNavPath',
        'Set-AnchorNavRoot',
        'Get-AnchorNavRoots',
        'Get-AnchorNavOrgs',
        'Set-AnchorNavOrg',
        'Set-AnchorNavFolder',
        'Save-AnchorNavFile'
    )
    CmdletsToExport = @()
    AliasesToExport = @(
        'UtcToLocal', # Remove after testing.
        'AnchorLogin',
        'AnchorLogon',
        'AnchorSignin',
        'AnchorRefresh',
        'AnchorLogout',
        'AnchorLogoff',
        'AnchorSignout',
        'AnchorGroup',
        'AnchorGuestShares',
        'AnchorMachine',
        'AnchorMachineStatus',
        'apwd',
        'acd',
        'aco',
        'acc',
        'acr',
        'als',
        'adir',
        'alo',
        'alc',
        'alr',
        'aget'
    )
}