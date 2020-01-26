# Classes
Class ApiData{
    [int]$status_code
    [string]$tag
    [string]$hint
}

Class AnchorRoot {
    [int]$id
    [string]$name
    [string]$path
    [string]$revision_space_formatted
    [long]$revision_space_used
    [string]$root_type
    [long]$space_used
    [string]$space_used_formatted
    [string]$type
    [switch]$is_locked
    [array]$locks
    [array]$permissions
    [string]$hash
    [array]$children
    [int]$company_id
    [string]$company_name
    [hashtable]$company_data
    [switch]$api_exception=$false
    [ApiData]$ApiExceptionData = [ApiData]::new()
    [datetime]$queried_on
}

Class AnchorFseMap {
    [int]$id
    [int]$machine_id
    [string]$machine_name
    [string]$name
    [string]$path
    [Nullable[int]]$person_id
    [string]$person_display_name
    [Nullable[int]]$root_id
    [string]$root_name
    [AnchorRoot]$root_data = [AnchorRoot]::new()
    [switch]$share
    [string]$type
    [switch]$api_exception = $false
    [ApiData]$ApiExceptionData = [ApiData]::new()
    [datetime]$queried_on
}

Class AnchorBackup {
    [string]$type
    [int]$id
    [string]$root_name
    [AnchorRoot]$root_data
    [int]$machine_id
    [string]$machine_name
    [string]$path
    [switch]$api_exception = $false
    [ApiData]$ApiExceptionData = [ApiData]::new()
    [datetime]$queried_on
}

Class AnchorActivity {
    [int]$id
    [string]$type
    [string]$activity
    [string]$actor_type
    [string]$actor_text
    [Nullable[int]]$actor_company_id
    [string]$actor_company_name
    [Nullable[int]]$actor_machine_id
    [string]$actor_machine_name
    [Nullable[int]]$actor_person_id
    [Nullable[int]]$actor_guest_id
    [string]$actor_guest_email
    [string]$action_text
    [string]$acted_on_type
    [string]$acted_on_text
    [Nullable[int]]$acted_on_company_id
    [string]$acted_on_company_name
    [Nullable[int]]$acted_on_machine_id
    [string]$acted_on_machine_name
    [Nullable[int]]$acted_on_person_id
    [string]$acted_on_person_display_name
    [Nullable[int]]$acted_on_guest_id
    [string]$acted_on_guest_email
    [Nullable[int]]$acted_on_root_id
    [string]$acted_on_root_name
    [Nullable[int]]$acted_on_group_id
    [string]$acted_on_group_name
    [string]$data_text
    [object]$data_text_vars
    [int]$activity_type_id
    [string]$created
    [datetime]$created_ps_local
    [switch]$processed
    [switch]$api_exception = $false
    [ApiData]$ApiExceptionData = [ApiData]::new()
    [datetime]$queried_on
    [AnchorRoot]LookupActedOnRoot(){return Get-AnchorRootMetadata -id ($this.acted_on_root_id)}
    [Object]LookupActorPerson(){return Get-AnchorPerson -id ($this.actor_person_id)}
    [void]Expand(){
        $this.acted_on_company_name = (Get-AnchorOrg -id ($this.acted_on_company_id)).name
        $this.actor_company_name = (Get-AnchorOrg -id ($this.actor_company_id)).name
        $this.actor_machine_name = (Get-AnchorMachine -id ($this.actor_machine_id)).dns_name
    }

}

# Base API URI
[string]$Global:apiUri = "https://syncedtool.com/api/2"