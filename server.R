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
  # Vérification des formats
  sessions <- reactive({
    req(input$upload_fichiers)
    # 
    # ext <- tools::file_ext(input$upload_fichiers$name)
    # switch(ext,
    #        csv = input$upload$datapath %>% map_dfr(chronique.ouverture, Type = "Mesures", typemesure = "Piézométrie", skipvalue = 1, nbcolonnes = 3, separateur_colonnes = ";", separateur_decimales = ".", typefichier = ".csv", typedate = "dmy_hms", typecapteur = "Hobo", nomfichier = T),
    #        txt = input$upload$datapath %>% map_dfr(chronique.ouverture, Type = "Mesures", typemesure = "Piézométrie", skipvalue = 1, nbcolonnes = 3, separateur_colonnes = ";", separateur_decimales = ".", typefichier = ".csv", typedate = "dmy_hms", typecapteur = "Hobo", nomfichier = T),
    #        validate("Fichier invalide - Merci de charger un fichier .csv ou .txt")
    # )
    
    ## Renommage des fichiers avec leur nom original, car ils sont stockés localement avec un nom aléatoire
    # from <- input$upload_fichiers$datapath
    # to <- file.path(dirname(from), basename(input$upload_fichiers$name))
    # file.rename(from, to)
    
    # from <- input$upload_fichiers[['datapath']]
    # to <- file.path(dirname(from), basename(input$upload_fichiers[['name']]))
    # file.rename(from, to)
    
    input$upload_fichiers %>% 
      fixUploadedFilesNames() %>% 
      select(datapath) %>% 
    # input$upload_fichiers$datapath %>% 
      map_dfr(chronique.ouverture, Type = "Mesures", typemesure = "Piézométrie", skipvalue = 1, nbcolonnes = 3, separateur_colonnes = ";", separateur_decimales = ".", typefichier = ".csv", typedate = "dmy_hms", typecapteur = "Hobo", nomfichier = T)
           # txt = input$upload$datapath %>% map_dfr(chronique.ouverture, Type = "Mesures", typemesure = "Piézométrie", skipvalue = 1, nbcolonnes = 3, separateur_colonnes = ";", separateur_decimales = ".", typefichier = ".csv", typedate = "dmy_hms", typecapteur = "Hobo", nomfichier = T),
           # validate("Fichier invalide - Merci de charger un fichier .csv ou .txt")
    # )
  })
  
  # output$files <- DT::renderDT({
  # output$files <- renderTable({
  #   req(input$upload_fichiers)
  #   # DT::datatable(sessions(), selection = c("single"))
  #   sessions()
  # })
  
  output$files <- render_gt(expr = sessions())
  
  #### Données initiales ####
  
}