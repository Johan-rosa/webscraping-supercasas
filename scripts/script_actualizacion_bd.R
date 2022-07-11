# Paquetes ----------------------------------------------------------------
library(here)
library(rvest)
library(tidyverse)

# Funciones de trabajo ----------------------------------------------------
source(
  here::here("scripts", "ejercicio_individual.R"), 
  echo = FALSE, encoding = "UTF-8")

# URL de las páginas generales --------------------------------------------
url_historicas <- readRDS(here::here("data", "url_historicas.RDS"))

url_casas_nuevas <- get_url_viviendas()

url_casas_nuevas <- url_casas_nuevas[!url_casas_nuevas %in% url_historicas]

data_nueva <-  map(url_casas_nuevas, get_house_data)

data_nueva <- bind_rows(data_nueva) %>% 
  tidy_house_data()

# manual_date <- "2021-11-30"
# 
# data_nueva <- data_nueva %>%
#   mutate(
#     scrape_date = lubridate::ymd(manual_date)
#   )

# Guardando archivos actualizados
data_historica <- readRDS(here::here("data", "data_historica.RDS"))

data_historica <- bind_rows(data_historica, data_nueva)
url_historicas <- c(url_historicas, url_casas_nuevas) 

saveRDS(data_historica, here::here("data", "data_historica.RDS"))
saveRDS(url_historicas, here::here("data",  "url_historicas.RDS"))

# Esta parte es para tener versiones de control

saveRDS(
  url_casas_nuevas,
  paste0(
    "data/data_rds/url_nuevas",
    Sys.Date(),
    #manual_date,
    ".RDS"))

saveRDS(
  data_historica,
  paste0(
    "data/data_rds/data_historica",
    Sys.Date(),
    #manual_date,
    ".RDS"))

saveRDS(
  url_historicas,
  paste0(
    "data/data_rds/url_historicas",
    Sys.Date(),
    #manual_date,
    ".RDS")
)
