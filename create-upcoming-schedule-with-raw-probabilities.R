createUpcomingScheduleWithProbabilities <- function(){
  schedule <- nflreadr::load_schedules(nflreadr::get_current_season()) |>
    dplyr::filter(game_type == "REG", week >= nflreadr::get_current_week()) |>
    dplyr::mutate(
      home_decimal_odds = convertAmericanOddsToDecimalOdds(home_moneyline),
      away_decimal_odds = convertAmericanOddsToDecimalOdds(away_moneyline)
    ) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      implied = list(implied::implied_probabilities(
        c(home_decimal_odds, away_decimal_odds),
        method = "power"
      )),
      home_prob = implied$probabilities[1],
      away_prob = implied$probabilities[2]
    ) |>
    dplyr::ungroup() |>
    dplyr::select(game_type, week, away_team, home_team, away_rest, home_rest, location, result, away_prob, home_prob)
  
  return(schedule)
}
