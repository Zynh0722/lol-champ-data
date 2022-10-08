# Preincluding names we know we are going to use
library("jsonlite")
library("httr")
library("stringr")
library("dplyr")

get_latest_champion_data <- function() {
    r <- GET("https://ddragon.leagueoflegends.com/api/versions.json", )
    parsed <- fromJSON(content(r, "text", encoding = "utf-8"))

    latest_champion_url <-
        paste("http://ddragon.leagueoflegends.com/cdn/",
            parsed[1],
            "/data/en_US/champion.json",
            sep = ""
        )
    r <- GET(latest_champion_url)
    parsed <- fromJSON(content(r, "text", encoding = "utf-8"))

    sapply(parsed$data, function(arr) arr$stats)
}

# Worth noting this is actually a matrix, is.matrix evaluates to true.
# However I'm not an R programmer, but typeof(stat_matrix) is list?
# This seems to imply at least matrices in R are just lists that match
# a set of conditons? (containing elements of the same atomic type)
stat_matrix <- get_latest_champion_data()

# Parsing base stats
stats <- unlist(dimnames(stat_matrix)[1])
scaling_stats <- Filter(function(s) grepl("perlevel", s, fixed = TRUE), stats)

# Remove all base stats
stat_matrix <-
    stat_matrix[scaling_stats, ]

# Remove perlevel from stat names
stat_names <- unlist(dimnames(stat_matrix)[1])
stat_names <- list(str_remove(stat_names, "perlevel"))
dimnames(stat_matrix)[1] <- stat_names

# DATA INVALID UNTIL REGEN STATS ARE CONFIRMED
stat_values <- list(
    attackdamage = 35,
    attackspeed = 25,
    crit = 40,
    mpregen = 5,
    hpregen = 3,
    armor = 20,
    spellblock = 18,
    mp = 1.4,
    hp = 2.67
)

for (name in names(stat_values)) {
    stat_matrix[name, ] <-
        lapply(
            stat_matrix[name, ],
            function(num) num * stat_values[[name]]
        )
}

gold_values_per_level <- c()
for (champ in dimnames(stat_matrix)[[2]]) {
    gold_values_per_level[champ] <- sum(unlist(stat_matrix[, champ]))
}

write.csv(
    gold_values_per_level, 
    "/Users/zynh/Documents/projects/rplayground/output.csv"
)