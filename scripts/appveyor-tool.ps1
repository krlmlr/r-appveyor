$CRAN = "http://cran.rstudio.com"

# Found at http://zduck.com/2012/powershell-batch-files-exit-codes/
Function Exec
{
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=1)]
        [scriptblock]$Command,
        [Parameter(Position=1, Mandatory=0)]
        [string]$ErrorMessage = "Execution of command failed.`n$Command"
    )
    $ErrorActionPreference = "Continue"
    & $Command 2>&1 | %{ "$_" }
    if ($LastExitCode -ne 0) {
        throw "Exec: $ErrorMessage`nExit code: $LastExitCode"
    }
}

Function TravisTool
{
  [CmdletBinding()]
  param (
      [Parameter(Position=0, Mandatory=1)]
      [string[]]$Params
  )

  Exec { bash.exe ../travis-tool.sh $Params }
}

Function Bootstrap {
  [CmdletBinding()]
  Param()

  date
  tzutil /g
  tzutil /s "GMT Standard Time"
  tzutil /g
  date
  Invoke-WebRequest https://rportable.blob.core.windows.net/r-portable/1.0.5/Output/R.iso -OutFile "..\R.iso"
  date

  # http://www.powershellmagazine.com/2013/03/07/pstip-finding-the-drive-letter-of-a-mounted-disk-image/
  $DriveLettersBefore = (Get-Volume).DriveLetter
  Mount-DiskImage -ImagePath "..\R.iso"
  $DriveLettersAfter = (Get-Volume).DriveLetter
  $ISODriveLetter = compare $DriveLettersBefore $DriveLettersAfter -Passthru
  $ISODriveLetter
  date

  $env:PATH = 'c:\Rtools\bin;c:\Rtools\MinGW\bin;c:\Rtools\gcc-4.6.3\bin;' + $ISODriveLetter + ':\R\bin\i386;' + $env:PATH
  $env:PATH.Split(";")
  $rtoolsver = $(Invoke-WebRequest http://cran.rstudio.com/bin/windows/Rtools/VERSION.txt).Content.Split(' ')[2].Split('.')[0..1] -Join ''
  $rtoolsurl = "http://cran.rstudio.com/bin/windows/Rtools/Rtools$rtoolsver.exe"
  Invoke-WebRequest $rtoolsurl -OutFile "..\Rtools-current.exe"
  date
  ..\Rtools-current.exe /verysilent "/log=..\Rtools.log" | Out-Null
  Get-Content "..\Rtools.log" -Tail 10
  date
  Invoke-WebRequest http://raw.github.com/krlmlr/r-travis/master/scripts/travis-tool.sh -OutFile "..\travis-tool.sh"
  date
  echo '@bash.exe ../travis-tool.sh "%*"' | Out-File -Encoding ASCII .\travis-tool.sh.cmd
  cat .\travis-tool.sh.cmd
  bash -c "echo '^travis-tool\.sh\.cmd$' >> .Rbuildignore"
  cat .\.Rbuildignore
  date
}
