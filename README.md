R+AppVeyor
==========

[![Build status](https://ci.appveyor.com/api/projects/status/github/krlmlr/r-appveyor?branch=master&svg=true)](https://ci.appveyor.com/project/krlmlr/r-appveyor/branch/master)

This is a solution for continuous integration for R projects on Windows, using [AppVeyor](http://appveyor.com) -- a CI testing service similar to [Travis-CI](http://travis-ci.org).
Under the hood, [r-travis](https://github.com/craigcitro/r-travis) is used to perform the testing; this works even on Windows thanks to [MinGW and MSYS](http://www.mingw.org/).


Usage
-----

1. Sign up to [AppVeyor](http://appveyor.com).
2. [Enable testing](https://ci.appveyor.com/projects/new) for your project.
3. Run `devtools::use_appveyor()` in your project.
4. (Optional) Adapt `appveyor.yml` to your needs according to the [documentation](http://www.appveyor.com/docs/appveyor-yml).
5. (Optional) Add a badge as described by the output of `devtools::use_appveyor()`.
6. Be sure to supply a `.gitattributes` file that takes care of fixing CRLF conversion settings that are relevant on Windows.  [The one in this repo](/.gitattributes) can be used for starters.
7. Push to your repo to start building.
8. Enjoy!


Environment variables
---------------------

These can be set in the `appveyor.yml`, overriding the defaults.

- `VERSION`: The version of R to be used for testing. Specify `devel`, `patched`, `release`, `oldrel`, or a version number.
- `GCC_PATH`: The path to GCC in the Rtools installation, currently one of `gcc-4.6.3`, `mingw_32` or `mingw_64`.
- `WARNINGS_ARE_ERRORS`: Set to 1 to treat all warnings as errors.
- `CRAN`: The CRAN mirror to use, defaults to RStudio's CDN via HTTPS. Change to HTTP for `oldrel` or earlier.
- `R_BUILD_ARGS`: Arguments passed to `R CMD build`, defaults to `--no-manual`.
- `R_CHECK_ARGS`: Arguments passed to `R CMD check`, defaults to `--no-manual --as-cran`.

Currently, all builds use the `--no-multiarch` switch for checking, and all vignettes (and the `VignetteBuilder` entry in `DESCRIPTION`) are removed prior to building (due to the absence of pandoc and LaTeX which are likely to be needed).


Artifacts
---------

In contrast to Travis-CI, AppVeyor offers facilities for hosting artifacts.  This can be configured by adding a section to the `appveyor.yml`.  The sample file is configured to deploy logs, and source and **binary** versions of the built package.  Check the "ARTIFACTS" section for [your project at AppVeyor](https://ci.appveyor.com/projects).


Acknowledgements
----------------

This wouldn't have been as easy without [r-travis](https://github.com/craigcitro/r-travis) and the experience gained there. Thanks!


Other branches
--------------

[![Build status for expected success](https://ci.appveyor.com/api/projects/status/github/krlmlr/r-appveyor?branch=master-mingw32&svg=true)](https://ci.appveyor.com/project/krlmlr/r-appveyor/branch/master-mingw32) ([`master-mingw32` branch](https://github.com/krlmlr/r-appveyor/tree/master-mingw32), success expected)

[![Build status for expected failure](https://ci.appveyor.com/api/projects/status/github/krlmlr/r-appveyor?branch=master-fail&svg=true)](https://ci.appveyor.com/project/krlmlr/r-appveyor/branch/master-fail) ([`master-fail` branch](https://github.com/krlmlr/r-appveyor/tree/master-fail), failure expected)
