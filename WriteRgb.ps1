#Taken from https://github.com/gravejester/Communary.ConsoleExtensions/tree/4aad40bf35d9749bcb9b8c47dd34ca88db3eecca
#Under the MIT License

#MIT License
#
#Copyright (c) 2016 Øyvind Kallstad
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

class RGB {
    [ValidateRange(0,255)]
    [int] $Red;
    [ValidateRange(0,255)]
    [int] $Green;
    [ValidateRange(0,255)]
    [int] $Blue;
    
    RGB() {}
    
    RGB($r,$g,$b) {
        $this.Red = $r;
        $this.Green = $g;
        $this.Blue = $b;
    }
    
    [string] ToString() {
        return "$($this.Red),$($this.Green),$($this.Blue)";
    }
}

function Write-RGB {
    <#
        .SYNOPSIS
            Write to the console in 24-bit colors!
        .DESCRIPTION
            This function lets you write to the console using 24-bit color depth.
            You can specify colors using its RGB values.
        .EXAMPLE
            Write-RGB 'PowerShell rocks!'
            Will write the text using the default colors.
        .EXAMPLE
            Write-RGB 'PowerShell rocks!' -ForegroundColor ([rgb]::new(255,192,203))
            Will write the text in a pink foreground color.
        .EXAMPLE
            Write-RGB 'PowerShell rocks!' -ForegroundColor ([rgb]::new(255,192,203)) -BackgroundColor ([rgb]::new(128,128,0))
            Will write the text in a pink foreground color and an olive background color.
        .NOTES
            Author: Øyvind Kallstad
            Version: 1.0
            Date: 23.09.2016
        .LINK
            https://communary.net/ 
    #>
    [CmdletBinding()]
    param (
        # The text you want to write.
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Text,
        
        # The foreground color of the text. Defaults to white.
        [Parameter(Position = 1)]
        [rgb] $ForegroundColor = [rgb]::new(255,255,255),
        
        # The background color of the text. Defaults to PowerShell Blue.
        [Parameter(Position = 2)]
        [rgb] $BackgroundColor = [rgb]::new(1,36,86),
        
        # No newline after the text.
        [Parameter()]
        [switch] $NoNewLine
    )
    
    if ($PSVersionTable.PSVersion.Build -ge 14931 -Or $PSVersionTable.PSEdition -eq "Core") {

        $escape = [char]27 + '['
        $resetAttributes = "$($escape)0m"
        
        $foreground = "$($escape)38;2;$($ForegroundColor.Red);$($ForegroundColor.Green);$($ForegroundColor.Blue)m"
        $background = "$($escape)48;2;$($BackgroundColor.Red);$($BackgroundColor.Green);$($BackgroundColor.Blue)m"
        
        Write-Host ($foreground + $background + $Text + $resetAttributes) -NoNewline:$NoNewLine
    }

    else {
        Write-Warning "This function will only work with build 14931 or above. Your build version is $($PSVersionTable.PSVersion.Build)"
    }
}