#' Check OS windows
#' @keywords internal
#' @noRd

is_windows <- function() {
  identical(.Platform$OS.type, "windows")
}

#' Check OS unix
#' @keywords internal
#' @noRd
is_unix <- function() {
  identical(.Platform$OS.type, "unix")
}

#' Check OS osx
#' @keywords internal
#' @noRd
is_osx <- function() {
  Sys.info()["sysname"] == "Darwin"
}

#' Check OS linux
#' @keywords internal
#' @noRd
is_linux <- function() {
  identical(tolower(Sys.info()[["sysname"]]), "linux")
}

#' Check OS ubuntu
#' @keywords internal
#' @noRd
is_ubuntu <- function() {
  if (is_unix() && file.exists("/etc/lsb-release")) {
    lsbrelease <- readLines("/etc/lsb-release")
    any(grepl("Ubuntu", lsbrelease))
  } else {
    FALSE
  }
}

#' Python modules
#' @keywords internal
#' @noRd
figas_pkgs <- function(version, packages = c('pandas', 'numpy', 'nltk')) {
  if (is.null(packages))
    packages <- sprintf("packages%s",
                        ifelse(version == "latest", "", paste0("=", version)))
  return(packages)
}


#' Automatically install miniconda
#' @keywords internal
#' @noRd
install_miniconda <- function() {
  if (is_osx()) {
    message("Downloading installation script")
    system(paste(
      "curl https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -o ~/miniconda.sh;",
      "echo \"Running installation script\";",
      "bash ~/miniconda.sh -b -p $HOME/miniconda"))
    system('echo \'export PATH="$PATH:$HOME/miniconda/bin"\' >> $HOME/.bash_profile; rm ~/miniconda.sh')
    message("Installation of miniconda complete")
  } else if (is_linux()) {
    message("Downloading installation script")
    system(paste(
      "wget -nv https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh;",
      "echo \"Running installation script\";",
      "bash ~/miniconda.sh -b -p $HOME/miniconda"))
    system('echo \'export PATH="$PATH:$HOME/miniconda/bin"\' >> $HOME/.bashrc; rm ~/miniconda.sh')
    message("Installation of miniconda complete")
  } else {
    stop("Automatic miniconda installation is available only for Mac or Linux")
  }
}


#' Install figas_condaenv
#' @importFrom reticulate conda_list conda_create py_install conda_install conda_remove
#' @importFrom utils menu
#' @importFrom spacyr spacy_download_langmodel
#' @keywords internal
#' @noRd
process_figas_installation_conda <- function(conda, version,
                                             spacy_version,
                                             python_version,
                                             prompt=prompt,
                                             envname=envname,
                                             pip=pip) {

  conda_envs <- reticulate::conda_list(conda = conda)

  if (prompt) {
    ans <- utils::menu(c("No", "Yes"), title = "This package will create a new conda environment 'figas_condaenv'.\n Are you sure you want to proceed?")
    if (ans == 1) stop("condaenv setup is cancelled by user", call. = FALSE)
  }
  conda_env <- subset(conda_envs, conda_envs$name == envname)
  if (nrow(conda_env) == 1) {
    python <- conda_env$python
  } else{
    reticulate::conda_remove(envname = envname)
    cat('Creating figas_condaenv environment for FiGAS installation...\n')
    python_packages <- ifelse(is.null(python_version), "python=3.7",
                              sprintf("python=%s", python_version))
    python <- reticulate::conda_create(envname, packages = python_packages, conda = conda)
  }

  cat("Installing FiGAS...\n")
  spacy_package <- ifelse(is.null(spacy_version), "spacy=2.2.3",sprintf("spacy=%s", spacy_version))
  packages <- c(figas_pkgs(version), spacy_package)
  reticulate::py_install(packages=packages,
                         envname=envname,
                         conda = conda,
                         method = "conda") ## Would you like to install Miniconda? [Y/n]:
  reticulate::conda_install(envname, packages=packages, pip=pip, conda=conda)
  spacyr::spacy_download_langmodel(model="en_core_web_lg", envname=envname, conda = conda)
}


#' Call python code
#' @importFrom reticulate conda_list use_condaenv py_run_string py_run_file import_from_path
#' @importFrom tibble as_tibble
#' @keywords internal
#' @noRd
figas_wrapper <- function(text=text, include=include, exclude=exclude, location=location, tense=tense, oss=oss, parallel=parallel){

  ## INPUT
  # text : a list of texts
  # include : list of terms to search (tokens-of-interest)
  # exlude : a list of terms to exclude form search
  # location : a list of locations
  # tense : a list of tense to consider take from 'past', 'present', 'future', 'NaN'
  # oss : logical, if TRUE compute the Overall Sentiment Score

  # checkpackage<-function(U){if((U %in% rownames(installed.packages()))==F){install.packages(U)}}
  # packagelist<-list("reticulate", "tibble", "spacyr")
  # lapply(packagelist,checkpackage)
  # suppressMessages(suppressWarnings(packages <- lapply(packagelist, FUN = function(x) {library(x, character.only = TRUE)})))

  # if (Sys.which("conda")==""){
  #   stop("It's the first time you run this package.\n Please run 'figas_install()' before running the 'get_sentiment()' function.\n")
  # }
  conda <- tryCatch(reticulate::conda_binary("auto"), error = function(e) NULL)
  if (is.null(conda)){
    stop("It's the first time you run this package.\n Please run 'figas_install()' before running the 'get_sentiment()' function.\n")
  }
  clist <- reticulate::conda_list(conda=conda)
  if (!(("figas_condaenv") %in% clist$name)){
    stop("It's the first time you run this package.\n Please run 'figas_install()' before running the 'get_sentiment()' function.\n")
  }
  reticulate::use_condaenv(condaenv = "figas_condaenv", required = T, conda = "auto")
  reticulate::py_run_string("import warnings")
  reticulate::py_run_string("warnings.simplefilter(action='ignore',category=FutureWarning)")
  # reticulate::py_run_file(file = system.file('python', 'senticnet5.py', package = 'FiGAS'), convert=TRUE)
  reticulate::py_run_file(file = system.file('python', 'senti_bignomics.py', package = 'FiGASR'), convert=TRUE)
  pc2 <- reticulate::import_from_path(module='package_creation2', path=system.file('python', package = 'FiGASR'), convert=TRUE)

  pcout <- pc2$WRAPPER(text=text, include=include, exclude=exclude, location=location, tense=tense, oss=oss)

  out <- pcout
  out$Text <- unlist(out$Text)
  out <- tibble::as_tibble(out)

  # ## Detailed output by chunk
  # out1 <- tibble::as_tibble(out)
  # out1$Text <- unlist(out$Text)
  # out1$SpannedText <- unlist(out$SpannedText)
  # out1$Tense <- unlist(out$Tense)
  # out1$Include <- unlist(out$Include)
  # # out1$Doc_id <- paste0("doc_", out1$Doc_id+1)
  #
  # ## Main output: average sentiment by Doc_ID
  # by2 <- out1$Text
  # out2 <- stats::aggregate(out1[, c("Sentiment") ], by=list(by2), FUN="mean")
  # # colnames(out2) <- c("Doc_id", "Text", "Average Sentiment")
  # colnames(out2) <- c("Text", "Average Sentiment")
  # # out2 <- out2[order(out2$Doc_id), ]
  # # out2 <- as_tibble(out2)

  # # print('The 1st element of the output list contains the Main Output, the 2nd element contains Details')
  # return(list("sentiment"=out2, "sentiment_by_chunk"=out1, "out"=out))

  return(out)

}


