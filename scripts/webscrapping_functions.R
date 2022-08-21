# Objetos utilitarios --------------------------------------------------------------

# Extraer las url individuales --- --- 

get_url <- function(url_general) {
  rvest::read_html('https://www.supercasas.com/buscar/?Locations=47&PriceType=400&PagingPageSkip=1') %>% 
    rvest::html_elements('li.normal a') %>% 
    rvest::html_attr('href') %>% 
    stringr::str_subset(pattern = "/casa|apartamento|solar|finca|naves|oficina|edificio|penthouse|negocio|local comercial")
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

 viviendas_url <- purrr::map(urls, save_get_url) %>% 
   unlist()

 return(viviendas_url)
}


get_house_data <- function(url_casa) {
  
  pattern_type <- paste0(
    "casa|apartamento|solar|finca|nave|oficina|edificio|",
    "penthouse|negocio|local comercial" )
  
  url_casa <- paste0("https://www.supercasas.com", url_casa)
  
  # leer el html
  html <- rvest::read_html(url_casa)
  
  scrape_date <- Sys.Date()
  
  tipo_vivienda <- html %>%
    rvest::html_nodes("#detail-ad-header h2") %>%
    rvest::html_text() %>%
    stringr::str_to_lower() %>%
    stringr::str_extract(pattern = pattern_type)
  
  # extraer el precio del inmueble
  precio <- html %>%
    rvest::html_nodes("#detail-ad-header h3") %>%
    rvest::html_text()
  
  # extraer atributos con cantidad de habitaciones,
  # baños y paqueos
  atributos <- html %>%
    rvest::html_nodes(".secondary-info span") %>%
    rvest::html_text()
  
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
    rvest::html_nodes("tr:nth-child(1) td") %>%
    rvest::html_text() %>%
    tail(1)
  
  # Dimensiones
  metraje <- html %>%
    rvest::html_nodes("tr:nth-child(3) td:nth-child(2)") %>%
    rvest::html_text()
  
  # Detalles
  detalles <- html %>%
    rvest::html_nodes("#detail-ad-info-specs ul li") %>%
    rvest::html_text() %>%
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
    tidyr::separate(precio, into = c("divisa", "precio"), sep = " ") %>%
    dplyr::mutate(
      precio = readr::parse_number(precio),
      habitaciones = readr::parse_number(habitaciones),
      banios = readr::parse_number(banios),
      parqueos = readr::parse_number(parqueos),
      metraje = readr::parse_number(metraje)
    )
  
  return(df_tidy)
}






