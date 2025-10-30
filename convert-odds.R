convertAmericanOddsToDecimalOdds <- function(american_odds) {
  odds <- as.numeric(american_odds)
  
  decimal_odds <- dplyr::case_when(is.na(odds) ~ NA_real_,
                                   odds > 0    ~ (odds / 100) + 1,
                                   odds < 0    ~ (100 / abs(odds)) + 1,
                                   TRUE        ~ 1.00)
  
  return(decimal_odds)
}
