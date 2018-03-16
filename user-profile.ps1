# Use this file to run your own startup commands

. $PSScriptRoot\WriteRgb.ps1

#######################################
#         Prompt Customization
#######################################
<#
.SYNTAX
    <PrePrompt><CMDER DEFAULT>
    λ <PostPrompt> <repl input>
.EXAMPLE
    <PrePrompt>N:\Documents\src\cmder [master]
    λ <PostPrompt> |
#>

[ScriptBlock]$PrePrompt = {

}

function Import-GitModule($Loaded){
    if($Loaded) { return }
    $GitModule = Get-Module -Name Posh-Git -ListAvailable
    if($GitModule | Select-Object version | Where-Object version -le ([version]"0.7.1")){
        Import-Module Posh-Git > $null
    }
    if(-not ($GitModule) ) {
        Write-Warning "Missing git support, install posh-git with 'Install-Module posh-git' and restart cmder."
    }
    # Make sure we only run once by alawys returning true
    return $true
}



$isGitLoaded = $false
#Anonymice Powerline
$arrowSymbol = [char]0xE0B0
$branchSymbol = [char]0xE0A0

$branchAheadSymbol = [char]0x2191 # up arrow
$branchAheadColor = [RGB]::new(0, 255, 0)
$branchBehindSymbol = [char]0x2193 # down arrow
$branchBehindcolor = [RGB]::new(255, 0, 0)

$defaultForeColor = [RGB]::new(255, 255, 255)
$defaultBackColor = [RGB]::new(0,0,0)
$pathForeColor = [RGB]::new(0, 0, 0)#"White"
$pathBackColor = [RGB]::new(0, 0, 128)#"DarkBlue"
$gitCleanForeColor = [RGB]::new(255, 255, 255) #"White"
$gitCleanBackColor = [RGB]::new(0, 128, 0)#"DarkGreen"
$gitDirtyForeColor = [RGB]::new(0, 0, 0) #"Black"
$gitDirtyBackColor = [RGB]::new(255, 250, 205) #"Yellow"

function Write-GitPrompt() {
    $status = Get-GitStatus

    if ($status) {

        # assume git folder is clean
        $gitBackColor = $gitCleanBackColor
        $gitForeColor = $gitCleanForeColor
        if ($status.HasWorking -Or $status.HasIndex) {
            # but if it's dirty, change the back color
            $gitBackColor = $gitDirtyBackColor
            $gitForeColor = $gitDirtyForeColor
        }

        # Close path prompt
        Write-RGB $arrowSymbol -NoNewLine -BackgroundColor $gitBackColor -ForegroundColor $pathBackColor

        # Write branch symbol and name
        $branchString = [string]::Format(" {0} {1} ",$branchSymbol, $status.Branch)
        Write-RGB $branchString -NoNewLine -BackgroundColor $gitBackColor -ForegroundColor $gitForeColor

        if($status.AheadBy -gt 0) {
            $aheadByString = [string]::Format("{0} {1} ", $branchAheadSymbol, $status.AheadBy)
            Write-RGB $aheadByString -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $branchAheadColor
        }

        if($status.BehindBy -gt 0) {
            $behindByString = [string]::Format("{0} {1} ", $branchBehindSymbol, $status.BehindBy)
            Write-RGB $behindByString -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $branchBehindColor
        }

        <# Git status info
        HasWorking   : False
        Branch       : master
        AheadBy      : 0
        Working      : {}
        Upstream     : origin/master
        StashCount   : 0
        Index        : {}
        HasIndex     : False
        BehindBy     : 0
        HasUntracked : False
        GitDir       : D:\amr\SourceCode\DevDiary\.git
        #>

        # close git prompt
        Write-RGB $arrowSymbol -NoNewLine -BackgroundColor $defaultBackColor -ForegroundColor $gitBackColor
    }
}

function getGitStatus($Path) {
    if (Test-Path -Path (Join-Path $Path '.git') ) {
        $isGitLoaded = Import-GitModule $isGitLoaded
        Write-GitPrompt
        return
    }
    $SplitPath = split-path $path
    if ($SplitPath) {
        getGitStatus($SplitPath)
    }
    else{
      Write-RGB $arrowSymbol -NoNewLine -ForegroundColor $pathBackColor -BackgroundColor $defaultBackColor
    }
}

function tildaPath($Path) {
    return $Path.replace($env:USERPROFILE, "~")
}

# Replace the cmder prompt entirely with this.
[ScriptBlock]$CmderPrompt = {
    $tp = [string]::Format("`n{0} ", $(tildaPath($pwd.ProviderPath)))
    Write-RGB $tp -NoNewLine -BackgroundColor $pathBackColor -ForegroundColor $pathForeColor

    getGitStatus($pwd.ProviderPath)
}


[ScriptBlock]$PostPrompt = {
}

## <Continue to add your own>

