# Insurance Charges Prediction

An interactive Shiny application that predicts health insurance costs based on individual characteristics.

## Overview

This project uses machine learning to predict annual health insurance charges based on personal factors like age, BMI, smoking status, and more. The app provides both prediction functionality and data visualizations to help users understand what drives insurance costs.

<img src="assets/Model%20Prediction%20UI.png" alt="Model Prediction UI" width="800" style="border: 2px solid black;">

## Dataset

The analysis uses the `insurance.csv` dataset which contains the following variables:
- **age**: Age of the primary beneficiary
- **sex**: Gender of the primary beneficiary
- **bmi**: Body Mass Index (weight in kg / height in m²)
- **children**: Number of children/dependents covered
- **smoker**: Smoking status (yes/no)
- **region**: Residential area in the US (northeast, northwest, southeast, southwest)
- **charges**: Annual medical costs billed by health insurance

## Features

- **Interactive Prediction**: Enter personal information to get an estimated insurance cost
- **Data Visualization**: Explore the relationships between different factors and insurance costs
- **Model Explanation**: See which factors have the biggest impact on insurance charges

## Analysis Highlights

### 1. Age vs. Insurance Charges
<img src="assets/Data%20Visualization.png" alt="Smoking Impact" width="600" style="border: 2px solid black;">

Age shows a positive correlation with insurance charges, with costs steadily increasing as people get older. The effect is more pronounced for smokers, who show a steeper increase in costs with age.

### 2. Impact of Smoking

Smoking is the single most significant factor affecting insurance costs. The visualization clearly demonstrates smokers pay approximately 3-4 times more than non-smokers with otherwise similar characteristics.

### 3. Model Results
The linear regression model reveals the following key relationships:
- Being a smoker increases costs by approximately $24,000 annually
- Each year of age adds about $250 to annual costs
- Each point increase in BMI adds roughly $340 to annual costs
- Each additional dependent child increases costs by about $480

## Implementation Details

The application is built using:
- **R** programming language
- **Shiny** for interactive web interface
- **ggplot2** for data visualization
- Linear regression for predictive modeling

## Usage

To run the application locally:
1. Clone this repository
2. Ensure R is installed with required packages
3. Run the app with `shiny::runApp()`

## Future Work

Potential improvements include:
- Implementing more advanced prediction algorithms
- Adding confidence intervals to predictions
- Expanding the dataset with more recent information
- Adding more interactive visualizations
