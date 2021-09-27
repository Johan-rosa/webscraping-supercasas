# Paquetes -------------------------------------------------------------------------
library(rvest)
library(tidyverse)
library(lubridate)


# Objetos utilitarios --------------------------------------------------------------

# Extraer las url individuales --- --- 

get_url <- function(url_general) {
  read_html('https://www.supercasas.com/buscar/?Locations=47&PriceType=400&PagingPageSkip=1') %>% 
    html_elements('li.normal a') %>% 
    html_attr('href') %>% 
    str_subset(pattern = "/casa|apartamento|solar|finca|naves|oficina|edificio|penthouse|negocio|local comercial")
}


save_get_url <- purrr::possibly(get_url, otherwise = NA_character_, quiet = TRUE)


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
  
  
  urls <- paste0(
    "https://www.supercasas.com/buscar/?location=", parametro_location,
    "&PriceType=400&PagingPageSkip=", pages_seq
    )
  
  
 viviendas_url <- map(urls, save_get_url) %>% 
   unlist()
  

 return(viviendas_url)
}


get_house_data <- function(url_casa) {
  
  pattern_type <- paste0(
    "casa|apartamento|solar|finca|nave|oficina|edificio|",
    "penthouse|negocio|local comercial" )
  
  url_casa <- paste0("https://www.supercasas.com", url_casa)
  
  # leer el html
  html <- read_html(url_casa)
  
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






