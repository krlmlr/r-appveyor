$CRAN = "http://cran.rstudio.com"

# Set the path of gcc
## The "c:\Rtools\" + $gcc_path + "\bin" will be added to $PATH
if ( -not(Test-Path variable:GCC_PATH) )
    $gcc_path = "gcc-4.6.3"
}
Else {
    $gcc_path = $env:GCC_PATH
}

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
  if ( -not (Test-Path "${RDrive}\R\bin" -PathType Container) ) {
    Throw "Failed to mount R. Could not find directory: ${RDrive}\R\bin"
  }
  echo "R is now available on drive $RDrive"

  Progress "Setting PATH"
  $env:PATH = $RDrive + '\R\bin\i386;' + 'C:\MinGW\msys\1.0\bin;' + $env:PATH

  if ( Test-Path "src" ) {

  Progress "Downloading Rtools.vhd"
  bash -c 'curl -s -L https://rportable.blob.core.windows.net/r-portable/master/Rtools.vhd.gz | gunzip -c > ../Rtools.vhd'

  Progress "Getting full path for Rtools.vhd"
  $ImageFullPath = Get-ChildItem "..\Rtools.vhd" | % { $_.FullName }
  $ImageSize = (Get-Item $ImageFullPath).length
  echo "$ImageFullPath [$ImageSize bytes]"

  Progress "Mounting Rtools.vhd"
  $RtoolsDrive = [string](Mount-DiskImage -ImagePath $ImageFullPath -Passthru | Get-DiskImage | Get-Disk | Get-Partition | Get-Volume).DriveLetter + ":"
  # Assert that R was mounted properly
  if ( -not (Test-Path "${RtoolsDrive}\Rtools\bin" -PathType Container) ) {
    Throw "Failed to mount Rtools. Could not find directory: ${RtoolsDrive}\Rtools\bin"
  }
  echo "Rtools is now available on drive $RtoolsDrive"

  Progress "Setting PATH"
  $env:PATH = $RtoolsDrive + '\Rtools\bin;' + $RtoolsDrive + '\Rtools\MinGW\bin;' + $RtoolsDrive + '\Rtools\' + $gcc_path + '\bin;' + $env:PATH
  }
  Else {
    Progress "Skipping download of Rtools because src/ directory is missing."
  }

  Progress "Downloading and installing travis-tool.sh"
  Invoke-WebRequest http://raw.github.com/krlmlr/r-travis/master/scripts/travis-tool.sh -OutFile "..\travis-tool.sh"
  echo '@bash.exe ../travis-tool.sh %*' | Out-File -Encoding ASCII .\travis-tool.sh.cmd
  cat .\travis-tool.sh.cmd
  bash -c "echo '^travis-tool\.sh\.cmd$' >> .Rbuildignore"
  cat .\.Rbuildignore

  $env:PATH.Split(";")

  Progress "Setting R_LIBS_USER"
  $env:R_LIBS_USER = 'c:\RLibrary'
  mkdir $env:R_LIBS_USER

  Progress "Bootstrap: Done"
}
