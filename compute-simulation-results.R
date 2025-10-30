computeSimulationResults <- function(teams, games, week_num, ...) {
  args <- list(...)
  upcomingSchedule <- args$upcoming_schedule
  
  data.table::setDT(games)
  data.table::setDT(upcomingSchedule)
  upcomingSchedule[, week := as.factor(week)]
  
  prob_cols <- c(
    "game_type",
    "week",
    "away_team",
    "home_team",
    "away_rest",
    "home_rest",
    "location",
    "result",
    "home_prob",
    "away_prob"
  )
  games <- merge(
    games,
    upcomingSchedule[, ..prob_cols],
    by = c(
      "game_type",
      "week",
      "away_team",
      "home_team",
      "away_rest",
      "home_rest",
      "location",
      "result"
    ),
    all.x = TRUE,
    sort = FALSE
  )
  
  drop_cols <- grep(
    "^home_prob\\.|^away_prob\\.|^i\\.|^home_prob\\.y|^away_prob\\.y",
    names(games),
    value = TRUE
  )
  if (length(drop_cols) > 0)
    games[, (drop_cols) := NULL]
  
  games <- upcomingSchedule[games, on = c(
    "game_type",
    "week",
    "away_team",
    "home_team",
    "away_rest",
    "home_rest",
    "location",
    "result"
  )]
  
  homeFieldAdvantage <- 2.22 * 25
  round_out <- function(x) {
    x <- x[!is.na(x)]
    x[x < 0] <- floor(x[x < 0])
    x[x > 0] <- ceiling(x[x > 0])
    as.integer(x)
  }
  if (!data.table::is.data.table(games))
    data.table::setDT(games)
  if (!data.table::is.data.table(teams))
    data.table::setDT(teams)
  games_indices <- data.table::indices(games)
  if (is.null(games_indices) || !"week" %chin% games_indices) {
    data.table::setindexv(games, c("week", "location", "game_type"))
  }
  if (!"elo" %chin% colnames(teams)) {
    args <- list(...)
    if ("elo" %chin% names(args)) {
      ratings <- args$elo
      teams[, elo := ratings[team]]
    } else {
      ratings <- setNames(rnorm(length(unique(teams$team)), 1500, 150), unique(teams$team))
      teams[, elo := ratings[team]]
    }
  }
  ratings <- teams[, setNames(elo, paste(sim, team, sep = "-"))]
  games[list(week_num), away_elo := ratings[paste(sim, away_team, sep = "-")], on = "week"]
  games[list(week_num), home_elo := ratings[paste(sim, home_team, sep = "-")], on = "week"]
  games[list(week_num), elo_diff := home_elo - away_elo + (home_rest - away_rest) / 7 * 25, on = "week"]
  games[list(week_num, "Home"), elo_diff := elo_diff + homeFieldAdvantage, on = c("week", "location")]
  games[list(week_num, c("WC", "DIV", "CON", "SB")), elo_diff := elo_diff * 1.2, on = c("week", "game_type")]

  games[list(week_num), `:=`(
    wp = data.table::fifelse(!is.na(home_prob) & !is.na(away_prob), home_prob, 1 / (10^(-elo_diff / 400) + 1)),
    estimate = data.table::fifelse(
      !is.na(home_prob) & !is.na(away_prob),
      (home_prob - away_prob) * 25,
      elo_diff / 25
    )
  ), on = "week"]

  games[list(week_num) == week & is.na(result), result := round_out(rnorm(.N, estimate, 13))]
  games[list(week_num), `:=`(
    outcome = data.table::fcase(is.na(result), NA_real_, result > 0, 1, result < 0, 0, default = 0.5),
    elo_input = data.table::fcase(
      is.na(result),
      NA_real_,
      result > 0,
      elo_diff * 0.001 + 2.2,
      result < 0,
      -elo_diff * 0.001 + 2.2,
      default = 1.0
    )
  ), on = "week"]
  games[list(week_num), elo_mult := log(pmax(abs(result), 1) + 1.0) * 2.2 / elo_input, on = "week"]
  games[list(week_num), elo_shift := 20 * elo_mult * (outcome - wp), on = "week"]
  elo_change_away <- games[list(week_num), setNames(-elo_shift, paste(sim, away_team, sep = "-")), on = "week"]
  elo_change_home <- games[list(week_num), setNames(elo_shift, paste(sim, home_team, sep = "-")), on = "week"]
  elo_change <- c(elo_change_away, elo_change_home)
  drop_cols <- c(
    "away_elo",
    "home_elo",
    "elo_diff",
    "wp",
    "estimate",
    "outcome",
    "elo_input",
    "elo_mult",
    "elo_shift"
  )
  games[, (drop_cols) := NULL]
  teams[, elo_shift := elo_change[paste(sim, team, sep = "-")]]
  teams[, elo_shift := data.table::fifelse(is.na(elo_shift), 0, elo_shift)]
  teams[, elo := elo + elo_shift]
  teams[, elo_shift := NULL]
  list("teams" = teams, "games" = games)
}
