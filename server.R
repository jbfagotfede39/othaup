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
library(readr)
# library(readxl)
# library(scales)
# library(sf)
library(shiny)
library(stringr)
# library(tibble)
library(tidyr)

downloadButton <- function(...) {
  tag <- shiny::downloadButton(...)
  tag$attribs$download <- NULL
  tag
}

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
      menuItem('Notice',
               tabName = 'tab_othaup_sub_notice',
               icon = icon('book-open-reader')),
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
      map_dfr(chronique.ouverture, Type = input$param_ouverture_piezo_type, typemesure = input$param_ouverture_piezo_typemesure, skipvalue = input$param_ouverture_piezo_skipvalue, nbcolonnes = input$param_ouverture_piezo_nbcolonnes, separateur_colonnes = input$param_ouverture_piezo_separateur_colonnes, separateur_decimales = input$param_ouverture_piezo_separateur_decimales, typefichier = ".csv", typedate = input$param_ouverture_piezo_typedate, typecapteur = "Hobo", nomfichier = T)
  })

  #### Nettoyage ####
  fichiers_propres_apres_importation <- reactive({
    req(input$upload_fichiers)
    fichiers_bruts_apres_importation() %>%
      separate(nom_fichier, c("chmes_coderhj", "nom_fichier"), sep = "_", ) %>%  # Ajout du code station à partir du nom de fichier
      select(chmes_coderhj, contains("chmes_capteur"), chmes_date, chmes_heure, chmes_valeur, chmes_unite, chmes_typemesure) %>% 
      distinct()# Dédoublonnage
  })
  
  #### Séparation thermie/piézo ####
  thermie <- reactive({
    req(input$upload_fichiers)
    fichiers_propres_apres_importation() %>%
      filter(grepl("hermi", chmes_typemesure))
    })
  
  piezo <- reactive({
    req(input$upload_fichiers)
    fichiers_propres_apres_importation() %>%
      filter(!grepl("hermi", chmes_typemesure))
    })

  #### Calcul ####
  donnees_compensees <- reactive({
    req(input$upload_fichiers)
    piezo() %>%
      chronique.compensation.barometrie(modalite_rattachement = input$param_compensation_modalite_rattachement, duree_max_rattachement = input$param_compensation_duree_max_rattachement, sortie = "compensé") %>% 
      select(-id, -chmes_validation, -chmes_mode_acquisition)
  })
  donnees_compensees_avec_vide <- reactive({
    req(input$upload_fichiers)
    piezo() %>%
      chronique.compensation.barometrie(modalite_rattachement = input$param_compensation_modalite_rattachement, duree_max_rattachement = input$param_compensation_duree_max_rattachement, sortie = "compensé_avec_vide") %>% 
      select(-id, -chmes_validation, -chmes_mode_acquisition)
  })
  donnees_compensees_tout <- reactive({
    req(input$upload_fichiers)
    piezo() %>%
      chronique.compensation.barometrie(modalite_rattachement = input$param_compensation_modalite_rattachement, duree_max_rattachement = input$param_compensation_duree_max_rattachement, sortie = "tout") %>% 
      select(-id, -chmes_validation, -chmes_mode_acquisition)
  })
  donnees_compensees_large <- reactive({
    req(input$upload_fichiers)
    piezo() %>%
      chronique.compensation.barometrie(modalite_rattachement = input$param_compensation_modalite_rattachement, duree_max_rattachement = input$param_compensation_duree_max_rattachement, sortie = "large")
  })
  
  #### Regroupement thermie/piézo ####
  regroupement <- reactive({
    req(input$upload_fichiers)
    donnees_compensees_tout() %>%
      union(thermie()) %>% 
      arrange(chmes_coderhj, chmes_date, chmes_heure, chmes_typemesure, chmes_unite)
  })
  
  #### Contexte ####
  fichiers_bruts_apres_importation_contexte <- reactive({
    req(input$upload_fichiers)
    fichiers_bruts_apres_importation() %>%
      chronique.contexte()
  })
  
  fichiers_propres_apres_importation_contexte <- reactive({
    req(input$upload_fichiers)
    fichiers_propres_apres_importation() %>%
      chronique.contexte()
  })
    
  donnees_compensees_contexte <- reactive({
    req(input$upload_fichiers)
    donnees_compensees() %>%
      chronique.contexte()
  })
    
  donnees_compensees_avec_vide_contexte <- reactive({
    req(input$upload_fichiers)
    donnees_compensees_avec_vide() %>%
      chronique.contexte()
  })
    
  donnees_compensees_tout_contexte <- reactive({
    req(input$upload_fichiers)
    donnees_compensees_tout() %>%
      chronique.contexte()
  })
    
  donnees_compensees_large_contexte <- reactive({
    req(input$upload_fichiers)
    donnees_compensees_large() %>%
      chronique.contexte()
  })
      
  regroupement_contexte <- reactive({
    req(input$upload_fichiers)
    regroupement() %>%
      chronique.contexte()
  })
  
  
  #### Affichage ####
  # output$fichiers_bruts_apres_importation <- render_gt(fichiers_bruts_apres_importation() %>% filter(grepl("gouterot", nom_fichier)) %>% head())
  # output$fichiers_propres_apres_importation <- render_gt(fichiers_propres_apres_importation() %>% filter(grepl("gouterot", chmes_coderhj)) %>% head())
  # output$fichiers_propres_apres_importation_test <- render_gt(fichiers_propres_apres_importation() %>% filter(grepl("porf", chmes_coderhj)) %>% head())
  # output$files <- render_gt(fichiers_bruts_apres_importation() %>% distinct(nom_fichier))
  # output$fichiers_bruts_apres_importation_contexte <- render_gt(fichiers_bruts_apres_importation_contexte())
  # output$fichiers_propres_apres_importation_contexte <- render_gt(fichiers_propres_apres_importation_contexte())
  # output$donnees_compensees_tout_contexte <- render_gt(donnees_compensees_tout_contexte())
  output$thermie <- render_gt(thermie() %>% head())
  output$piezo <- render_gt(piezo() %>% head())
  output$donnees_compensees_tout <- render_gt(donnees_compensees_tout() %>% head())

  #### Téléchargement ####
  # Format long
  output$download_data_long <- downloadHandler(
    filename = function(){
      glue("{format(now(), format='%Y-%m-%d_%H:%M:%S')}_Regroupement_long_{fichiers_propres_apres_importation_contexte()$station}_{fichiers_propres_apres_importation_contexte()$annee}.csv") %>% str_replace_all(";", "-")
    },
    content = function(file) {
      # write_csv2(fichiers_propres_apres_importation(), file)
      write_csv2(donnees_compensees_tout(), file)
    }
  )
  
  # Format large
  output$download_data_large <- downloadHandler(
    filename = function(){
      glue("{format(now(), format='%Y-%m-%d_%H:%M:%S')}_Regroupement_large_{fichiers_propres_apres_importation_contexte()$station}_{fichiers_propres_apres_importation_contexte()$annee}.csv") %>% str_replace_all(";", "-")
    },
    content = function(file) {
      # write_csv2(fichiers_propres_apres_importation(), file)
      write_csv2(donnees_compensees_large(), file)
    }
  )

}