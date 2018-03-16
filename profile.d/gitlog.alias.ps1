function GitLogAlias () {
	if (Test-Path -Path (Join-Path (Get-Item -Path ".\" -Verbose).FullName '.git') ) {
        git log --oneline --decorate
    }
    else {
        write-host "There's no Git repo here!"
    }
    
}

Set-Alias gitlog GitLogAlias