# Module Goals and Standards

1. Every API endpoint should be accessible by a named function (not just a generic function that handles multiple endpoints).
1. Functions should be named in "PowerShell style", with a PowerShell-approved verb, followed by a dash, followed by the word, "Anchor", then the name of the base object-type being acted upon, then the secondary object type or action. For example, `Get-AnchorOrgMachines`, not `Get-AnchorMachines`, because the function requires a company_id (org).
1. If multiple endpoints can be logically combined into a single function (downloading a file and downloading a folder are separate endpoints, but could, logically be part of the same function) they can be. 
1. Where logical, each function should accept pipeline input of multiple objects, and arrays of parameter values.
1. Each object type should have a defined Class.
1. All date properties in objects should include a _ps_local variant that is a PowerShell DateTime object with the correct local offset.
1. Where practical, all objects that contain id numbers for other objects should also include a property that lists the name of that object.
1. In general, additional functionality that can be easily accomplished by pipelining, and which does not reduce API calls, should not be incorporated into a module function. For example, returning only 'mobile' devices: This can be done by simply piping the output of Get-AnchorOrgMachines to `Select-Object machine_type -eq 'mobile'`. Implementing this in the function would not save API calls, and would only complicate the code.
1. All functions should accept PowerShell DateTime objects as date parameters.
1. All functions should accept arrays where comma-separated lists are required in the API.
1. As possible, every non-dependent API call should be run in its own runspace, simultaneous with other, non-dependent API calls. For example, if a Get- function is passed multiple objects, the API request for each object should be run in a separate runspace, and all should be called simultaniously. When dealing with paginated data (where more than 100 records are returned), the first API request must be completed, before subsequent calls can be made (because we don't know how many records there are until the first one is returned). Subsequent calls should be made in multi-threaded runspaces, since we know how many there will be, and they are not dependent on each other.
1. As few API requests as possible should be made to accomplish a task. If two property values are going to be used from the same API request, the request should be made once, and the necessary values saved, rather than making the call twice to obtain the values.
