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

    $ProgressMessage = (Date) + ': ' + $Message

    Add-AppveyorMessage $ProgressMessage -Category Information
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

  Progress "Setting time zone"
  tzutil /g
  tzutil /s "GMT Standard Time"
  tzutil /g
  date
  $env:PATH = 'c:\Rtools\bin;c:\Rtools\MinGW\bin;c:\Rtools\gcc-4.6.3\bin;c:\R\bin\i386;' + $env:PATH
  $env:PATH.Split(";")
  Invoke-WebRequest http://cran.rstudio.com/bin/windows/base/R-3.1.1-win.exe -OutFile "..\R-current-win.exe"
  date
  ..\R-current-win.exe /verysilent /dir=c:\R "/log=..\R.log" | Out-Null
  date
  Get-Content "..\R.log" -Tail 10
  date
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
