
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Lexicon-based Sentiment Analysis for Economic and Financial Applications

The `FiGASR` package allows R users to leverage on cutting-hedge NLP
techniques to easily run sentiment analysis on economic news content:
this package is a wrapper of the
[`SentiBigNomics`](https://github.com/sergioconsoli/SentiBigNomics)
python package. Given a list of texts as input and a list of tokens of
interest (ToI), the algorithm analyses the texts and compute the
economic sentiment associated each ToI. Two key features characterize
this approach. First, it is *fine-grained*, since words are assigned a
polarity score that ranges in \[-1,1\] based on a dictionary. Second, it
is *aspect-based*, since the algorithm selects the chunk of text that
relates to the ToI based on a set of semantic rules and calculates the
sentiment only on that text, rather than the full article.

The package includes some additional of features, like automatic
negation handling, tense detection, location filtering and excluding
some words from the sentiment computation. `FiGASR` only supports
English language, as it relies on the *en\_core\_web\_lg* language model
from the `spaCy` Python module.

## Installation

You can install the package from GitHub as follows:

``` r
install.packages("devtools")
devtools::install_github("lucabarbaglia/FiGASR")
```

If it is the first time that you are using `FiGASR`, then set up the
associated environment:

``` r
FiGASR::figas_install()
```

## A start-up example

Let’s assume that you want to compute the sentiment associated to two
tokens of interest, namely *unemployment* and *economy*, given the two
following sentences.

``` r
library(FiGASR)
text <- list("Unemployment is rising at high speed",
             "The economy is slowing down and unemployment is booming")
include = list("unemployment", "economy")

get_sentiment(text = text, include = include)
#> $sentiment
#> # A tibble: 2 × 2
#>   Doc_id Average_sentiment
#>    <dbl>             <dbl>
#> 1      1             -0.85
#> 2      2             -0.6 
#> 
#> $sentiment_by_chunk
#> # A tibble: 3 × 6
#>   Doc_id Text                                      Chunk Sentiment Tense Include
#>    <dbl> <chr>                                     <chr>     <dbl> <chr> <chr>  
#> 1      1 Unemployment is rising at high speed      Unem…     -0.85 pres… unempl…
#> 2      2 The economy is slowing down and unemploy… econ…     -0.4  pres… economy
#> 3      2 The economy is slowing down and unemploy… unem…     -0.8  pres… unempl…
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
released between 1999 and 2019, and to `beige_book`, the [FED Beige
Book](https://www.federalreserve.gov/monetarypolicy/beige-book-default.htm)
released between 1983 and 2019.

Let’s provide an example of some additional features of the package:
assume that we want to extract the sentiment about “economic activity”
on the ECB Economic Bulletin releases in 2007-13. The figure below plots
the economic sentiment computed by `FiGASR`, which timely identifies the
recessionary period indicated by the shadowed area following the [EABCN
business cycles reference
dates](https://eabcn.org/dc/chronology-euro-area-business-cycles).

``` r
data("ecb_bulletin")
ecb_sub <- ecb_bulletin[ecb_bulletin$Date >= as.Date("2007-01-01") & ecb_bulletin$Date <= as.Date("2013-01-01"), ]
text <- as.list(as.data.frame(ecb_sub)[, "Text"])

## Compute sentiment about "economic activity"
ecb_sent      <- get_sentiment(text = text,
                              include = list("economic activity")) #, exclude = list("stock market"))

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

The `FiGASR` algorithm leverages on a set of semantic rules to identify
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
                              oss = TRUE)

ecb_sent_comparison <- left_join(ecb_sent$sentiment, ecb_sent_OSS$sentiment, by="Doc_id")
colnames(ecb_sent_comparison) <- c("Doc_id", "FiGASR", "Naive")

## Plot the time series of the average sentiment
library(tidyr)
cbind(ecb_sent_comparison, ecb_sub) %>%
  gather(var, val, 'FiGASR', Naive) %>%
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

## Daily sentiment data

The daily sentiment indicators for the US by [Barbaglia et
al. (2023)](https://doi.org/10.1080/07350015.2022.2060988) and for
Europe by [Barbaglia et al. (202X)](https://doi.org/10.1002/jae.3027)
can be accessed with the command `data("sentiment")`. The figure below
plots the economic sentiment indicators for the US, which timely
identifies the recessionary period indicated by the shadowed area
following the [NBER business cycles reference
dates](https://www.nber.org/cycles.html).

<img src="man/figures/README-US sentiment-1.png" width="80%" />

## Economic Lexicon

Within the package, we also provide access to the **Economic Lexicon
(EL)**, a dictionary with a fine-grained score in \[-1,+1\] for 4,165
terms. The EL is built with human-annotation and targets specifically
economic applications. More details are provide in [Barbaglia et
al. (2022)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4106936).

``` r
data("EL")
EL
#> # A tibble: 4,165 × 3
#>    token        sentiment polarity
#>    <chr>            <dbl> <chr>   
#>  1 abandon          -0.5  negative
#>  2 abandonment      -0.6  negative
#>  3 abdication       -0.25 negative
#>  4 aberration       -0.45 negative
#>  5 aberrational     -0.25 negative
#>  6 abet             -0.35 negative
#>  7 abeyance         -0.5  negative
#>  8 abeyances        -0.3  negative
#>  9 abide             0.2  positive
#> 10 ability           0.1  positive
#> # ℹ 4,155 more rows
```

## Citation:

If you use this package, please *cite* the following references:

<!-- ## References: -->

  - Barbaglia, Consoli, Manzan (202X). Forecasting GDP in Europe with
    Textual Data. *Journal of Applied Econometrics*:
    <https://doi.org/10.1002/jae.3027>

  - Barbaglia, Consoli, Manzan (2023). Forecasting with Economic News.
    *Journal of Business & Economic Statistics*:
    <https://doi.org/10.1080/07350015.2022.2060988>

  - Consoli, Barbaglia, Manzan (2022). Fine-Grained Aspect-Based
    Sentiment Analysis on Economic and Financial Lexicon.
    *Knowledge-Based Systems*:
    <https://doi.org/10.1016/j.knosys.2022.108781>

<!-- end list -->

1.  ECB Economic Bulletin copyright notice disclaimer “All rights
    reserved. Reproduction for educational and non-commercial purposes
    is permitted provided that the source is acknow ledged”.
