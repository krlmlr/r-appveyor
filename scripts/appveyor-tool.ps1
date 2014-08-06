Function Bootstrap {
  date
  $env:PATH = 'c:\Rtools\bin;c:\Rtools\MinGW\bin;c:\R\bin\i386;' + $env:PATH
  $env:PATH
  $env:TZ = 'GMT Standard Time'
  $env:TZ
  Invoke-WebRequest http://cran.rstudio.com/bin/windows/base/R-devel-win.exe -OutFile "..\R-current-win.exe"
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
}

Function Run_Tests {
  date
  $R_BUILD_ARGS = "--no-build-vignettes", "--no-manual"
  $R_CHECK_ARGS = "--no-build-vignettes", "--no-manual", "--as-cran"
  Invoke-Expression 'R.exe CMD build . $R_BUILD_ARGS 2>&1 | %{ "$_" }'
  date
  $File = $(ls "*.tar.gz" | Sort -Property LastWriteTime -Descending | Select-Object -First 1).Name
  Invoke-Expression 'R.exe CMD check $File $R_CHECK_ARGS 2>&1 | %{ "$_" }'
  date
}
