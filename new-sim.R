source("convert-odds.R")
source("create-upcoming-schedule-with-raw-probabilities.R")
source("compute-simulation-results.R")

args <- commandArgs(trailingOnly = TRUE)

runSim_2 <- function(currentSeason,
                     noOfSims,
                     noOfChunks,
                     ratings_input_file_path) {
  ratings_df <- read.csv(ratings_input_file_path)
  ratings_named_vector <- setNames(ratings_df[[2]], ratings_df[[1]])

  games <- nflreadr::load_schedules(currentSeason) |> dplyr::filter(game_type == "REG")

  sims <- nflseedR::nfl_simulations(
    games = games,
    chunks = noOfChunks,
    simulations = noOfSims,
    elo = ratings_named_vector,
    sim_include = "POST",
    verbosity = "NONE",
    compute_results = computeSimulationResults,
    upcoming_schedule = createUpcomingScheduleWithProbabilities()
  )
  
  simmed_games_output <- sims$game_summary |>
    dplyr::filter(week >= nflreadr::get_current_week()) |>
    dplyr::select(
      week,
      home = home_team,
      away = away_team,
      spread = result,
      home_win = home_percentage,
      away_win = away_percentage
    ) |>
    dplyr::mutate(
      spread = round(spread * -1, digits = 2)
    ) |>
    dplyr::group_by(week) |>
    tidyr::nest() |>
    jsonlite::toJSON(pretty = TRUE)
  
  arranged_output <- sims$overall |>
    dplyr::select(-seed1, -draft1, -draft5) |>
    dplyr::arrange(division, -div1) |>
    dplyr::mutate(
      playoff = round(1 / playoff, digits = 2),
      div1 = round(1 / div1, digits = 2),
      won_conf = round(1 / won_conf, digits = 2),
      won_sb = round(1 / won_sb, digits = 2)
    ) |>
    dplyr::rename(
      make_playoffs = playoff,
      win_div = div1,
      win_conf = won_conf,
      win_sb = won_sb
    )
  
  outright_output_as_json <- jsonlite::toJSON(arranged_output, pretty = TRUE)
  
  write(simmed_games_output, "./simmed_games_output_new.json")
  write(outright_output_as_json, "./outright_output_new.json")
  
  print(arranged_output |> knitr::kable())
}

runSim_2(as.numeric(args[1]),
         as.numeric(args[2]),
         as.numeric(args[3]),
         args[4])