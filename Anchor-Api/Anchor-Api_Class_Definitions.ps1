# Classes

Class AnchorOauth{
    [string]$access_token
    [int]$expires_in
    [string]$token_type
    [string]$scope
    [guid]$guid
    [string]$refresh_token
    [datetime]$expires_on
    [datetime]$refresh_after
    [void]Update(){Update-AnchorApiSession}
}

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

Class AnchorPerson {
    [bool]$can_share
    [int]$company_id
    [string]$company_name
    [PSCustomObject]$company_policy
    [string]$display_name
    [string]$email
    [string]$first_name
    [PSCustomObject]$i18n
    [int]$id
    [string]$last_name
    [string]$locale
    [bool]$pw_force_reset
    [string]$pw_last_changed
    [datetime]$pw_last_changed_ps_local
    [Object[]]$roots
    [int]$root_id
    [bool]$site_admin
    [long]$space_quota
    [string]$space_quota_formatted
    [long]$space_usage
    [string]$space_usage_formatted
    [bool]$system_admin
    [string]$timezone
    [string]$type
    [string]$username
    [object]$tag
    Hidden [void]GeneratePwLastChangedPsLocal(){$this.pw_last_changed_ps_local = [string]$(Get-Date("$($this.pw_last_changed)`Z"))}
    [void]PopulateCompanyName(){$this.company_name = (Get-AnchorOrg -id ($this.company_id)).name}
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

Class AnchorOrgPolicy{
    [bool]$admin_browse_files
    [bool]$admin_browse_remote
    [bool]$admin_create_users
    [bool]$ad_enabled
    [string]$api_ratelimit
    [bool]$api_ratelimit_enabled
    [bool]$backups_enabled
    [bool]$backups_purge_deleted
    [int]$backups_purge_deleted_frequency
    [bool]$backups_trim_revisions
    [int]$backups_trim_revisions_frequency
    [bool]$branding_enabled
    [int]$change_password_frequency
    [int]$company_id
    [string]$create_orgs_until
    [int]$deactivate_token_frequency
    [string[]]$excluded_extensions
    [bool]$file_server_enabled
    [string[]]$locked_extensions
    [int]$max_file_size
    [int]$num_orgs_maximum
    [int]$num_users_maximum
    [int]$num_users_minimum
    [bool]$psa_enabled
    [bool]$purge_deleted
    [int]$purge_deleted_frequency
    [bool]$require_mobile_lock
    [bool]$require_two_step_auth
    [bool]$secure_shares
    [bool]$service_plans_enabled
    [long]$space_quota
    [string]$space_quota_formatted
    [int]$trial_length_days
    [bool]$trim_revisions
    [int]$trim_revisions_x
    [string]$type
    [bool]$user_create_backups
    [bool]$user_create_shares
    [bool]$user_lock_files
    [bool]$user_overwrite_collisions
    [bool]$user_purge_deleted
    [bool]$user_rollback
    [bool]$user_trim_revisions
    [bool]$webdav_enabled
    [bool]$web_editor_enabled
    [bool]$web_preview_enabled
    [bool]$web_wopi_enabled
}

Class AnchorOrg {
    [bool]$active
    [object]$bandwidth_throttle
    [string]$created
    [datetime]$created_ps_local
    [int]$default_encryption
    [string]$description
    [string]$email
    [int]$email_server_id
    [bool]$email_templates
    [string]$hostname
    [pscustomobject]$i18n
    [int]$id
    [string]$locale
    [string]$name
    [int]$parent_id
    [object]$plan_id
    [AnchorOrgPolicy]$policy
    [bool]$privacy_mode
    [string]$share_disclaimer
    [string]$slug
    [object]$subscription_uuid
    [bool]$throttled
    [object]$throttle_exception_days
    [object]$throttle_exception_dow
    [object]$throttle_exception_end
    [object]$throttle_exception_start
    [object]$throttle_exception_throttle
    [string]$timezone
    [string]$trial_until
    [datetime]$trial_until_ps_local
    [string]$type
    [object]$tag
}