#' Compute Fine-Grained Aspect-based Sentiment analysis
#'
#' \code{get_sentiment} takes in a list of texts and compute the sentiment associated to a list of token of interest.
#' @importFrom stats aggregate
#' @importFrom tibble as_tibble
#' @param text A list of one or more texts.
#' @param include A list of tokens of interest about which you want to compute the sentiment.
#' @param exclude A list of tokens to exclude when calculating the sentiment.
#' @param location A list of locations by which you want to filter your texts.
#' @param tense A list of tenses to consider. Allowed values are: \code{"past"}, \code{"present"}, \code{"future"}, \code{"NaN"}. The default contains all these values.
#' @param oss Logical. If TRUE, computes the Overall Sentiment Score
#' @return sentiment A tibble "sentiment" containing the average sentiment computed for each text:
#'  \item{"Doc_id"}{A interger to identify the n^{th} item of the text input}
#'  \item{"Average_sentiment"}{The average sentiment score defined over [-1,1]}
#' @return sentiment_by_chunk A tibble "sentiment_by_chunk" containing the sentiment computed for each chunk detected in the texts.
#'  \item{"Doc_id"}{A interger to identify the n^{th} item of the text input}
#'  \item{"Text"}{Text given as input}
#'  \item{"Chunk"}{Chunk of sentence extracted from Text}
#'  \item{"Sentiment"}{Sentiment score defined over [-1,1]}
#'  \item{"Tense"}{Detected tense (possible values are \code{"past"}, \code{"present"}, \code{"future"}, \code{"NaN"})}
#'  \item{"Include"}{Word which the sentiment is referring to}
#' @references Barbaglia L., Consoli S., Manzan S. (2020). Monitoring the Business Cycle with Fine-Grained, Aspect-Based Sentiment Extraction from News. In: Bitetta V., Bordino I., Ferretti A., Gullo F., Pascolutti S., Ponti G. (eds) Mining Data for Financial Applications. MIDAS 2019. Lecture Notes in Computer Science, vol 11985. Springer.
#' \url{https://link.springer.com/chapter/10.1007/978-3-030-37720-5_8#citeas}
#' @seealso \code{\link{figas_install}}
#' @examples
#' ## Compute the economic sentiment from two texts about two tokens of interest, namely "unemployment" and "economy".
#' library(FiGAS)
#' text <- list("Unemployment is rising at high speed", "The economy is slowing down and unemployment is booming")
#' include = list("unemployment", "economy")
#' my_sent      <- get_sentiment(text = text, include = include)
#' my_sent
#'
#' ## Compute the sentiment about "economy", excluding "unemployment"
#' library(FiGAS)
#' my_sent      <- get_sentiment(text = list("The economy is slowing down and unemployment is booming"), include = list("economy"), exclude = list("unemployment"))
#' my_sent
#'
#' @export

get_sentiment <- function(text, include, exclude=NULL, location=NULL, tense=list('past', 'present', 'future', 'NaN'), oss=FALSE){


  if (!is.list(text)){stop("Define text as list.")}
  if (!is.list(include)){stop("Define include as list.")}
  if (!is.null(exclude) & !is.list(exclude)){stop("Define exclude as list.")}
  if (!is.null(location) & !is.list(location)){stop("Define location as list.")}
  if (!is.null(tense) & !is.list(tense)){stop("Define tense as list.")}

  out <- figas_wrapper(text=text, include=include, exclude=exclude, location=location, tense=tense, oss=oss, parallel=1)

  if (nrow(out) == 0){stop("No sentence was detected. Try to modify the include, exclude and location paramaters.")}

  ## Detailed output by chunk
  out$Doc_id <- out$Doc_id + 1
  out1 <- tibble::as_tibble(out)
  out1$Text <- sapply(out$Text, toString)
  out1$Chunk <- sapply(out$SpannedText, toString)
  out1$Tense <- sapply(out$Tense, toString)
  out1$Include <- sapply(out$Include, toString)
  out1 <- out1[, c("Doc_id", "Text", "Chunk", "Sentiment", "Tense", "Include")]

  ## Main output: average sentiment by Doc_ID
  by1 <- out1$Doc_id
  out2 <- stats::aggregate(out1[, c("Sentiment") ], by=list(by1), FUN="mean")
  colnames(out2) <- c("Doc_id", "Average_sentiment")
  out2 <- out2[order(out2$Doc_id), ]
  out2$Average_sentiment <- round(out2$Average_sentiment, 2)
  out2 <- tibble::as_tibble(out2)

  return(list("sentiment"=out2, "sentiment_by_chunk"=out1))

}

