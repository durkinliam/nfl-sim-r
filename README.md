# NFL Season Simulation

Simulation logic using R to simulate the current NFL season.

```
Rscript run-sim.R (season_year) (number of simulation iterations) (number of chunks)
```

For best results, run this within a terminal outside of an IDE. I typically run 100,000 simulations broken into 100 chunks of 1000 sims per chunk. 

On my machine, it takes around 2 minutes to run.

### Example terminal output

|conf |division  |team |     wins| make_playoffs|  win_div|  win_conf|    win_sb|
|:----|:---------|:----|--------:|-------------:|--------:|---------:|---------:|
|AFC  |AFC East  |NE   | 13.00850|          1.01|     1.32|      5.95|     14.71|
|AFC  |AFC East  |BUF  | 11.84590|          1.07|     4.09|      5.68|     11.33|
|AFC  |AFC East  |MIA  |  6.81189|        129.70| 20000.00|   3846.15|  12500.00|
|AFC  |AFC East  |NYJ  |  4.30455|       5263.16|      Inf| 100000.00|       Inf|
|AFC  |AFC North |BAL  |  9.81518|          1.36|     1.41|      8.34|     16.97|
|AFC  |AFC North |PIT  |  8.89888|          2.57|     3.51|     27.03|     63.29|
|AFC  |AFC North |CIN  |  5.29712|        160.51|   208.33|   2127.66|   6250.00|
|AFC  |AFC North |CLE  |  4.79527|       4000.00|  7692.31| 100000.00| 100000.00|
|AFC  |AFC South |IND  | 11.61438|          1.13|     1.41|      7.74|     18.18|
|AFC  |AFC South |JAX  | 10.00905|          1.53|     4.02|     29.49|     80.97|
|AFC  |AFC South |HOU  |  8.06021|          5.23|    23.05|     58.69|    135.50|
|AFC  |AFC South |TEN  |  2.69648|           Inf|      Inf|       Inf|       Inf|
|AFC  |AFC West  |DEN  | 12.58930|          1.04|     1.32|      6.11|     14.83|
|AFC  |AFC West  |LAC  | 10.11317|          1.51|     6.69|     18.00|     42.11|
|AFC  |AFC West  |KC   |  9.97988|          1.74|    10.47|     10.15|     18.85|
|AFC  |AFC West  |LV   |  4.42793|       2564.10|      Inf|  50000.00|  50000.00|
|NFC  |NFC East  |PHI  | 12.85096|          1.00|     1.01|      3.53|      6.39|
|NFC  |NFC East  |DAL  |  7.36691|         19.67|   167.50|    363.64|    729.93|
|NFC  |NFC East  |WAS  |  5.18041|       1785.71|  2083.33|  20000.00|  50000.00|
|NFC  |NFC East  |NYG  |  4.20424|           Inf|      Inf|       Inf|       Inf|
|NFC  |NFC North |DET  | 10.74421|          1.25|     2.29|      7.27|     12.11|
|NFC  |NFC North |GB   | 10.53840|          1.37|     2.74|     12.22|     22.24|
|NFC  |NFC North |CHI  |  9.91528|          1.88|     5.18|     40.05|     91.41|
|NFC  |NFC North |MIN  |  6.62309|         33.92|   200.00|    591.72|   1250.00|
|NFC  |NFC South |TB   | 10.19957|          1.17|     1.19|     25.39|     58.38|
|NFC  |NFC South |CAR  |  7.80002|          5.56|     6.77|    324.68|    813.01|
|NFC  |NFC South |ATL  |  6.14202|         64.98|   132.45|   1086.96|   2272.73|
|NFC  |NFC South |NO   |  4.89057|        155.28|   156.99|  10000.00|  25000.00|
|NFC  |NFC West  |LA   | 12.88318|          1.02|     1.54|      4.01|      7.06|
|NFC  |NFC West  |SEA  | 11.82522|          1.07|     4.45|      8.32|     15.18|
|NFC  |NFC West  |SF   | 11.02802|          1.12|     7.95|     18.31|     38.39|
|NFC  |NFC West  |ARI  |  5.54021|        396.83|      Inf|   8333.33|  16666.67|

### Output
#### Games
Along with the visual output within the terminal, upcoming week by week games are saved into a JSON array within `simmed_games_output.json`.

This data will detail match ups, the simulated final spread of the game and win probabilities for each team given that match up. These are all used within the overall simulation output. One caveat is that the post-season games are only projected per simulation, based on end of regular season simulations, and therefore some simulated games only ever happen once and can look a little off on the face of it.
For example: A projected Super Bowl match up which only appears once with 100,000 simulations. Because it only appears once, the `home_win` probability is 100% - it can look very definitive that something **will** happen.

#### Season
There is a JSON file containing all of the data which makes up the post-simulation grid outputted in the terminal, shown above. The file is saved after simulations at `outright_output.json`.
