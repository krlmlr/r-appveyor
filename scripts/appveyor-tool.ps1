Function Bootstrap {
  date
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
}
