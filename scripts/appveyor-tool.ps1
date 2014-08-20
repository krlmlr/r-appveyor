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

Function Progress
{
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=0)]
        [string]$Message = ""
    )

    $ProgressMessage = '== ' + (Get-Date) + ': ' + $Message

    Write-Host $ProgressMessage -ForegroundColor Magenta
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

  Progress "Bootstrap: Start"

  Progress "Setting time zone"
  tzutil /g
  tzutil /s "GMT Standard Time"
  tzutil /g
  Progress "Downloading R.iso"
  bash -c 'curl -s -L https://rportable.blob.core.windows.net/r-portable/master/R.iso.gz | gunzip -c > ../R.iso'

  Progress "Getting full path for R.iso"
  $ImageFullPath = Get-ChildItem "..\R.iso" | % { $_.FullName }
  $ImageFullPath

  Progress "Mounting R.iso"
  Mount-DiskImage -ImagePath $ImageFullPath
  # Enumerating drive letters takes about 10 seconds:
  # http://www.powershellmagazine.com/2013/03/07/pstip-finding-the-drive-letter-of-a-mounted-disk-image/
  # Hard-coding mounted drive letter here
  $ISOPath = "E:"
  $RPath = $ISOPath

  Progress "Downloading and installing travis-tool.sh"
  Invoke-WebRequest http://raw.github.com/krlmlr/r-travis/master/scripts/travis-tool.sh -OutFile "..\travis-tool.sh"
  echo '@bash.exe ../travis-tool.sh %*' | Out-File -Encoding ASCII .\travis-tool.sh.cmd
  cat .\travis-tool.sh.cmd
  bash -c "echo '^travis-tool\.sh\.cmd$' >> .Rbuildignore"
  cat .\.Rbuildignore

  Progress "Setting PATH"
  $env:PATH = $ISOPath + '\Rtools\bin;' + $ISOPath + '\Rtools\MinGW\bin;' + $ISOPath + '\Rtools\gcc-4.6.3\bin;' + $RPath + '\R\bin\i386;' + $env:PATH
  $env:PATH.Split(";")

  Progress "Setting R_LIBS_USER"
  $env:R_LIBS_USER = 'c:\RLibrary'
  mkdir $env:R_LIBS_USER

  Progress "Bootstrap: Done"
}
