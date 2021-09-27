# Paquetes -------------------------------------------------------------------------
library(rvest)
library(tidyverse)
library(lubridate)
library(polite)

#source(here::here('scripts/my_bow.R'))
#library(polite)


# Funciones ------------------------------------------------------------------------

  # Extraer las url individuales --- ---- 

  get_url_viviendas <- function(
    provincia = "sd_centro", start_page = 0, end_page = 41) {
  
  # Parametros de utilidad --- --- ---
  
  pattern_type <- paste0(
    "/casa|apartamento|solar|finca|naves|oficina|edificio|",
    "penthouse|negocio|local comercial" )
  
  provincias_disponibles <- list(
    santiago = "9",
    sd_centro = "47",
    sd_oeste = "48",
    sd_este = "49",
    sd_norte = "50"
    )
  
  
  parametro_location <- provincias_disponibles[[provincia]]
  pages_seq <- seq(start_page, end_page)
  session <- bow("https://www.supercasas.com/buscar/?",
                 user_agent = "johan.rosaperez@gmail.com", delay = 0.01, 
                 verbose = FALSE, force = TRUE)
  
  
  html_generales <- purrr::map(
    pages_seq,
    ~polite::scrape(
      session,
      query = list(location = parametro_location,
                      PriceType = "400",
                      PagingPageSkip = .x)
      ))
  
  url_disponibles <- purrr::map(
    html_generales,
      ~.x %>%
        rvest::html_nodes(".normal a") %>%
        rvest::html_attr("href") %>%
        stringr::str_subset(pattern = pattern_type)
      )
  
  
  urls <- url_disponibles %>%
    unlist() %>%
    unique()
  
  return(urls)
}

# Extraer la data de las viviendas --- ----
  
get_house_data <- function(supercasas_bow, url_casa) {
  
  pattern_type <- paste0(
    "casa|apartamento|solar|finca|nave|oficina|edificio|",
    "penthouse|negocio|local comercial" )

  html <- nod(supercasas_bow, url_casa) %>%
    polite::scrape()
  
  scrape_date <- Sys.Date()
  
  tipo_vivienda <- html %>%
    html_nodes("#detail-ad-header h2") %>%
    html_text() %>%
    str_to_lower() %>%
    str_extract(pattern = pattern_type)
  
  # extraer el precio del inmueble
  precio <- html %>%
    html_nodes("#detail-ad-header h3") %>%
    html_text()
  
  # extraer atributos con cantidad de habitaciones,
  # baños y paqueos
  atributos <- html %>%
    html_nodes(".secondary-info span") %>%
    html_text()
  
  # Cantidad de habitaciones  
  habitaciones <- atributos[1]
  
  # Cantidad de baños
  banios <- atributos[2]
  
  if(length(atributos) < 3){
    parqueos <- NA_character_
  } else {
    # Cantidad de paqueos
    parqueos <- atributos[3]
  }
  
  # Dirección
  direccion <- html %>%
    html_nodes("tr:nth-child(1) td") %>%
    html_text() %>%
    tail(1)
  
  # Dimensiones
  metraje <- html %>%
    html_nodes("tr:nth-child(3) td:nth-child(2)") %>%
    html_text()
  
  # Detalles
  detalles <- html %>%
    html_nodes("#detail-ad-info-specs ul li") %>%
    html_text() %>%
    paste(collapse = ", ")
  
  data <- data.frame(
    scrape_date = scrape_date,
    tipo_vivienda = tipo_vivienda,
    precio = precio,
    habitaciones = habitaciones,
    banios = banios,
    parqueos = parqueos,
    direccion = direccion,
    metraje = metraje,
    detalles = detalles
  )
  
  return(data)
  
  
}

get_house_data <- purrr::possibly(get_house_data, data.frame())

# tidy_house_data --- ----

tidy_house_data <- function(df) {
  
  df_tidy <- df %>%
    separate(precio, into = c("divisa", "precio"), sep = " ") %>%
    mutate(
      precio = parse_number(precio),
      habitaciones = parse_number(habitaciones),
      banios = parse_number(banios),
      parqueos = parse_number(parqueos),
      metraje = parse_number(metraje)
    )
  
  return(df_tidy)
}
