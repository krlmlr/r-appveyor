# R + AppVeyor [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/krlmlr/r-appveyor?branch=master&svg=true)](https://ci.appveyor.com/project/krlmlr/r-appveyor/branch/master) [![Travis-CI Build Status](https://travis-ci.org/krlmlr/r-appveyor.svg?branch=master)](https://travis-ci.org/krlmlr/r-appveyor)

This is a solution for continuous integration for R projects on Windows, using [AppVeyor](http://appveyor.com) -- a CI testing service similar to [Travis-CI](http://travis-ci.org).
Under the hood, [r-travis](https://github.com/craigcitro/r-travis) is used to perform the testing; this works even on Windows thanks to [MinGW and MSYS](http://www.mingw.org/).


Usage
-----

1. Sign up to [AppVeyor](http://appveyor.com).
2. [Enable testing](https://ci.appveyor.com/projects/new) for your project.
3. Run `usethis::use_appveyor()` in your project.
4. (Optional) Adapt `appveyor.yml` to your needs according to the [documentation](http://www.appveyor.com/docs/appveyor-yml).
5. (Optional) Add a badge as described by the output of `usethis::use_appveyor()`.
6. Be sure to supply a `.gitattributes` file that takes care of fixing CRLF conversion settings that are relevant on Windows.  [The one in this repo](/.gitattributes) can be used for starters.
7. Push to your repo to start building.
8. Enjoy!


Build and test commands
-----------------------

The `travis-tool` used in `appveyor.yml` is a [modified copy](https://github.com/krlmlr/r-travis) of the r-travis project, documentation is available [on its wiki](https://github.com/craigcitro/r-travis/wiki#configuration-options).



Environment variables
---------------------

These can be set in the `appveyor.yml`, overriding the defaults. [This repo](https://github.com/krlmlr/r-appveyor/blob/master/appveyor.yml#L20) tests several configurations at once in a build matrix, see also the [build status](https://ci.appveyor.com/project/krlmlr/r-appveyor/branch/master).

Example:
```
environment:
  VARIABLE: value
```

- `R_VERSION`: The version of R to be used for testing. Specify `devel`, `patched`, `stable` (or `release`), `oldrel`, or a version number.
- `R_ARCH`: The architecture to be used for testing, one of `x64` (default) or `i386`.
- `RTOOLS_VERSION`: The version of Rtools to be used for testing, defaults to the most recent Rtools. Specify e.g. `33` for Rtools 3.3.
- `USE_RTOOLS`: Set `USE_RTOOLS: true` (or `USE_RTOOLS: yes`) if Rtools needs to be installed. Defaults to `true` if your package has a `src/` directory and `false` otherwise. Rtools may be needed if you use `install_github()`, if there are packages in `Remotes:` in your `DESCRIPTION` file, or if one of your dependencies has updated, but the associated Windows binary is not yet available from CRAN. (Set `PKGTYPE=binary` to avoid installing packages from source.)
- `GCC_PATH`: The path to GCC in the Rtools installation, currently one of `gcc-4.6.3` (default), `mingw_32` or `mingw_64`.
- `WARNINGS_ARE_ERRORS`: Set to 1 to treat all warnings as errors, otherwise leave empty.
- `CRAN`: The CRAN mirror to use, defaults to [RStudio's CDN via HTTPS](https://cloud.r-project.org). Change to [HTTP](http://cloud.r-project.org) for R 3.1.3 or earlier.
- `R_BUILD_ARGS`: Arguments passed to `R CMD build`, defaults to `--no-manual`.
- `R_CHECK_ARGS`: Arguments passed to `R CMD check`, defaults to `--no-manual --as-cran`.
- `PKGTYPE`: Passed as `type` to `install.packages()`, `remotes::install_github()` and `remotes::install_deps()`. Set to `both` to install packages from source if the source version is more recent than the binary version.
- `NOT_CRAN`: Set this to `true` if you are using [testthat](https://testthat.r-lib.org/) and want to run tests marked with `testthat::skip_on_cran()`.
- `R_REMOTES_STANDALONE`: Set this to `true` if builds are failing due to the inability to update infrastructure packages such as curl, git2r and rlang. Read more in the [docs for the remotes package](https://github.com/r-lib/remotes#standalone-mode).
- `_R_CHECK_FORCE_SUGGESTS_`: Set this to `false` to avoid errors of the form "Package suggested but not available".
- `KEEP_VIGNETTES`: Set this to a nonempty value build vignettes. You will likely need LaTeX and/or Pandoc, see below for installation instructions. By default, all vignettes are purged and the `VignetteBuilder` entry in `DESCRIPTION` is removed.
- `DOWNLOAD_FILE_METHOD`: On some versions of R, setting this to `wininet` appears to work better than the default `auto`.


Artifacts
---------

In contrast to Travis-CI, AppVeyor offers facilities for hosting artifacts.  This can be configured by adding a section to the `appveyor.yml`.  The sample file is configured to deploy logs, and source and **binary** versions of the built package.  Check the "ARTIFACTS" section for [your project at AppVeyor](https://ci.appveyor.com/projects).


LaTeX
-----

See [the example contributed by @pat-s](https://github.com/krlmlr/r-appveyor/issues/10#issuecomment-423832887) for a way to install LaTeX.
The [tinytex package](https://yihui.name/tinytex/) is another option.

Pandoc and other software
-------------------------

The [Chocolatey installer](https://chocolatey.org/) is a convenient way to install other software.
See below for a Pandoc example from the [reprex repository](https://github.com/tidyverse/reprex/blob/2d505dd8a5c26366896a33d3a3f6a2c9092786d5/appveyor.yml#L21-L24):

```yaml
before_test:
  - cinst pandoc
  - ps: $env:Path += ";C:\Program Files (x86)\Pandoc\"
  - pandoc -v
```


Troubleshooting
---------------

### Using a 64-bit R installation

Some R packages, notably `rJava`, require a 64-bit installation of
Windows and R.  If you try to install these packages on a 32-bit
system you'll see a message similar to:
```
  Error: .onLoad failed in loadNamespace() for 'rJava', details:
    call: inDL(x, as.logical(local), as.logical(now), ...)
    error: unable to load shared object 'C:/Users/appveyor/AppData/Local/Temp/1/RtmpWa3KNC/RLIBS_bdc2913935/rJava/libs/i386/rJava.dll':
    LoadLibrary failure:  %1 is not a valid Win32 application.
```
To solve this problem, add to your `appveyor.yml`:
```
platform: x64

environment:
  R_ARCH: x64
```
This will cause Appveyor to run your build on a 64-bit version of
Windows Server, using the 64-bit R binary.

Acknowledgements
----------------

This wouldn't have been as easy without [r-travis](https://github.com/craigcitro/r-travis) and the experience gained there. Thanks!


See also
--------

The [win-builder project](http://win-builder.r-project.org/) has been around much longer and provides more comprehensive testing; you still might want to use this service before submitting to CRAN.


Other branches
--------------

[![Build status for expected failure](https://ci.appveyor.com/api/projects/status/github/krlmlr/r-appveyor?branch=master-fail&svg=true)](https://ci.appveyor.com/project/krlmlr/r-appveyor/branch/master-fail) ([`master-fail` branch](https://github.com/krlmlr/r-appveyor/tree/master-fail), failure expected)


License
-------

MIT © [Kirill Müller](https://github.com/krlmlr).
