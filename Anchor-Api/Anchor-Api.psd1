@{
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
        'Get-AnchorAuthStatus',
        'Get-AnchorApiVersion',
        'Get-AnchorFolderMetadata',
        'Get-AnchorFileMetadata',
        'Get-AnchorPerson',
        'Get-AnchorOrg',
        'Get-AnchorOrgMachines',
        'Get-AnchorOrgChildren',
        'Get-AnchorOrgRoots',
        'Get-AnchorOrgShare',
        'Get-AnchorOrgShares',
        'Get-AnchorOrgShareSubscribers',
        'Get-AnchorRootMetadata',
        'Get-AnchorRootFilesModifiedSince',
        'Get-AnchorRootLastModified',
        'Get-AnchorMachineBackups',
        'Download-AnchorFile',
        'New-AnchorFileShare',
        'Find-RootFilesAndFolders'
    )
    CmdletsToExport = @()
    AliasesToExport = @()
}