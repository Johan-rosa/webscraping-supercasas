library(tidyverse)
library(bcdata)
library(lubridate)

tcambio <- get_tcambio("mensual") %>% 
  select(fecha, tcn_venta)

data_eda <- data_historica

data_eda <- data_eda %>% 
  mutate(fecha = floor_date(scrape_date, "month")) %>% 
  left_join(tcambio) %>% 
  mutate(
    precio_pesos = ifelse(divisa == "US$", precio * tcn_venta, precio)
  ) %>% 
  select(scrape_date, fecha, tipo_vivienda, precio_pesos,
         habitaciones, banios, parqueos, direccion, metraje,
         divisa, precio, tcn_venta, detalles)


data_eda <- data_eda %>% 
  rowid_to_column(var = "id") %>% 
  separate_rows(detalles, sep = ", ") %>% 
  mutate(dummy = 1) %>% 
  spread(detalles, dummy, fill = 0) %>% 
  janitor::clean_names()


library(xlsx)

write.xlsx(data_eda, "data_supercasas.xlsx")
