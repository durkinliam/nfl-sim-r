updateRatings <- function() {
  nfeloRatings <- read.csv(
    "https://raw.githubusercontent.com/greerreNFL/nfelo/refs/heads/main/output_data/elo_snapshot.csv"
  )
  
  ratings <- nfeloRatings |>
    dplyr::select(team, rating = nfelo) |>
    dplyr::mutate(
      rating = round(rating),
      team = dplyr::case_when(team == "LAR" ~ "LA", team == "OAK" ~ "LV", TRUE ~ team)
    )
  
  write.csv(ratings, "./new_team_ratings.csv", row.names = FALSE)
}
