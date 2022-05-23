#' sentiment.
#'
#' A data set containing the daily scaled sentiment indicators from Barbaglia et al. (2021, 2022) for the DE, ES, FR, IT, UK and US.
#' The sentiment is computed using the Fine-Grained Aspect-based sentiment for all verbal tenses.
#'
#' @docType data
#'
#' @usage data(sentiment)
#'
#' @format A tibble with date, country and the sentiment indicators for the following topics:
#' \describe{
#'   \item{Economy}
#'   \item{Financial Sector}
#'   \item{Inflation}
#'   \item{Manufacturing}
#'   \item{Monetary Policy}
#'   \item{Unemployment}
#' }
#'
#' @references Luca Barbaglia, Sergio Consoli & Sebastiano Manzan (2022) Forecasting with Economic News, Journal of Business & Economic Statistics, \url{https://doi.org/10.1080/07350015.2022.2060988}
#' @references Luca Barbaglia, Sergio Consoli & Sebastiano Manzan (2021) Forecasting GDP in Europe with Textual Data. Available at SSRN: \url{https://ssrn.com/abstract=3898680}
#'
#' @seealso \code{\link{senti_bignomics}} to access the economic dictionary,  \code{\link{get_sentiment}} to compute the sentiment.
#'
#' @keywords datasets
#'
#'
"sentiment"


