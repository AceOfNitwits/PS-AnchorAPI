﻿@{
    ModuleVersion = '0.1'
    GUID = 'd4c837c2-5f26-4f08-8dfd-e1a1eb1a9d91'
    RootModule = '.\Anchor-Api.psm1'
    NestedModules = @(
        '.\Anchor-ApiOauth.ps1',
        '.\Anchor-ApiReporting.ps1',
        '.\Anchor-ApiManagement.ps1'
    )
    FunctionsToExport = @(
        'Authenticate-AnchorAccount',
        'Find-RootFilesAndFolders',
        'Get-AnchorApiVersion',
        'Get-AnchorFolderMetadata',
        'Get-AnchorFileMetadata',
        'Get-AnchorMachineBackups',
        'Get-AnchorOauthState',
        'Get-AnchorOrg',
        'Get-AnchorOrgChildren',
        'Get-AnchorOrgMachines',
        'Get-AnchorOrgRoots',
        'Get-AnchorOrgShare',
        'Get-AnchorOrgShares',
        'Get-AnchorOrgShareSubscribers',
        'Get-AnchorOrgUsers',
        'Get-AnchorPerson',
        'Get-AnchorRootFilesModifiedSince',
        'Get-AnchorRootLastModified',
        'Get-AnchorRootMetadata',
        'New-AnchorFileShare',
        'Save-AnchorFile',
        'Set-AnchorOauthUri'
    )
    CmdletsToExport = @()
    AliasesToExport = @()
}