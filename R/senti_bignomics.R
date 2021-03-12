#' Sentiment of economic terms.
#'
#' A dataset containg the sentiment score for 7,295 economic terms.
#' The score is defined over [-1,1] and was obtained from combining
#' human annotions from 10 US-based annotators.
#'
#' @docType data
#'
#' @usage data(senti_bignomics)
#'
#' @format A tibble with 7,295 rows and 2 variables:
#' \describe{
#'   \item{term}{economic term}
#'   \item{sentiment}{sentiment score defined over [-1,1]}
#' }
#'
#' @seealso \code{\link{get_sentiment}} to compute the sentiment.
#'
#' @keywords datasets
#'
#' @references Consoli, Barbaglia, Manzan (January 14, 2021). Fine-Grained  Aspect-Based Sentiment Analysis on Economic and Financial Lexicon. Available at SSRN: https://ssrn.com/abstract=3766194
#' \url{https://ssrn.com/abstract=3766194}
#'
"senti_bignomics"
