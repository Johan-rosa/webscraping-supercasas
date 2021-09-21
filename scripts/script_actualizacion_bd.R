# Paquetes ----------------------------------------------------------------
library(here)

# Funciones de trabajo -------------------------------------------------------------
<<<<<<< HEAD:scripts/script_actualizacion_bd.R
source(here("scripts", "funciones_webscraping_supercasas.R"))
url_historicas <- readRDS(here("data", "url_historicas.RDS"))
=======
source(here::here("scripts", "funciones_webscraping_supercasas.R"))


url_historicas <- readRDS(here::here("data", "url_historicas.RDS"))
>>>>>>> 78f2016b7d02268b274f5ffc3528f0726526bc1a:script_actualizacion_bd.R


# Parametros de las viviendas de Santo Domingo en SuperCasas

# Descargando las url individuales

url_casas_nuevas <- get_url_viviendas()

url_casas_nuevas <- url_casas_nuevas[!url_casas_nuevas %in% url_historicas]

# Descargando la data de las viviendas

supercasas_bow <- bow(
  "https://www.supercasas.com",
  user_agent = "johan.rosaperez@gmail.com",
  delay = 0.5)

data_nueva <- map(
  url_casas_nuevas,
  ~get_house_data(supercasas_bow, url_casa = .x)
  )

data_nueva <- bind_rows(data_nueva) %>% 
  tidy_house_data()


# manual_date <- "2021-04-30"
# 
# data_nueva <- data_nueva %>%
#   mutate(
#     scrape_date = lubridate::ymd(manual_date)
#   )

# Guardando archivos actualizados
<<<<<<< HEAD:scripts/script_actualizacion_bd.R
data_historica <- readRDS(here("data", "data_historica.RDS"))
=======
data_historica <- readRDS(here::here("data", "data_historica.RDS"))
>>>>>>> 78f2016b7d02268b274f5ffc3528f0726526bc1a:script_actualizacion_bd.R

data_historica <- bind_rows(data_historica, data_nueva)
url_historicas <- c(url_historicas, url_casas_nuevas) 

<<<<<<< HEAD:scripts/script_actualizacion_bd.R
saveRDS(data_historica, here("data", "data_historica.RDS"))
saveRDS(url_historicas, here("data",  "url_historicas.RDS"))
=======
saveRDS(data_historica, here::here("data", "data_historica.RDS"))
saveRDS(url_historicas, here::here("data",  "url_historicas.RDS"))
>>>>>>> 78f2016b7d02268b274f5ffc3528f0726526bc1a:script_actualizacion_bd.R

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




