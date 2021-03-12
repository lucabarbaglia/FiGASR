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
#' @references Barbaglia L., Consoli S., Manzan S. (2020). Monitoring the Business Cycle with Fine-Grained, Aspect-Based Sentiment Extraction from News. In: Bitetta V., Bordino I., Ferretti A., Gullo F., Pascolutti S., Ponti G. (eds) Mining Data for Financial Applications. MIDAS 2019. Lecture Notes in Computer Science, vol 11985. Springer.
#' \url{https://link.springer.com/chapter/10.1007/978-3-030-37720-5_8#citeas}
#'
"senti_bignomics"