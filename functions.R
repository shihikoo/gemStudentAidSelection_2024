library(googlesheets4)
library(shiny)
library(shinydashboard)
library(DT)
library(dplyr)
library(data.table)
library(plotly)
library(shinythemes)
library(tidyr)
library(stats)
library(gsubfn)

clean_submission_2024 <- function(df2024_submission){
  colnames(df2024_submission) <- tolower(colnames(df2024_submission))
  colnames(df2024_submission) <- gsub('-', ' ', colnames(df2024_submission))
  
  df2024_submission <- df2024_submission[df2024_submission$status != "delete",]
  df2024_submission$duplicate <- duplicated(df2024_submission$`student email`)
  if (sum(df2024_submission$duplicate) > 0) {
    print("Duplicated entry found.")
    print(df2024_submission[df2024_submission$duplicate, ])
  }
  df2024_submission$`student email` <- tolower(df2024_submission$`student email`)

  df2024_submission$`student pronouns`[df2024_submission$`student pronouns` == 'other'] <- df2024_submission$`pronouns other`[df2024_submission$`student pronouns` == 'other']
  
  df2024_submission$us <- df2024_submission$`student country` == "United States" | df2024_submission$`student country` == "United State" | df2024_submission$`student country` == "USA"| df2024_submission$`student country` == "US" | df2024_submission$`student country` == "United States of America"
  
  df2024_submission$`student country`[df2024_submission$us]='USA'
  
  df2024_submission$`phd years` = sapply(df2024_submission$`phd years`, unlist)
  df2024_submission$`num workshop` = sapply(df2024_submission$`num workshop`, unlist)
  
  df2024_submission$id <- rownames(df2024_submission)
  
  graduateDf <- df2024_submission[(df2024_submission$`student degree program` == "PhD" | df2024_submission$`student degree program` == "Master's") & df2024_submission$us, ] 
  
  intergraduateDf <- df2024_submission[(df2024_submission$`student degree program` == "PhD" | df2024_submission$`student degree program` == "Master's") & !df2024_submission$us, ] 
  
  undergraduateDf <- df2024_submission[(df2024_submission$`student degree program` == "Undergraduate"), ] 
  
  postdocDf <- df2024_submission[(df2024_submission$`student degree program` == "Post Doc or Early Career (PhD + 3 yrs)"), ] 
  
  output_columns_names <- c("id","student name","student email" ,"student affiliation","student country","student pronouns", "student degree program", "phd years" , "num workshop","advisor name","advisor email","student tutorial talk","student day","student poster", "student wholeweek", "student pref roommate","student accommodations")
  
  return(list(graduateDf[,output_columns_names], intergraduateDf[,output_columns_names], undergraduateDf[,output_columns_names], postdocDf[,output_columns_names]) )
}

clean_recommendation_2024 <- function(df2024_recommendation){
  colnames(df2024_recommendation) <- tolower(colnames(df2024_recommendation))
  colnames(df2024_recommendation) <- gsub('-', ' ', colnames(df2024_recommendation))
  
  df2024_recommendation[is.na(df2024_recommendation$status),'status'] <- "Current"
  df2024_recommendation <- df2024_recommendation[df2024_recommendation$status != "delete",]
  df2024_recommendation <- df2024_recommendation[!is.na(df2024_recommendation$`student email`),]
  
  df2024_recommendation <- df2024_recommendation[df2024_recommendation$`recommend`== 'Yes' ,]
  df2024_recommendation <- df2024_recommendation[df2024_recommendation$`aware fee`== 'Yes' ,]

  
  df2024_recommendation$duplicate <- duplicated(df2024_recommendation$`student email`)
  if (sum(df2024_recommendation$duplicate) > 0) {
    print("Duplicated entry found.")
    print(df2024_recommendation[df2024_recommendation$duplicate, ])
    df2024_recommendation <- df2024_recommendation[!df2024_recommendation$duplicate,]
    } 
  df2024_recommendation$student_name_recommendation <- df2024_recommendation$`student name`
  df2024_recommendation$advisor_name_recommendation <- df2024_recommendation$`advisor name`
  df2024_recommendation$`student email` <- tolower(df2024_recommendation$`student email`)
  
  output_columns_names <- c('student email','advisor email','student_name_recommendation','advisor_name_recommendation','inneed')
  
  return(df2024_recommendation[, output_columns_names])
}

clean_tutorial_2024 <- function(df2024_tutorial){
  df2024_tutorial$`student email` <- tolower(df2024_tutorial$`student email`)
  
  df2024_tutorial[,c("student email","tutorial")]
}

clean_rep_2024 <- function(df2024_rep){
  df2024_rep$`student email` <- tolower(df2024_rep$`student email`)
  
  df2024_rep[,c("student email","rep")]
}

selectionRun <- function(x) {
  return(runif(1,min=0.3*(x=='zero'),max=1)) 
}

processDF <- function(graduateDf, category, selectionNum){
  graduateDf$cat <- category
  
  graduateDf$randomNumberGenerated <- sapply(graduateDf$`num workshop`, selectionRun)
  
  graduateDf$randomNumberGenerated[!is.na(graduateDf$inneed) & graduateDf$inneed == "Yes"] = graduateDf$randomNumberGenerated[!is.na(graduateDf$inneed) & graduateDf$inneed == "Yes"] + 1
  
  graduateDf$randomNumberGenerated[graduateDf$`student wholeweek` == "No"] = 0
  
  graduateDf$randomNumberGenerated[!is.na(graduateDf$tutorial) & graduateDf$tutorial == "Yes"] = 2
  graduateDf$randomNumberGenerated[!is.na(graduateDf$rep) & graduateDf$rep == "Yes"] = 2
  
  # invalid application
  graduateDf$randomNumberGenerated[is.na(graduateDf$student_name_recommendation)] = -999
  graduateDf$randomNumberGenerated[graduateDf$`student day` == "No"] = -999
  graduateDf$randomNumberGenerated[graduateDf$`student poster` == "No"] = -999
  
  graduateDf <- graduateDf[order(graduateDf$randomNumberGenerated, decreasing = TRUE),]
  
  graduateDf$selected <- FALSE
  graduateDf$selected[1:selectionNum] <- TRUE 
  graduateDf$selected[graduateDf$randomNumberGenerated == -999] <- FALSE
  
  return(graduateDf)
}

remove_invalid <- function(graduateDf) {
    graduateDf <- graduateDf[-c(!graduateDf$randomNumberGenerated == -999),]
}


