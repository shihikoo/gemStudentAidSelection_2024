source('configure.R')
source('functions.R')

gs4_deauth()

list[graduateDf, intergraduateDf, undergraduateDf, postdocDf] <- clean_submission_2024(googlesheets4::read_sheet(googleSheetId2024, sheet = "submission"))

recommendation_2024 <- clean_recommendation_2024(googlesheets4::read_sheet(googleSheetId2024, sheet = "recommendation"))
tutorial_2024 <- clean_tutorial_2024(googlesheets4::read_sheet(googleSheetId2024, sheet = "tutorial"))
rep_2024 <- clean_rep_2024(googlesheets4::read_sheet(googleSheetId2024, sheet = "student rep"))

graduateDf <- merge(merge(merge(graduateDf, recommendation_2024, by = c('student email','advisor email'), all.x = TRUE), tutorial_2024, by = 'student email' , all.x = TRUE), rep_2024, by = 'student email' , all.x = TRUE) 

intergraduateDf <- merge(merge(merge(intergraduateDf, recommendation_2024, by = c('student email','advisor email'), all.x = TRUE), tutorial_2024, by = 'student email' , all.x = TRUE), rep_2024, by = 'student email' , all.x = TRUE) 

undergraduateDf <- merge(merge(merge(undergraduateDf, recommendation_2024, by = c('student email','advisor email'), all.x = TRUE), tutorial_2024, by = 'student email' , all.x = TRUE), rep_2024, by = 'student email' , all.x = TRUE) 

postdocDf <- merge(merge(merge(postdocDf, recommendation_2024, by = c('student email','advisor email'), all.x = TRUE), tutorial_2024, by = 'student email' , all.x = TRUE), rep_2024, by = 'student email' , all.x = TRUE) 

graduateDf <- processDF(graduateDf,"graduate", 84)
intergraduateDf <- processDF(intergraduateDf,"international", 4)
undergraduateDf <- processDF(undergraduateDf,"undergraduate",4)
postdocDf <- processDF(postdocDf,"postdoc",10)

combinedDF <- rbind(graduateDf, intergraduateDf, undergraduateDf, postdocDf)

missingApplication <- merge(combinedDF, recommendation_2024, by = c('student email','advisor email'), all.y = TRUE)
missingApplication <- missingApplication[is.na(missingApplication$`student name`),]

missingRecommendation <- combinedDF[is.na(combinedDF$student_name_recommendation),]

tableColumnNames <- c("student email","advisor email" ,"student affiliation", "phd years", "num workshop","advisor name","inneed","tutorial", "rep","student wholeweek","randomNumberGenerated","selected")

# sheet_write(combinedDF[is.na(combinedDF[combinedDF$student_name_recommendation,]),], ss = googleSheetId2024, sheet = "Decisions")

# write.csv2(combinedDF)

rm(recommendation_2024, tutorial_2024, rep_2024 )


