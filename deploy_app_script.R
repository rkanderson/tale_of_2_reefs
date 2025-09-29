library(rsconnect)

rsconnect::deployApp(
  appDir = "shinyapp",  # folder containing app.R
  appName = "tale_of_2_reefs"     # the name you want on shinyapps.io
)