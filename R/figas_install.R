#' Set-up environment to run Fine-Grained Aspect-based Sentiment analysis. This is a one-time operation, that should be run when you install the SentiBigNomicsR package, keeping all arguments to their default values.
#' @importFrom reticulate py_versions_windows conda_binary conda_install
#' @importFrom utils menu
#' @param conda The path to a `conda` executable (argument in `reticulate`). Use `"auto"` to
#'   automatically find an appropriate `conda` binary (default option).
#' @param version Version of the `pandas`, `numpy` and `nltk` modules. Use `"latest"` to download the latest available versions (default option).
#' @param spacy_version Version of the `spaCy` module to be installed. Default is "2.2.3".
#' @param python_version Python version to be used. Default is "3.7".
#' @param envname Name of the conda virtual environment. Default is "figas_condaenv".
#' @param pip Logical. If `FALSE` (default option), then do not use `pip` when downloading or installing packages (argument in `reticulate`).
#' @param python_path Path to the Python installion to be used. If `FALSE`, it automatically finds the Python installation (default option).
#' @param prompt Logical. Get prompt messages during the installation. Default to `FALSE`.
#'
#' @seealso \code{\link{get_sentiment}} to compute sentiment.
#' @examples
#' ## Compute the economic sentiment from two texts about two tokens of interest, namely "unemployment" and "economy".
#' library(SentiBigNomicsR)
#' figas_install()
#' text <- list("Unemployment is rising at high speed", "The economy is slowing down and unemployment is booming")
#' include = list("unemployment", "economy")
#' my_sent      <- get_sentiment(text = text, include = include)
#' my_sent

#' @export

figas_install <- function(conda = "auto",
                          version = "latest",
                          spacy_version = "2.2.3",
                          python_version = "3.7",
                          envname = "figas_condaenv",
                          pip = FALSE,
                          python_path = NULL,
                          prompt = FALSE) {


  ## PRELIMINIARY CHECKS
  if (!is_windows() && !is_osx() && !is_linux()) {
    stop("This function is available only for Windows, Mac, and Linux")
  }

  if (.Machine$sizeof.pointer != 8) {
    stop("Unable to install TensorFlow on this platform.",
         "Binary installation is only available for 64-bit platforms.")
  }

  if (!(identical(version, "latest") || identical(version, "latest_v1"))) {
    if (!(grepl("^[1-9]\\.\\d{1,2}\\.\\d{1,2}\\b", version))){
      stop("figas version specification error\n",
           "Please provide a full major.minor.patch specification",
           call. = FALSE)
    }
  }

  # ram <- as.numeric(benchmarkme::get_ram())
  # if (ram < 7e9){stop("Please install FiGAS on a machine with at least 8GB RAM.")}

  conda <- tryCatch(reticulate::conda_binary(conda), error = function(e) NULL)
  have_conda <- !is.null(conda)

  if (is_unix()) {
    if (!have_conda) {
      cat("No conda was found in the system. ")
      ans <- utils::menu(c("No", "Yes"), title = "FiGAS requires the installation of miniconda in ~/miniconda, do you agree?")
      if (ans == 2) {
        install_miniconda()
        reticulate::conda_install(packages = "numpy")
        conda <- tryCatch(reticulate::conda_binary("auto"), error = function(e) NULL)
      } else stop("Conda environment installation failed (no conda binary found)\n", call. = FALSE)
    }
    process_figas_installation_conda(conda, version, spacy_version,
                                     python_version, prompt,
                                     envname = envname, pip = pip)
  }
  ## Manual installation of conda on Windows as in SpacyR https://github.com/quanteda/spacyr/blob/master/R/spacy_install.R#L6
  if (is_windows()){
    python_versions <- reticulate::py_versions_windows()
    python_versions <- python_versions[python_versions$type == "PythonCore", ]
    python_versions <- python_versions[python_versions$version %in% c("3.6", "3.7"), ]
    python_versions <- python_versions[python_versions$arch == "x64", ]
    have_system <- nrow(python_versions) > 0
    if (have_system){python_system_version <- python_versions[1, ]}
    if (!have_conda) {
      stop("Conda installation failed (no conda binary found)\n\n",
           "Install Anaconda 3.x for Windows (https://www.anaconda.com/download/#windows)\n",
           "before installing figas",
           call. = FALSE)
    }

    process_figas_installation_conda(conda, version, spacy_version,
                                     python_version, prompt,
                                     envname = envname, pip = pip)
  }
  message("\nInstallation complete.\n"
  )
  invisible(NULL)
}

