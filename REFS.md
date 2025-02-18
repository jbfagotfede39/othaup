## Règles générales ##
- Les données d'une unique station barométrique doivent être fournies, avec les données relatives à l'ensemble des stations piézométriques rattachées
- Il est actuellement considéré que les données à traiter sont :
  * dans les mêmes unités de hauteur d'eau (`kPa`, `cm H2O`, etc.)
  * dans le même fuseau horaire

## Nommage des fichiers
- Le nom des fichiers doit démarrer par le nom de la station, séparé du reste du nom du fichier par un `underscore` (`_`) : `CdM_Piezo2_2024-11-25.csv` pour la station `CdM`
- Le nom de station barométrique doit contenir la chaîne de caractères `baro` à un endroit du nom du fichier : `CdMb_baro2_2024-11-25` par exemple
- Les noms des stations piézométriques doivent contenir la chaîne de caractères `piezo` à un endroit du nom du fichier : `CdM_Piezo2_2024-11-25` par exemple
- Les noms de stations barométriques et piézométriques doivent être différents : `CdM_Piezo2_2024-11-25` et `CdMb_baro2_2024-11-25` par exemple

## Paramètres de configuration ##
- `param_ouverture_piezo_type` : type de données à importer (`Mesures`)
- `param_ouverture_piezo_typemesure` : type de mesures à traiter (`Piézométrie`, `Thermie`, etc.)
- `param_ouverture_piezo_skipvalue` : nombre de lignes à ignorer
- `param_ouverture_piezo_nbcolonnes` : nombre de colonnes dans les fichiers à traiter
- `param_ouverture_piezo_separateur_colonnes` : séparateur de colonnes (`;`, `,`)
- `param_ouverture_piezo_separateur_decimales` : séparateur de décimales (`,`, `.`)
- `param_ouverture_piezo_typedate` : format de date (`dmy_hms`, `ymd_hms`)
