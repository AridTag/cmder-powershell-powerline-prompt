function Set-Extensions() {
    Param($extension)

    Get-ChildItem -Exclude ([string]::Format("*.{0}", $extension)) | Where-Object {!$_.PsIsContainer} | Rename-Item -NewName {$_.Name + $extension}
}

Set-Alias -Name addextension -Value Set-Extensions