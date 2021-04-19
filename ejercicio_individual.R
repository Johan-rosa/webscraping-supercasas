# Paquetes -------------------------------------------------------------------------
library(rvest)
library(tidyverse)
library(lubridate)


# Objetos utilitarios --------------------------------------------------------------

# Extraer las url individuales --- --- 

get_url <- function(url_general) {
  
  read_html(url_general) %>%
    html_nodes(".normal a") %>%
    html_attr("href") %>%
    str_subset(pattern = "apartamentos|casas-")
}

get_house_data <- function(url_casa) {
  
  url_casa <- paste0("https://www.supercasas.com", url_casa)
  
  # leer el html
  html <- read_html(url_casa)
  
  tipo_vivienda <- html %>%
    html_nodes("#detail-ad-header h2") %>%
    html_text() %>%
    str_to_lower() %>%
    str_extract("casa|apartamento|solar|finca|nave|oficina|edificio|penthouse|negocio|local comercial")
  
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



# Extraer los datos de las viviendas publicadas ------------------------------------
urls <- get_url("https://www.supercasas.com/buscar/?PriceType=400")

map_df(urls[1:3], get_house_data)
