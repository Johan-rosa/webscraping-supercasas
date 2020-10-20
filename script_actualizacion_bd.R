# Funciones de trabajo -------------------------------------------------------------
source("funciones_webscraping_supercasas.R")
url_historicas <- readRDS("url_historicas.RDS")


# Parametros de las viviendas de Santo Domingo en SuperCasas

# Descargando las url individuales

url_casas_nuevas <- get_url_viviendas()

url_casas_nuevas <- url_casas_nuevas[!url_casas_nuevas %in% url_historicas]

# Descargando la data de las viviendas

supercasas_bow <- bow(
  "https://www.supercasas.com",
  user_agent = "johan.rosaperez@gmail.com",
  delay = 1)

data_nueva <- map(
  url_casas_nuevas,
  ~get_house_data(supercasas_bow, url_casa = .x)
  )

data_nueva <- bind_rows(data_nueva) %>% 
  tidy_house_data()


# Guardando archivos actualizados
data_historica <- readRDS("data_historica.RDS")

data_historica <- bind_rows(data_historica, data_nueva)
url_historicas <- c(url_historicas, url_casas_nuevas) 

saveRDS(data_historica, "data_historica.RDS")
saveRDS(url_historicas, "url_historicas.RDS")

# Esta parte es para tener versiones de control

saveRDS(
  url_casas_nuevas,
  paste0(
    "data_rds/url_nuevas",
    Sys.Date(),
    ".RDS"))

saveRDS(
  data_historica,
  paste0(
    "data_rds/data_historica",
    Sys.Date(),
    ".RDS"))

saveRDS(
  url_historicas,
  paste0(
    "data_rds/url_historicas",
    Sys.Date(),
    ".RDS")
  )




