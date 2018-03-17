# Use this file to run your own startup commands

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
    if($GitModule | Select-Object version | Where-Object version -le ([version]"0.6.1.20160330")){
        Import-Module Posh-Git > $null
    }
    if(-not ($GitModule) ) {
        Write-Warning "Missing git support, install posh-git with 'Install-Module posh-git' and restart cmder."
    }
    # Make sure we only run once by alawys returning true
    return $true
}



$isGitLoaded = $false

#SauceCodePro Nerdfonts complete
$arrowSymbol = [char]0xE0B0;
$branchSymbol = [char]0xF418;
$aheadBySymbol = [char]0xF0AA; # Up arrow
$behindBySymbol = [char]0xF0AB; # Down arrow
$gitSymbol = [char]0xFBD9;

$defaultForeColor = "White"
$defaultBackColor = "Black"
$pathForeColor = "White"
$pathBackColor = "DarkBlue"
$gitCleanForeColor = "Black"
$gitCleanBackColor = "Green"
$gitDirtyForeColor = "Black"
$gitDirtyBackColor = "Yellow"

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
        Write-Host $arrowSymbol -NoNewLine -BackgroundColor $gitBackColor -ForegroundColor $pathBackColor

        # Write vcs symbol
        Write-Host ([string]::Format(" {0}", $gitSymbol)) -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $gitForeColor

        # Write branch symbol and name
        $branchString = [string]::Format(" {0} {1} ", $branchSymbol, $status.Branch)
        Write-Host $branchString -NoNewLine -BackgroundColor $gitBackColor -ForegroundColor $gitForeColor
		
		
		
		if($status.AheadBy -ge 1 -and $status.BehindBy -ge 1) {
			$aheadAndBehindString = [string]::Format("{0}{1} {2}{3}", $aheadBySymbol, $status.AheadBy, $behindBySymbol, $status.BehindBy)
			Write-Host $aheadAndBehindString -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $gitForeColor
        } elseif ($status.AheadBy -ge 1) {
            $aheadString = [string]::Format("{0}{1}", $aheadBySymbol, $status.AheadBy)
            Write-Host $aheadString -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $gitForeColor
        } elseif ($status.BehindBy -ge 1) {
            $behindString = [string]::Format("{0}{1}", $behindBySymbol, $status.BehindBy)
            Write-Host $behindString -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $gitForeColor
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
        $endPromptString = [string]::Format("{0}", $arrowSymbol)
        Write-Host $endPromptString -NoNewLine -BackgroundColor $defaultBackColor -ForegroundColor $gitBackColor
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
      Write-Host $arrowSymbol -NoNewLine -ForegroundColor $pathBackColor
    }
}

function tildaPath($Path) {
    return $Path.replace($env:USERPROFILE, "~")
}

# Replace the cmder prompt entirely with this.
[ScriptBlock]$CmderPrompt = {
    $tp = tildaPath($pwd.ProviderPath)
    $pathString = [string]::Format("`n{0} ", $tp)
    Microsoft.PowerShell.Utility\Write-Host $pathString -NoNewLine -BackgroundColor $pathBackColor -ForegroundColor $pathForeColor

    getGitStatus($pwd.ProviderPath)
}


[ScriptBlock]$PostPrompt = {
}

## <Continue to add your own>

