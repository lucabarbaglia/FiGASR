#' US sentiment.
#'
#' A data set containing the daily sentiment indicators from Barbaglia et al. (2021) for the US.
#' The sentiment is computed using the Fine-Grained Aspect-based sentiment for all verbal tenses.
#'
#' @docType data
#'
#' @usage data(US_sentiment)
#'
#' @format A tibble with date and the sentiment indicator for the following topics:
#' \describe{
#'   \item{Economy}
#'   \item{Financial Sector}
#'   \item{Inflation}
#'   \item{Manufacturing}
#'   \item{Monetary Policy}
#'   \item{Unemployment}
#' }
#'
#' @references Barbaglia, Luca and Consoli, Sergio and Manzan, Sebastiano, Forecasting with Economic News (May 26, 2021). Available at SSRN: https://ssrn.com/abstract=3698121 or http://dx.doi.org/10.2139/ssrn.3698121
#'
#' @seealso \code{\link{senti_bignomics}} to access the economic dictionary,  \code{\link{get_sentiment}} to compute the sentiment.
#'
#'  @keywords datasets
#'
#'
"US_sentiment"


