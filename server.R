#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# library(aquatools)
library(DBI)
library(dplyr)
# library(ggplot2)
library(glue)
library(fs)
# library(gt)
# library(gtsummary)
# library(hms)
library(lubridate)
library(magrittr)
library(markdown)
library(purrr)
# library(readr)
# library(readxl)
# library(scales)
# library(sf)
library(shiny)
library(stringr)
# library(tibble)

# Define server logic required to draw a histogram
function(input, output, session) {

  #### Francisation ####
  if(Sys.info()['sysname'] %>% str_replace("sysname", "") == "Darwin") Sys.setlocale("LC_TIME", "French") # OSX
  if(Sys.info()['sysname'] %>% str_replace("sysname", "") == "Linux") Sys.setlocale("LC_TIME", "fr_FR.UTF-8") # Serveur linux
  
  #### Menus ####
  logo <- "FD39blanc.png"
  
  output$sidebar <- renderMenu({
    sidebarMenu(
      id = "tabs",
      menuItem("Traitement", tabName = "tab_outils",
               icon = icon("arrows-rotate")),
      menuItem('Configuration',
               tabName = 'tab_othaup_sub_configuration',
               icon = icon('wrench')),
      menuItem('À propos',
               tabName = 'tab_othaup_sub_apropos',
               icon = icon('info-circle'))
    ) # Fin de sidebarMenu
  })

  #### Uploads ####
  ## Importation ##
  fichiers_bruts_apres_importation <- reactive({
    req(input$upload_fichiers)
    input$upload_fichiers %>%
      fixUploadedFilesNames() %>%
      select(datapath) %>% 
      pull() %>% 
      map_dfr(chronique.ouverture, Type = "Mesures", typemesure = "Piézométrie", skipvalue = 1, nbcolonnes = 3, separateur_colonnes = ";", separateur_decimales = ".", typefichier = ".csv", typedate = "dmy_hms", typecapteur = "Hobo", nomfichier = T)
  })

  output$fichiers_bruts_apres_importation <- render_gt(fichiers_bruts_apres_importation())
  output$files <- render_gt(fichiers_bruts_apres_importation() %>% distinct(nom_fichier))
  
  #### Données initiales ####
  
}