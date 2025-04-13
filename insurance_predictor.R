# Simple Insurance Charges Prediction Shiny App
# Load required libraries
library(shiny)       # For building interactive web apps
library(dplyr)       # For data manipulation
library(ggplot2)     # For data visualization

# Define the user interface (UI)
ui <- fluidPage(
  titlePanel("Insurance Charges Prediction"),
  
  # Create a sidebar layout with input controls
  sidebarLayout(
    sidebarPanel(
      # User inputs
      numericInput("age", "Age:", 30, min = 18, max = 100),
      selectInput("sex", "Sex:", choices = c("male", "female")),
      numericInput("bmi", "BMI:", 25, min = 10, max = 50),
      numericInput("children", "Number of Children:", 0, min = 0, max = 10),
      radioButtons("smoker", "Smoker:", choices = c("yes", "no")),
      selectInput("region", "Region:", 
                  choices = c("northeast", "northwest", "southeast", "southwest")),
      actionButton("predict", "Predict Charges", class = "btn-success")
    ),
    
    # Main panel with tabs for prediction and data visualization
    mainPanel(
      tabsetPanel(
        # First tab: Prediction results
        tabPanel("Prediction", 
                 h3("Your Estimated Insurance Charges:"),
                 textOutput("prediction_result"),
                 br(),
                 h4("Key Factors Affecting Insurance Charges:"),
                 verbatimTextOutput("model_summary")
        ),
        
        # Second tab: Data exploration
        tabPanel("Data Exploration",
                 plotOutput("age_plot"),
                 plotOutput("smoker_plot")
        )
      )
    )
  )
)

# Define the server logic
server <- function(input, output) {
  
  # Step 1: Load and clean the data
  insurance_data <- reactive({
    # Load the dataset (with a backup if file not found)
    tryCatch({
      df <- read.csv("insurance.csv")
    }, error = function(e) {
      # Create sample data if file isn't found
      df <- data.frame(
        age = c(19, 33, 60, 36, 52, 38),
        sex = c("female", "male", "female", "male", "female", "male"),
        bmi = c(27.9, 22.7, 25.8, 30.3, 32.4, 26.3),
        children = c(0, 2, 1, 3, 0, 1),
        smoker = c("yes", "no", "no", "yes", "no", "yes"),
        region = c("southwest", "northwest", "southeast", "northeast", "northwest", "northeast"),
        charges = c(16884.92, 3866.86, 11380.64, 21976.28, 10600.55, 29523.17)
      )
    })
    
    # Remove any missing values
    df <- na.omit(df)
    
    # Make sure region and sex are standardized
    df$region <- tolower(df$region)
    df$sex <- tolower(df$sex)
    
    # Make sure charges is numeric
    if(is.character(df$charges)) {
      df$charges <- as.numeric(gsub("\\$", "", df$charges))
    }
    
    return(df)
  })
  
  # Step 2: Create the prediction model
  insurance_model <- reactive({
    # Get clean data
    df <- insurance_data()
    
    # Prepare data for modeling (convert categorical variables to numeric)
    df_model <- df %>%
      mutate(
        is_male = ifelse(sex == "male", 1, 0),
        is_smoker = ifelse(smoker == "yes", 1, 0),
        region_northeast = ifelse(region == "northeast", 1, 0),
        region_northwest = ifelse(region == "northwest", 1, 0),
        region_southwest = ifelse(region == "southwest", 1, 0)
      )
    
    # Train a linear regression model
    model <- lm(charges ~ age + bmi + children + is_male + is_smoker + 
                  region_northeast + region_northwest + region_southwest, 
                data = df_model)
    
    return(model)
  })
  
  # Step 3: Make prediction when button is clicked
  prediction <- eventReactive(input$predict, {
    # Get model
    model <- insurance_model()
    
    # Create data from user inputs
    new_data <- data.frame(
      age = input$age,
      bmi = input$bmi,
      children = input$children,
      is_male = ifelse(input$sex == "male", 1, 0),
      is_smoker = ifelse(input$smoker == "yes", 1, 0),
      region_northeast = ifelse(input$region == "northeast", 1, 0),
      region_northwest = ifelse(input$region == "northwest", 1, 0),
      region_southwest = ifelse(input$region == "southwest", 1, 0)
    )
    
    # Make prediction
    predicted_value <- predict(model, newdata = new_data)
    
    # Make sure prediction isn't negative
    return(max(0, predicted_value))
  })
  
  # Step 4: Display prediction result
  output$prediction_result <- renderText({
    if(input$predict == 0) {
      return("Click the 'Predict Charges' button to see your estimated insurance cost")
    }
    
    # Format the prediction nicely
    paste0("$", format(round(prediction(), 2), big.mark = ",", nsmall = 2))
  })
  
  # Step 5: Show model summary
  output$model_summary <- renderPrint({
    if(input$predict == 0) {
      return("Click the 'Predict Charges' button to see model information")
    }
    
    # Get coefficients to explain the model
    coefs <- coef(insurance_model())
    
    # Print the key factors
    cat("Most important factors affecting insurance cost:\n\n")
    
    if(coefs["is_smoker"] > 0) {
      cat("1. Smoking status: Being a smoker increases costs by about $", 
          round(coefs["is_smoker"]), "\n")
    }
    
    if(coefs["age"] > 0) {
      cat("2. Age: Each additional year increases costs by about $", 
          round(coefs["age"]), "\n")
    }
    
    if(coefs["bmi"] > 0) {
      cat("3. BMI: Each additional BMI point increases costs by about $", 
          round(coefs["bmi"]), "\n")
    }
    
    if(coefs["children"] > 0) {
      cat("4. Children: Each additional child increases costs by about $", 
          round(coefs["children"]), "\n")
    }
  })
  
  # Step 6: Create visualization for age
  output$age_plot <- renderPlot({
    df <- insurance_data()
    
    ggplot(df, aes(x = age, y = charges, color = smoker)) +
      geom_point(alpha = 0.6) +
      geom_smooth(method = "lm") +
      labs(title = "How Age Affects Insurance Charges", 
           x = "Age", y = "Charges ($)") +
      theme_minimal()
  })
  
  # Step 7: Create visualization for smoker
  output$smoker_plot <- renderPlot({
    df <- insurance_data()
    
    ggplot(df, aes(x = smoker, y = charges, fill = smoker)) +
      geom_boxplot() +
      labs(title = "Impact of Smoking on Insurance Charges", 
           x = "Smoker", y = "Charges ($)") +
      theme_minimal()
  })
}

# Run the application
shinyApp(ui = ui, server = server)