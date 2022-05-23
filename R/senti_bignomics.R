#' Sentiment of economic terms.
#'
#' A dataset containg the sentiment score for 3,181 economic terms.
#' The score is defined over [-1,1] and was obtained from combining
#' human annotions from 10 US-based annotators.
#'
#' @docType data
#'
#' @usage data(senti_bignomics)
#'
#' @format A tibble with 3,181 rows and 2 variables:
#' \describe{
#'   \item{term}{economic term}
#'   \item{sentiment}{sentiment score defined over [-1,1]}
#' }
#'
#' @seealso \code{\link{get_sentiment}} to compute the sentiment.
#'
#' @keywords datasets
#'
#' @references Consoli, Sergio, Luca Barbaglia, and Sebastiano Manzan. "Fine-grained, aspect-based sentiment analysis on economic and financial lexicon." Knowledge-Based Systems (2022): 108781. \url{https://doi.org/10.1016/j.knosys.2022.108781}
#'
"senti_bignomics"
