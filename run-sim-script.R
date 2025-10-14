args <- commandArgs(trailingOnly = TRUE)

runSim <- function(currentSeason,
                   noOfSims,
                   noOfChunks,
                   ratings_input_file_path) {
  ratings_df <- read.csv(ratings_input_file_path)
  ratings_named_vector <- setNames(ratings_df[[2]], ratings_df[[1]])
  
  sims <- nflseedR::nfl_simulations(
    games = nflreadr::load_schedules(currentSeason) |> dplyr::filter(game_type == "REG"),
    chunks = noOfChunks,
    simulations = noOfSims,
    elo = ratings_named_vector,
    sim_include = "POST",
    verbosity = "NONE"
  )
  
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
  
  output_as_json <- jsonlite::toJSON(arranged_output)
  
  write(output_as_json, "./output.json")
  
  
  print(arranged_output |> knitr::kable())
}

runSim(as.numeric(args[1]),
       as.numeric(args[2]),
       as.numeric(args[3]),
       args[4])
