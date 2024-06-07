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

graduateDf <- processDF(graduateDf,"graduate", 82)
intergraduateDf <- processDF(intergraduateDf,"international", 4)
undergraduateDf <- processDF(undergraduateDf,"undergraduate",4)
postdocDf <- processDF(postdocDf,"postdoc",10)

combinedDF <- rbind(graduateDf, intergraduateDf, undergraduateDf, postdocDf)

# combinedDF$id <- paste(rownames(combinedDF), combinedDF$cat)

# 3 application were retracted by applicants
missingApplication <- merge(combinedDF, recommendation_2024, by = c('student email','advisor email'), all.y = TRUE)
missingApplication <- missingApplication[is.na(missingApplication$`student name`),]


missingRecommendation <- combinedDF[is.na(combinedDF$student_name_recommendation),]

tableColumnNames <- c("selected", "student email","advisor email" ,"student affiliation", "phd years", "num workshop","advisor name","inneed","tutorial", "rep","student wholeweek","randomNumberGenerated")

					

# sheet_write(combinedDF[is.na(combinedDF[combinedDF$student_name_recommendation,]),], ss = googleSheetId2024, sheet = "Decisions")

write.csv(combinedDF[,c("id",	"cat"	,"selected",	"student email"	,"advisor email",		"student name"	,"student affiliation",	"student country"	,"student pronouns",	"student degree program",	"phd years",	"num workshop",	"advisor name",	"student tutorial talk"	,"student day"	,"student poster"	,"student wholeweek",	"student pref roommate"	,"student accommodations",	"student_name_recommendation"	,"advisor_name_recommendation"	,"inneed",	"tutorial",	"rep",	"randomNumberGenerated"		)], file = "combinedDF.csv", row.names = FALSE)

# rm(recommendation_2024, tutorial_2024, rep_2024 )


