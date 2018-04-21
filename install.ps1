param([String]$cmderPath)

if ([String]::IsNullOrWhiteSpace($cmderPath)) {
    Write-Host "Path to cmder was not specified"
    return
}

if (!(Test-Path -Path $cmderPath -PathType Container)) {
    Write-Host "cmder path not directory or does not exist"
    return
}

function Read-Choice(
    [Parameter(Mandatory)][string]$Message,
    [Parameter(Mandatory)][string[]]$Choices,
    [Parameter(Mandatory)][string]$DefaultChoice,
    [Parameter()][string]$Question = 'Are you sure you want to proceed?'
) {
    $defaultIndex = $Choices.IndexOf($DefaultChoice)
    if ($defaultIndex -lt 0) {
        throw "$DefaultChoice not found in choices"
    }

    $choiceObj = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]

    foreach ($c in $Choices) {
        $choiceObj.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList $c))
    }

    $decision = $Host.UI.PromptForChoice($Message, $Question, $choiceObj, $defaultIndex)
    return $Choices[$decision]
}

$cmderConfigPath = Join-Path -Path $cmderPath -ChildPath "config"

$profiledLinkSource = Join-Path -Path $PSScriptRoot -ChildPath "profile.d"
$profiledLinkTarget = Join-Path -Path $cmderConfigPath -ChildPath "profile.d"

$userProfileLinkSource = Join-Path -Path $PSScriptRoot -ChildPath "user-profile.ps1"
$userProfileLinkTarget = Join-Path -Path $cmderConfigPath -ChildPath "user-profile.ps1"

if (!(Test-Path -Path $cmderConfigPath -PathType Container)) {
    Write-Host "cmder config path not found"
    return
}

$profiledExists = $false
if (Test-Path -Path $profiledLinkTarget -PathType Container) {
    $profiledExists = $true
    $directoryInfo = Get-ChildItem $profiledLinkTarget | Measure-Object
    if ($directoryInfo.Count -gt 0) {
        $choice = Read-Choice -Message "$profiledLinkTarget is not empty. If you continue you will lose everything in there" -Choices "&Yes","&No" -DefaultChoice "&No"
        if (!($choice -eq "&Yes")) {
            Write-Host "Stopping script"
            return
        }
    }
}

$userProfileExists = $false
if (Test-Path -Path $userProfileLinkTarget) {
    $userProfileExists = $true
    $choide = Read-Choice -Message "$userProfileLinkTarget already exists. If you continue you will lose everything in there" -Choices "&Yes","&No" -DefaultChoice "&No"
    if(!($choide -eq "&Yes")) {
       Write-Host "Stopping script"
       return 
    }
}

if ($profiledExists) {
    (Get-Item $profiledLinkTarget).Delete()
}

if ($userProfileExists){
    (Get-Item $userProfileLinkTarget).Delete()
}

New-Item -Path $profiledLinkTarget -ItemType SymbolicLink -Value $profiledLinkSource
New-Item -Path $userProfileLinkTarget -ItemType SymbolicLink -Value $userProfileLinkSource