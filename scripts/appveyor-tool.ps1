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
  Invoke-WebRequest https://rportable.blob.core.windows.net/r-portable/master/R.iso -OutFile "..\R.iso"
  date

  # Enumerating drive letters takes about 10 seconds:
  # http://www.powershellmagazine.com/2013/03/07/pstip-finding-the-drive-letter-of-a-mounted-disk-image/
  # Hard-coding mounted drive letter here

  $ImageFullPath = Get-ChildItem "..\R.iso" | % { $_.FullName }
  $ImageFullPath
  date
  Mount-DiskImage -ImagePath $ImageFullPath
  $ISODriveLetter = "E"
  date

  Invoke-WebRequest http://raw.github.com/krlmlr/r-travis/master/scripts/travis-tool.sh -OutFile "..\travis-tool.sh"
  date
  echo '@bash.exe ../travis-tool.sh "%*"' | Out-File -Encoding ASCII .\travis-tool.sh.cmd
  cat .\travis-tool.sh.cmd
  bash -c "echo '^travis-tool\.sh\.cmd$' >> .Rbuildignore"
  cat .\.Rbuildignore
  date
  $env:PATH = $ISODriveLetter + ':\Rtools\bin;' + $ISODriveLetter + ':\Rtools\MinGW\bin;' + $ISODriveLetter + ':\Rtools\gcc-4.6.3\bin;' + $ISODriveLetter + ':\R\bin\i386;' + $env:PATH
  $env:PATH.Split(";")
  date
  $env:R_LIBS_USER = 'c:\RLibrary'
  mkdir $env:R_LIBS_USER
  date
}
