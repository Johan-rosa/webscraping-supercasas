# Paquetes ----------------------------------------------------------------
library(here)
library(tidyverse)
library(bcdata)
library(lubridate)

# Importando datos --------------------------------------------------------
tcambio <- get_tcambio("mensual") %>% 
  select(fecha, tcn_venta)

data_historica <- read_rds(here("data/data_historica.RDS"))


data_historica <- data_historica %>% 
  mutate(fecha = floor_date(scrape_date, "month")) %>% 
  left_join(tcambio) %>% 
  mutate(
    precio_pesos = ifelse(divisa == "US$", precio * tcn_venta, precio)
  ) %>% 
  select(
    scrape_date, fecha, tipo_vivienda, precio_pesos,
    habitaciones, banios, parqueos, direccion, metraje,
    divisa, precio, tcn_venta, everything())

data_historica <- data_historica %>% 
  rowid_to_column(var = "id") %>% 
  separate_rows(detalles, sep = ", ") %>% 
  mutate(dummy = 1) %>% 
  spread(detalles, dummy, fill = 0) %>% 
  janitor::clean_names()

data_historica %>% 
  count(fecha) %>%
  filter(fecha > "2019-12-31") %>% 
  ggplot(aes(fecha, n)) +
  geom_line()


library(xlsx)

#write.xlsx(data_eda, "data_supercasas.xlsx")
write_rds(data_historica, "data/data_rds/data_supercasas.rds")
openxlsx::write.xlsx(data_historica, "data/data_csv/data_supercasas.xlsx")

