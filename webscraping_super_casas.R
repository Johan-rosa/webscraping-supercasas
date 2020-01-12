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

# Url generales DN --- ---

paginas_generales_distrito <- paste0(
  "https://www.supercasas.com/buscar/?Locations=47&PriceType=400&PagingPageSkip=",
  0:41)


# Extraer las url individuales de las casas en venta del DN

url_casas_distrito <- list()

for (i in 1:length(paginas_generales_distrito)) {
  
  url_casas_distrito[[i]] <- get_url(paginas_generales_distrito[i]) 
  
  print(i/length(paginas_generales_distrito) * 100)
  
  Sys.sleep(0.3)
}

url_casas_distrito <- url_casas_distrito %>%
  unlist() %>%
  paste0("https://www.supercasas.com/", .)

# Extraer caracteristicas de las casas --- ---- 

datos_inmuebles <- vector(mode = "list", length = length(url_casas_distrito))

for (i in 1:length(url_casas_distrito)) {
  
  datos_inmuebles_diciembre[[i]] <- get_house_data(url_casas_distrito[i])
  print(paste0("Iteracion: ", i, " de ", length(url_casas_distrito)))
  
  Sys.sleep(5)
}


datos_diciembre_df <- datos_inmuebles %>%
  #map(~.x %>%
  #      dplyr::select(tipo_vivienda:metraje) %>%
  #      summarise_all( unique) ) %>%
  bind_rows()

datos_inmuebles_df %>%
  glimpse()

write_csv(datos_inmuebles_df, "data_distrito_clean2.csv")  

datos_inmuebles_clean <- datos_inmuebles_df %>%
  separate(precio, into = c("divisa", "precio"), sep = " ") %>%
  mutate(
    precio = parse_number(precio),
    habitaciones = parse_number(habitaciones),
    banios = parse_number(banios),
    parqueos = parse_number(parqueos),
    metraje = parse_number(metraje)
    ) %>% glimpse()

datos_inmuebles_df$detalles %>%
  view()
  str_extract(" .*$") %>%
  table


write.csv(datos_inmuebles_clean, "data_distrito_clean2.csv")

save.image("ws_noviembre")

