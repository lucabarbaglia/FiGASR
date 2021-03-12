#' ECB Economic Bulletin.
#'
#' A dataset containing the \href{https://www.ecb.europa.eu/pub/economic-bulletin/html/index.en.html}{ECB Economic Bulletin} releases from 1999 to November 7th 2019.
#' The text was formatted from PDF and saved as a .RData file.
#'
#' @docType data
#'
#' @usage data(ecb_bulletin)
#'
#' @format A tibble with 231 rows and 7 variables:
#' \describe{
#'   \item{Urls}{Link to the original .pdf file from ECB archives.}
#'   \item{Date}{Release date.}
#'   \item{Text}{Full text of the ECB Economic Bulletin.}
#'   \item{n_pages}{Number of pages of the original file.}
#'   \item{author}{Author list.}
#'   \item{title}{Title of the original .pdf file.}
#' }
#'
#' @seealso \code{\link{senti_bignomics}} to access the economic dictionary,  \code{\link{get_sentiment}} to compute the sentiment.
#'
#'  @keywords datasets
#'
#'
"ecb_bulletin"


