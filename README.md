# enviroCaR

Import and analysis functions for the R environment for statistical computing and graphics

## Installation

### Install dependencies

You need the ``trajectories`` package, which is not available on CRAN yet. Install it with

```
git clone https://github.com/edzer/trajectories
R CMD INSTALL trajectories
```

### Install enviroCaR

The enviroCaR package is not on CRAN yet, so please download and install the package manually. For this to work must have both git (http://git-scm.com/downloads) and R (see documentation [here](http://cran.r-project.org/bin/windows/base/rw-FAQ.html#Rcmd-is-not-found-in-my-PATH_0021) for Windows) on your path. Then run the following commands in the command line:

```
git clone https://github.com/enviroCar/enviroCaR
R CMD INSTALL enviroCaR
```


## Usage

Take a look at the demos to see how to use the package:

```
library(enviroCaR)
demo(package = "enviroCaR")
```

## Bug reporting

If you find a bug or run into problems, please open a new issue on GitHub: https://github.com/enviroCar/enviroCaR/issues

Before you submit the bug, consider these [guidelines](http://52north.org/resources/mailing-list-and-forums/mailinglist-guidelines).

## Development

### Contributing

Contributions to this package are always welcome. Take a look at the [issues](https://github.com/enviroCar/enviroCaR/issues) to see what tasks are pending and join the enviroCar [mailing list](http://list.52north.org/mailman/listinfo/envirocar-discuss)/[forum](http://envirocar-discuss.forum.52north.org/) to discuss new ideas.

We follow the [fork & pull development modell](https://help.github.com/articles/using-pull-requests), so please fork the project and send us your contributions as pull requests.

*No work should be done without an issue describing the task.*

### Documentation

We use roxygen comments in the R files. Take a look at the [roxygen2 documentation](http://cran.r-project.org/web/packages/roxygen2/vignettes/roxygen2.html) use it and read these [guidelines on documenting functions](http://adv-r.had.co.nz/Documenting-functions.html).

## About

See http://envirocar.org to learn more about the project.

## License

This R exention package is licensed under GPL version 2 or later.
