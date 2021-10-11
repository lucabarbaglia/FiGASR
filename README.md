
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
#> # A tibble: 2 x 2
#>   Doc_id Average_sentiment
#>    <dbl>             <dbl>
#> 1      1             -0.85
#> 2      2             -0.6 
#> 
#> $sentiment_by_chunk
#> # A tibble: 3 x 6
#>   Doc_id Text                       Chunk              Sentiment Tense Include  
#>    <dbl> <chr>                      <chr>                  <dbl> <chr> <chr>    
#> 1      1 Unemployment is rising at… Unemployment is r…     -0.85 pres… unemploy…
#> 2      2 The economy is slowing do… economy is slowing     -0.4  pres… economy  
#> 3      2 The economy is slowing do… unemployment is b…     -0.8  pres… unemploy…
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

### US sentiment

The daily sentiment indicators used for the US used in [Barbaglia et
al. (2021)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3698121)
can be accessed with the command `data("US_sentiment")`. The figure
below plots the economic sentiment indicators, which timely identifies
the recessionary period indicated by the shadowed area following the
[NBER business cycles reference
dates](https://www.nber.org/cycles.html).

<img src="man/figures/README-US sentiment-1.png" width="80%" />

## Citation:

If you use this package, please *cite* the following references:

<!-- ## References: -->

  - Barbaglia, Consoli, Manzan (May 26, 2021). Forecasting with Economic
    News. Available at SSRN: <https://ssrn.com/abstract=3698121>

  - Consoli, Barbaglia, Manzan (January 14, 2021). Fine-Grained
    Aspect-Based Sentiment Analysis on Economic and Financial Lexicon.
    Available at SSRN: <https://ssrn.com/abstract=3766194>
