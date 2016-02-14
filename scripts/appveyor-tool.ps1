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

Function InstallR {
  [CmdletBinding()]
  Param()

  $version = "stable"
  Progress ("Version: " + $version)

  If ($version -eq "master") {
    $url_path = ""
    $version = "devel"
  }
  ElseIf ($version -eq "stable") {
    $url_path = ""
    $version = $(ConvertFrom-JSON $(Invoke-WebRequest http://rversions.r-pkg.org/r-release).Content).version
  }
  ElseIf ($version -eq "patched") {
    $url_path = ""
    $version = $(ConvertFrom-JSON $(Invoke-WebRequest http://rversions.r-pkg.org/r-release).Content).version + "patched"
  }
  Else {
      $url_path = ("old/" + $version + "/")
  }

  Progress ("URL path: " + $url_path)

  $rurl = "https://cran.rstudio.com/bin/windows/base/" + $url_path + "R-" + $version + "-win.exe"

  Progress ("Downloading R from: " + $rurl)
  Exec { bash -c ("curl --silent -o ../R-win.exe -L " + $rurl) }

  dir .
  dir ..

  $blockRdp = $true; iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/appveyor/ci/master/scripts/enable-rdp.ps1'))

  Progress "Running R installer"
  Start-Process -FilePath ..\R-win.exe -ArgumentList "/VERYSILENT /DIR=C:\R" -NoNewWindow -Wait

  $RDrive = "C:"
  echo "R is now available on drive $RDrive"

  dir C:\
  dir C:\R

  Progress "Setting PATH"
  $env:PATH = $RDrive + '\R\bin\i386;' + 'C:\MinGW\msys\1.0\bin;' + $env:PATH

  Progress "Testing R installation"
  Rscript -e "sessionInfo()"
}

Function InstallRtools {
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
  if ( -not(Test-Path Env:\GCC_PATH) ) {
    $gcc_path = "gcc-4.6.3"
  }
  Else {
    $gcc_path = $env:GCC_PATH
  }
  $env:PATH = $RtoolsDrive + '\Rtools\bin;' + $RtoolsDrive + '\Rtools\MinGW\bin;' + $RtoolsDrive + '\Rtools\' + $gcc_path + '\bin;' + $env:PATH
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

  InstallR

  if ( Test-Path "/**/src" ) {
    InstallRtools
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
