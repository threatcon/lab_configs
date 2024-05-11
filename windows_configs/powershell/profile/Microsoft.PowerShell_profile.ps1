### Antonio Turner's PowerShell profile 
### Version 1.0
### All sources credited
### S1
### S2



# Imports
Import-Module -Name Terminal-Icons


# Set variables
$EDITOR = 'code'

$VISIOAPP = 'C:\Program Files\Microsoft Office\root\Office16\VISIO.EXE'

## Find out if the current user identity is elevated (has admin rights)
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
if ($isAdmin) {
    $Host.UI.RawUI.WindowTitle += " [ADMIN]"
}    


# Set commands
# New-PSDrive -Name  -PSProvider FileSystem -Root $WORKROOT1 -Description '' | Out-Null
# New-PSDrive -Name  -PSProvider FileSystem -Root $WORKROOT2 -Description '' | Out-Null

## Aliases

### Set UNIX-like aliases for the admin command, so sudo <command> will run the command
### with elevated rights. 
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin
Set-Alias -Name edit -Value $EDITOR

## PSReadline
### Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
### Autocompletion for arrow keys
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows


# Functions
function Start-DailyApps { 
    $teamsCheck = Get-Process -Name ms-teams -ErrorAction SilentlyContinue
    $adBrokerCheck = Get-Process -Name Microsoft.AAD.BrokerPlugin.exe -ErrorAction SilentlyContinue
    
    if ($teamsCheck) {
        stop-process -Name ms-teams
    }            
    
    if ($adBrokerCheck) {
        stop-process -Name Microsoft.AAD.BrokerPlugin.exe
    }            

    start-process ms-teams

    Remove-Variable teamsCheck
    Remove-Variable adBrokerCheck
}            
            

function draw {


    start-process $VISIOAPP $args
}            
           

# function Philips: { Set-Location  $WORKFOLDER: }
# function BV: { Set-Location  $WORKFOLDER2: }
function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }

# Compute file hashes - useful for checking successful downloads 
function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

# Quick shortcut to start notepad++
function n { start-process 'C:\Program Files\Notepad++\notepad++.exe' $args }

# Drive shortcuts
function HKLM: { Set-Location HKLM: }
function HKCU: { Set-Location HKCU: }
function Env: { Set-Location Env: }


# Set up command prompt and window title. Use UNIX-style convention for identifying 
# whether user is elevated (root) or not. Window title shows current version of PowerShell
# and appends [ADMIN] if appropriate for easy taskbar identification
function prompt { 
    if ($isAdmin) {
        "[" + (Get-Location) + "] # " 
    }            
    else {
        "[" + (Get-Location) + "] $ "
    }            
}            
# Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
function dirs {
    if ($args.Count -gt 0) {
        Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
    }        
    else {
        Get-ChildItem -Recurse | Foreach-Object FullName
    }        
}        

# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin {
    if ($args.Count -gt 0) {   
        $argList = "& '" + $args + "'"
        Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argList
    }        
    else {
        Start-Process "$psHome\powershell.exe" -Verb runAs
    }        
}        

# Make it easy to edit this profile once it's installed
function Edit-Profile {
    if ($host.Name -match "ise") {
        $psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
    }    
    else {
        notepad $profile.CurrentUserAllHosts
    }    
}    

# We don't need these any more; they were just temporary variables to get to $isAdmin. 
# Delete them to prevent cluttering up the user profile. 
Remove-Variable identity
Remove-Variable principal
   
function ll { Get-ChildItem -Path $pwd -File }
function g { Set-Location $HOME\Documents\Github }
function gcom {
    git add .
    git commit -m "$args"
}
function lazyg {
    git add .
    git commit -m "$args"
    git push
}
function Get-PubIP {
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}
function reload-profile {
    & $profile
}
function find-file($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place_path = $_.directory
        Write-Output "${place_path}\${_}"
    }
}
function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}
function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}
function touch($file) {
    "" | Out-File $file -Encoding ASCII
}
function df {
    get-volume
}
function sed($file, $find, $replace) {
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}
function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}
function export($name, $value) {
    set-item -force -path "env:$name" -value $value;
}
function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
function pgrep($name) {
    Get-Process $name
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# Invoke-Expression (& { (zoxide init powershell | Out-String) })

## Final Line to set prompt
oh-my-posh init pwsh --config '' | Invoke-Expression
