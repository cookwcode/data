# make data of films
library(tidyverse)
library(here)

data <- tribble(
    ~year, ~title, ~type,
    1968, "Planet of the Apes", "Original",
    1970, "Beneath the Planet of the Apes", "Original",
    1971, "Escape from the Planet of the Apes", "Original",
    1972, "Conquest of the Planet of the Apes", "Original",
    1973, "Battle for the Planet of the Apes", "Original",
    2001, "Planet of the Apes", "Remake",
    2011, "Rise of the Planet of the Apes", "Reboot",
    2014, "Dawn of the Planet of the Apes", "Reboot",
    2017, "War for the Planet of the Apes", "Reboot",
    2024, "Kingdom of the Planet of the Apes", "Reboot"
)

data %>% write_csv(here("planet-of-the-apes/pota_films.csv"))
