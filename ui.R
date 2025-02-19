# Application Shiny Anki

library(aquatools)
library(afd39)
library(dplyr)
library(glue)
library(gt)
library(lubridate)
library(shiny)
library(shinydashboard)
library(stringr)
library(tibble)

#### Éléments à afficher ####
url_mail_perso <- a("Jean-Baptiste Fagot", href="mailto:jean-baptiste.fagot@peche-jura.com")

# Define UI for application that draws a histogram
ui <- dashboardPage(
  dashboardHeader(
    title = "OTHAUP"
  ),
  
  # setup a sidebar menu to be rendered server-side
  dashboardSidebar(
    collapsed = TRUE, 
    sidebarMenuOutput("sidebar")
  ),
  
  dashboardBody(
    tabItems(
      tabItem("tab_outils", 
              titlePanel("OTHAUP - Outils de Traitement des HAUteurs d'eau Piézométriques"),
              ## Upload des données ##
              tags$h3(tagList("Chargement des données")),
              fluidRow(
                column(width = 6,
                       box(width = NULL,
                           fileInput("upload_fichiers", "Chargement des fichiers", 
                                     multiple = TRUE,
                                     accept = c(".csv", ".txt"),
                                     buttonLabel = "Sélectionner...",
                                     placeholder = "Aucun fichier sélectionné")
                       )
                )
              ), # Fin de fluidRow
                tableOutput("fichiers_bruts_apres_importation_contexte"),
                tableOutput("fichiers_propres_apres_importation_contexte"),
                tableOutput("files"),
                tableOutput("fichiers_bruts_apres_importation"),
                tableOutput("fichiers_propres_apres_importation"),
                tableOutput("fichiers_propres_apres_importation_test"),
                downloadButton("download_data", "Télécharger le résultat")
      ), # Fin de tabItem
              ## Configuration ##
      tabItem("tab_othaup_sub_configuration",
              ## Titre ##
              titlePanel("OTHAUP - Configuration"),
              fluidRow(
                column(width = 3, selectInput("param_ouverture_piezo_type", "Type de données", list("Mesures" = "Mesures"))),
                column(width = 3, selectInput("param_ouverture_piezo_typemesure", "Type de mesures", list("Piézométrie" = "Piézométrie", "Thermie" = "Thermie"))),
                ), # Fermeture de fluidRow
                fluidRow(
                column(width = 3, numericInput("param_ouverture_piezo_skipvalue", label = "Nombre de lignes à ignorer", value = 1)),
                column(width = 3, numericInput("param_ouverture_piezo_nbcolonnes", label = "Nombre de colonnes", value = 3)),
                column(width = 3, textInput("param_ouverture_piezo_separateur_colonnes", label = "Séparateur de colonnes", value = ";")),
                column(width = 3, textInput("param_ouverture_piezo_separateur_decimales", label = "Séparateur de décimales", value = "."))
                ), # Fermeture de fluidRow
                fluidRow(
                  column(width = 3, selectInput("param_ouverture_piezo_typedate", label = "Format de date", list("dmy_hms" = "dmy_hms", "ymd_hms" = "ymd_hms")))
                ) # Fermeture de fluidRow
              ), # Fin de tabItem              ## Notice ##
              tabItem("tab_othaup_sub_notice",
                titlePanel("OTHAUP - Notice d'utilisation"),
                includeMarkdown("REFS.md")
              ), # Fin de tabItem
              tabItem("tab_othaup_sub_apropos", 
                      titlePanel("OTHAUP - À propos"),
                      includeMarkdown("NEWS.md")
              ) # Fin de tabItem
      ), # fin de tabItems
      
    # Bas de page de tous les tabItems
    fluidRow( # à rétablir mais fait planter l'application sans que je ne sache pourquoi
      column(
        width = 12,
        h5(tagList("Version 0.0.6 de l'application, déployée le 18/02/2025 par ", url_mail_perso))

      ) # Fermeture de column
    ) # Fermeture de fluidRow
  ) # fin de dashboardBody
) # fin de dashboardPage
