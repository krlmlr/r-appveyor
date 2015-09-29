$CRAN = "http://cran.rstudio.com"
$RVersion = "R"


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

  Progress "Adding GnuWin32 tools to PATH"
  $env:PATH = "C:\Program Files (x86)\Git\bin;" + $env:PATH

  Progress "Setting time zone"
  tzutil /g
  tzutil /s "GMT Standard Time"
  tzutil /g

  Progress "Downloading R.vhd"
  bash -c 'curl -s -L https://rportable.blob.core.windows.net/r-portable/master/R.vhd.gz | gunzip -c > ../R.vhd'

  Progress "Getting full path for R.vhd"
  $ImageFullPath = Get-ChildItem "..\R.vhd" | % { $_.FullName }
  $ImageSize = (Get-Item $ImageFullPath).length
  echo "$ImageFullPath [$ImageSize bytes]"

  Progress "Mounting R.vhd"
  $RDrive = [string](Mount-DiskImage -ImagePath $ImageFullPath -Passthru | Get-DiskImage | Get-Disk | Get-Partition | Get-Volume).DriveLetter + ":"
  # Assert that R was mounted properly
  if ( -not (Test-Path "${RDrive}\${RVersion}\bin" -PathType Container) ) {
    Throw "Failed to mount R. Could not find directory: ${RDrive}\${RVersion}\bin"
  }
  echo "R is now available on drive $RDrive"

  Progress "Downloading and installing travis-tool.sh"
  Invoke-WebRequest http://raw.github.com/krlmlr/r-travis/master/scripts/travis-tool.sh -OutFile "..\travis-tool.sh"
  echo '@bash.exe ../travis-tool.sh %*' | Out-File -Encoding ASCII .\travis-tool.sh.cmd
  cat .\travis-tool.sh.cmd
  bash -c "echo '^travis-tool\.sh\.cmd$' >> .Rbuildignore"
  cat .\.Rbuildignore

  Progress "Setting PATH"
  $env:PATH = $RDrive + '\Rtools\bin;' + $RDrive + '\Rtools\MinGW\bin;' + $RDrive + '\Rtools\gcc-4.6.3\bin;' + $RDrive + '\' + $RVersion + '\bin\i386;' + $env:PATH
  $env:PATH.Split(";")

  Progress "Setting R_LIBS_USER"
  $env:R_LIBS_USER = 'c:\RLibrary'
  mkdir $env:R_LIBS_USER

  Progress "Bootstrap: Done"
}
