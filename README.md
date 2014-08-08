R+AppVeyor [![Build status](https://ci.appveyor.com/api/projects/status/xtc629xek00o5rui/branch/master)](https://ci.appveyor.com/project/krlmlr/r-appveyor/branch/master)
==========

This is a solution for continuous integration for R projects on Windows, using [AppVeyor](http://appveyor.com) -- a CI testing service similar to [Travis-CI](http://travis-ci.org).
Under the hood, [r-travis](https://github.com/craigcitro/r-travis) is used to perform the testing; this works even on Windows thanks to [MinGW and MSYS](http://www.mingw.org/).


Usage
-----

1. Sign up to [AppVeyor](http://appveyor.com).
2. [Enable testing](https://ci.appveyor.com/projects/new) for your project.
3. Save a copy of [`sample.appveyor.yml`](/sample.appveyor.yml) as `appveyor.yml` to the root of your project.
4. Add the following line to `.Rbuildignore` of your project:

    ```
    ^appveyor\.yml$
    ```
5. Push to your repo to start building.
6. (Optional) Add a badge as described in the "Badges" section of your project's](https://ci.appveyor.com/projects)  "SETTINGS" to your `README.md`.
7. Enjoy!


Coming soon
-----------

Deployment of Windows binary packages.
It is not at all clear where to deploy them best.
Should it be one CRAN-like repository, or GitHub, or...?


Acknowledgements
----------------

This wouldn't have been as easy without [r-travis](https://github.com/craigcitro/r-travis) and the experience gained there. Thanks!
