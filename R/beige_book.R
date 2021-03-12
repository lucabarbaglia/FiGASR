#' FED Beige Book.
#'
#' A dataset containing the \href{https://www.federalreserve.gov/monetarypolicy/beige-book-default.htm}{FED Beige Book} releases from 1983 to September 4th 2019.
#' The text was formatted from PDF and saved as a .RData file.
#'
#' @docType data
#'
#' @usage data(beige_book)
#'
#' @format A tibble with 291 rows and 8 variables:
#' \describe{
#'   \item{Urls}{Link to the original .pdf file from FED archives.}
#'   \item{Date}{Release date.}
#'   \item{Text}{Full text of the Beige Book.}
#'   \item{n_pages}{Number of pages of the original .pdf file.}
#'   \item{author}{Author list.}
#'   \item{title}{Title of the original .pdf file.}
#'   \item{creation_date}{Date/time of creation of the original .pdf file.}
#'   \item{modification_date}{Date/time of last modification of the original .pdf file.}
#' }
#'
#' @seealso \code{\link{senti_bignomics}} to access the economic dictionary,  \code{\link{get_sentiment}} to compute the sentiment.
#'
#'  @keywords datasets
#'
#'
"beige_book"


