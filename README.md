
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Fine-Grained Aspect-based Sentiment

The `FiGAS` package allows R users to leverage on cutting-hedge NLP
techniques to easily run sentiment analysis on economic news content.
Given a list of texts as input and a list of tokens of interest (ToI),
`FiGAS` analyses the texts and compute the economic sentiment associated
each ToI. Two key features characterize this approach. First, it is
*fine-grained*, since words are assigned a polarity score that ranges in
\[-1,1\] based on a dictionary. Second, it is *aspect-based*, since the
algorithm selects the chunk of text that relates to the ToI based on a
set of semantic rules and calculates the sentiment only on that text,
rather than the full article.

The package includes some additional of features, like automatic
negation handling, tense detection, location filtering and excluding
some words from the sentiment computation. `FiGAS` only supports English
language, as it relies on the *en\_core\_web\_lg* language model from
the `spaCy` Python module.

## Installation

You can install `FiGAS` from GitHub as follows:

``` r
install.packages("devtools")
devtools::install_github("ec-jrc/FiGAS", auth_token = "f95d99e30957ff8e75e484b15d362bf2208cf206")
```

If it is the first time that you are using `FiGAS`, then set up the
associated environment:

``` r
FiGAS::figas_install()
```

## A start-up example

Let’s assume that you want to compute the sentiment associated to two
tokens of interest, namely *unemployment* and *economy*, given the two
following sentences.

``` r
library(FiGAS)
text <- list("Unemployment is rising at high speed",
             "The economy is slowing down and unemployment is booming")
include = list("unemployment", "economy")

get_sentiment(text = text, include = include)
#> $sentiment
#> # A tibble: 2 x 2
#>   Doc_id Average_sentiment
#>    <dbl>             <dbl>
#> 1      1             -0.9 
#> 2      2             -0.55
#> 
#> $sentiment_by_chunk
#> # A tibble: 3 x 6
#>   Doc_id Text                       Chunk              Sentiment Tense Include  
#>    <dbl> <chr>                      <chr>                  <dbl> <chr> <chr>    
#> 1      1 Unemployment is rising at… Unemployment is r…    -0.899 pres… unemploy…
#> 2      2 The economy is slowing do… economy is slowing    -0.3   pres… economy  
#> 3      2 The economy is slowing do… unemployment is b…    -0.8   pres… unemploy…
```

The output of the function `get_sentiment` is a list, containing two
objects:

  - a tibble “sentiment” containing the average sentiment computed for
    each text;

  - a tibble “sentiment\_by\_chunk” containing the sentiment computed
    for each chunk detected in the texts.

The first element of the output list provides the overall average
sentiment score of each text, while the second provides the detailed
score of each chunk of text that relates to one of the ToI.

## ECB Economic Bulletin

Among the available data sets, the package provides access to
`senti_bignomics`, a fine-grained dictionary customized for economic
sentiment analysis, and to `ecb_bulletin`, the [ECB Economic
Bulletin](https://www.ecb.europa.eu/pub/economic-bulletin/html/index.en.html)\[1\]
released between 1999 and 2019. Let’s provide an example of some
additional features of the package: assume that we want to extract the
sentiment about “economic activity” on the ECB Economic Bulletin
releases in 2007-13 and excluding all sentences that relates to the
“stock market”. The figure below plots the economic sentiment computed
by `FiGAS`, which timely identifies the recessionary period indicated by
the shadowed area following the [EABCN business cycles reference
dates](https://eabcn.org/dc/chronology-euro-area-business-cycles).

``` r
data("ecb_bulletin")
ecb_sub <- ecb_bulletin[ecb_bulletin$Date >= as.Date("2007-01-01") & ecb_bulletin$Date <= as.Date("2013-01-01"), ]
text <- as.list(as.data.frame(ecb_sub)[, "Text"])

## Compute sentiment about "economic activity"
ecb_sent      <- get_sentiment(text = text, 
                              include = list("economic activity"),
                              exclude = list("stock market"))

## Add dates for original Doc_id
library(ggplot2)
library(dplyr, warn.conflicts=FALSE)
ecb_dates <- ecb_sub %>%
  mutate(Doc_id = row_number()) %>%
  select(Doc_id, Date) %>%
  left_join(ecb_sent$sentiment, by="Doc_id")

## Plot the time series of the average sentiment
ecb_dates %>%
  ggplot(aes(x = Date, y = Average_sentiment)) +
  geom_line(color="#000080") +
  theme_bw() +
  annotate("rect", xmin = as.Date("2008-03-01"), xmax = as.Date("2009-06-01"), 
           ymin=-Inf, ymax=Inf, alpha = .2) +
  annotate("rect", xmin = as.Date("2011-09-01"), xmax = as.Date("2013-03-01"), 
           ymin=-Inf, ymax=Inf, alpha = .2) +
  geom_hline(yintercept = 0, col="grey") +
  ylab("Average sentiment")
```

![](man/figures/README-ECB%20Economic%20Bulletin-1.png)<!-- -->

The `FiGAS` algorithm leverages on a set of semantic rules to identify
the part of text that relates and characterize the token of interest.
The argument `oss` allows to run a *naive* sentiment computation by
assigning a score to each word in the text without the usage of semantic
rules (i.e., overall sentiment score). The figure below shows the
sentiment computed with the proposed algorithm (in blue) and in the
naive way (in red): the former captures the recessionary period more
**timely** and **accurately** than the latter.

``` r
## Overall sentiment score
ecb_sent_OSS      <- get_sentiment(text = text, 
                              include = list("economic activity"),
                              exclude = list("stock market"),
                              oss = TRUE)

ecb_sent_comparison <- left_join(ecb_sent$sentiment, ecb_sent_OSS$sentiment, by="Doc_id")
colnames(ecb_sent_comparison) <- c("Doc_id", "FiGAS", "Naive")

## Plot the time series of the average sentiment
library(tidyr)
cbind(ecb_sent_comparison, ecb_sub) %>%
  gather(var, val, 'FiGAS', Naive) %>%
  ggplot(aes(x = Date, y = val, color=var, group=var)) +
  geom_line() +
  theme_bw() +
  annotate("rect", xmin = as.Date("2008-03-01"), xmax = as.Date("2009-06-01"), 
           ymin=-Inf, ymax=Inf, alpha = .2) +
  annotate("rect", xmin = as.Date("2011-09-01"), xmax = as.Date("2013-03-01"), 
           ymin=-Inf, ymax=Inf, alpha = .2) +
  geom_hline(yintercept = 0, col="grey") +
  ylab("Average sentiment") +
  scale_colour_manual(values=c("#000080", "#E41A1C")) +
  theme(legend.title = element_blank()) 
```

![](man/figures/README-OSS%20ECB%20Economic%20Bulletin-1.png)<!-- -->

## Citation:

If you use this package, please *cite* the following reference:

<!-- ## References: -->

  - Barbaglia L., Consoli S., Manzan S. (September 23, 2020).
    Forecasting with Economic News. Available at SSRN:
    <https://ssrn.com/abstract=3698121>

  - Barbaglia L., Consoli S., Manzan S. (2020). Monitoring the Business
    Cycle with Fine-Grained, Aspect-Based Sentiment Extraction from
    News. In: Bitetta V., Bordino I., Ferretti A., Gullo F., Pascolutti
    S., Ponti G. (eds) Mining Data for Financial Applications. MIDAS
    2019. Lecture Notes in Computer Science, vol 11985. Springer.

## Notes:

1.  ECB Economic Bulletin copyright notice disclaimer “All rights
    reserved. Reproduction for educational and non-commercial purposes
    is permitted provided that the source is acknow ledged”.