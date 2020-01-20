# PS-AnchorAPI
PowerShell scripts for managing Axcient Anchor via the v2 API

Functions are PS-friendly, returning objects and accepting pipeline input.

# Files

## Anchor-ApiOauth.ps1 

Includes functions for obtaining and refreshing the OAuth token you'll need to use any of the other functions.

## Anchor-ApiReporting.ps1

Includes functions that obtain information from the API. No destructive potential. 🐇

## Anchor-ApiManagement.ps1 👻

Not yet available. This will include functions for modifying data. High potential to be distructive if used incorrectly. 💣

## Anchor-BackupCheck.ps1 

Contains some examples of how to use the existing functions. To use, put all files in the same folder, and make sure you are in that folder when you run this script.

# To-do 

⬜ Create management functions

⬜ Finish populating reporting functions

⬜ More examples. 

✔ Use jobs to make functions with data-intensive calls complete faster

✔ Investigate creating some sort of "session" to manage Oauth info, rather than passing the value to each function.

⬜ Convert to a module

⬜ Improve authentication logic to only prompt for TOTP when it's actually needed. 
