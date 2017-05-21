# =========================================================
# Using rvest to scrape Linguist List for job trends
# Jesse Harris (jharris AT humnet DOT ucla DOT edu)
# UCLA
# vers. May 20, 2017
# Use as you like, but please just give a shout out if you use this script.
# See README and License for more information.
# =========================================================




################################## SET DATES HERE ##################################
# Set dates to search here:

# Start date cannot be pre-2000. Note also that there are very few job advertisements before 2004.
start = 2004
end = 2016

dates = start:end

# The remainder of the script should run without additional input.
#####################################################################################


# -----------------------------------
# Load libraries
library(magrittr)
library(stringr)
library(rvest)
library(tidyr)
library(ggplot2)
library(gsubfn)



################################## GETTING DATA ##################################
# Create empty data frame
df <- data.frame(year = character(0), html = character(0))
# df

# Select css tag
selector_name = '.issue-msg'

# For loop to download html from Language List by year
for (year in dates) {
	dl <- read_html(paste('http://linguistlist.org/issues/issues-by-topic.cfm?topic=7&y=', year, sep=''))
	temp <- data.frame(year = year, html = html_nodes(x = dl, css = selector_name) %>% html_text())
	df <- rbind(df, temp)
	print(paste('Done with', year))
}

# Convert html to UTF-8 encoding
df$html <- enc2utf8(as.character(df$html))

head(df)


################################## EXTRACTING DATA ##################################


# ----------------------------------
# Convert ampersand space in html of listing
df$html2 <- gsub('   ', '&&', df$html)


# NB. At this point, there may be a few errors. It might be wise to look at resulting file and make adjustments to columns by hand as needed. 

# Correcting errors in the html2 column. 

fixme <- list(
				'Chinese,' = 'Chinese;', 
				'Grammaticalization,' = 'Grammaticalization;', 
				'Morphology,' = 'Morphology;', 				
				'Semantics,' = 'Semantics;', 				
				'Syntax,' = 'Syntax;', 
				'Phonetics,' = 'Phonetics;', 
				'Phonology,' = 'Phonology;',
				'Phonetician,' = 'Phonetician;',					
				'Phonetician,' = 'Phonetician;',				
				'Linguist,' = 'Linguist;',	
				'Language,' = 'Language;', 
				'fMRI,' = 'fMRI;', 								
				'Jobs:' = 'Jobs', 												
				'Language,' = 'Language;',														
				'Typology,' = 'Typology;',
				'Modified:' = 'Modified -', 				
				'Modified Issue:' = 'Modified issue -', 				
				'Modified Re:' = 'Modified Re -', 					
				'chair,' = 'chair',													
				'Morphosyntax,' = 'Morphosyntax;',
				': Syntax,' = '; Syntax;',				
				'Documentation,' = 'Documentation;',
				'; Visiting' = ': Visiting;',				
				'Linguististics,' = 'Linguistics;',
				'Dialectology,' = 'Dialectology;',					
				'Teaching,' = 'Teaching;',
				'Pragmatic,' = 'Pragmatics;',
				'Translation,' = 'Translation;',				
				'Creation,' = 'Creation;',										
				'Hebrew,' = 'Hebrew;',
				'Pragmatics,' = 'Pragmatics;',				
				'Acquisition,' = 'Acquisition;',
				';Assistant' = 'Assistant',				
				'Ling,' = 'Linguistics;',
				'Disorders,' = 'Disorders;',
				'Analysis,' = 'Analysis;',				
				'Languages,' = 'Languages;',
				'Lexiography,' = 'Lexiography;',				
				'Education: Language' = 'Education; Language',			
				'Movement,' = 'Movement;',							
				'Sociolinguistics,' = 'Sociolinguistics;',					
				'Culture,' = 'Culture;',					
				': Computational Linguist;' = ': Computational Linguist,',
				'; Assistant Professor' = ': ;Assistant Professor',	
				'Editor,' = 'Editor;', 
				'Theory,' = 'Theory;', 
				'Theories,' = 'Theories;', 				
 				'Psycholinguistics,' = 'Psycholinguistics;',
				'Variation,' = 'Variation;', 				
				'Neuroscience,' = 'Neuroscience;',				
				'Linguistics,' = 'Linguistics;', 
				'Reasoning,' = 'Reasoning;',				
				'Naming,' = 'Naming;', 
				'Nomenclature,' = 'Nomenclature;',					
				'Logic,' = 'Logic;', 								
				'Asian,' = 'Asian;',
				'Island,' = 'Island;',				
				'English,' = 'English;', 				
				'Spanish,' = 'Spanish;',
				'Arabic,' = 'Arabic;', 				
				'Spanish,' = 'Spanish;',	
				'Russian,' = 'Russian;',					
				'Quichua,' = 'Quichua;',					
				'Gaelic,' = 'Gaelic;',					
				'Farsi,' = 'Farsi;',					
				'Dari,' = 'Dari;',					
				'Tajik,' = 'Tajik;',					
				'French,' = 'French;',					
				'Dutch,' = 'Dutch;',					
				'Japanese,' = 'Japanese;',			
				'Dutch,' = 'Dutch;',					
				'Greek,' = 'Greek;',	
				'Pashto,' = 'Pashto;',									
				'Aramaic,' = 'Aramaic;',				
				'Pashto,' = 'Pashto;',									
				'Saami,' = 'Saami;',					
				'German,' = 'German;'					
			)


# Find and replace with gsubfn
df$html2 <- gsubfn(paste(names(fixme), collapse= '|'),fixme, df$html2)




# ----------------------------------
# String to split posting
# NB. Notes on string splitting:

# Position 1. Before && for contact information
# Position 2: From && until the : lists keywords
# Position 2: After the : lists rank
# Position 3: After the , is the hiring agency (university, corporation, etc.)

# Basic string to split html
string <- paste(c('&&',': ', ', '), collapse = '|')
string

# Use str_split to split sentence and extract columns, fixed = 5 to avoid catching too much material; create new column names.
df$contact <- str_split_fixed(df$html2, string, 5)[,1]
df$keywords <- str_split_fixed(df$html2, string, 5)[,2]
df$rank <- str_split_fixed(df$html2, string, 5)[,3]
df$institution <- str_split_fixed(df$html2, string, 5)[,4]



################################## TENURE TRACK JOBS ##################################

# Collect tenure track positions only
ten <- paste(c('assistant', 'asst', 'open rank', 'any rank'), collapse = '|')
short <- paste(c('visiting', 'term', 'editor', 'acting', 'lecturer', 'scientist', 'junior', 'year', 'post', 'fellow', 'scientific', 'development', 'instructor', 'part', 'curator', 'contract', 'doctoral', 'lab manager', 'sessional', 'teaching assistant', 'program assistant', 'assistant director', 'student', 'predoc',  'prae doc', 'research assistant', 'non-tenure', 'executive assistant', 'lab assistant', 'bank manager', 'adjunct', 'asst director'), collapse = '|')

df.tt <- subset(df, str_detect(tolower(rank), ten) & str_detect(tolower(rank), short) == F)

# List all tenure track ranks
levels(as.factor(df.tt$rank))





################################## SUMMARIZATION ##################################

# -----------------------------
# Fields of interest:

# Method from Language Log post:
# http://languagelog.ldc.upenn.edu/nll/?p=4349

# sociolinguistics: variation, discourse analysis, socio, anthro
# psycholinguistics: psychology, psycholinguistics
# cognitive science: cognition, cognitive
# computational: comp, nlp, natural language processing, machine translation


# TODO: Create acquisition field, separating out L1 and L2 acquisition.

# Phonetics
df.tt$phonetics <- ifelse(str_detect(tolower(df.tt$keywords), 'phonetics'), 1, 0)

# Phonology
df.tt$phonology <- ifelse(str_detect(tolower(df.tt$keywords), 'phonology'), 1, 0)

# Morphology
df.tt$morphology <- ifelse(str_detect(tolower(df.tt$keywords), 'morphology'), 1, 0)

# Syntax
df.tt$syntax <- ifelse(str_detect(tolower(df.tt$keywords), 'syntax'), 1, 0)

# Semantics
df.tt$semantics <- ifelse(str_detect(tolower(df.tt$keywords), 'semantic'), 1, 0)

# Historical
df.tt$historical <- ifelse(str_detect(tolower(df.tt$keywords), paste(c('historical', 'indo'), collapse = '|')), 1, 0)

# Sociolinguistics
df.tt$sociolinguistics <- ifelse(str_detect(tolower(df.tt$keywords), paste(c('variation', 'discourse analysis', 'socio', 'anthro'), collapse = '|')), 1, 0)

# Psycholinguistics (including neuro)
# df.tt$psycholinguistics <- ifelse(str_detect(tolower(df.tt$keywords), 'psycho'), 1, 0)
df.tt$psycholinguistics <- ifelse(str_detect(tolower(df.tt$keywords), paste(c('psycho', 'neuro'), collapse = '|')), 1, 0)

# Acquisition
df.tt$acquisition <- ifelse(str_detect(tolower(df.tt$keywords), 'acquisition'), 1, 0)

# Neurolinguistics
# df.tt$neuroling <- ifelse(str_detect(tolower(df.tt$keywords), 'neuro'), 1, 0)

# Language and cognition
df.tt$langcog <- ifelse(str_detect(tolower(df.tt$keywords), paste(c('cognition', 'cognitive'), collapse = '|')), 1, 0)

# Computational
df.tt$computational <- ifelse(str_detect(tolower(df.tt$keywords), paste(c('comp', 'nlp', 'natural language processing', 'machine translation'), collapse = '|')), 1, 0)




# -----------------------------
# List of all fields
# fields <- c('phonetics', 'phonology', 'morphology', 'syntax', 'semantics', 'historical', 'sociolinguistics', 'psycholinguistics', 'langcog', 'computational', 'acquisition', 'neuroling')

fields <- c('phonetics', 'phonology', 'morphology', 'syntax', 'semantics', 'historical', 'sociolinguistics', 'psycholinguistics', 'langcog', 'computational')

# Summarization by year
tt.year <- as.data.frame(lapply(df.tt[fields], tapply, INDEX = df.tt$year, sum), levels = fields)

# Add year column
tt.year$year <- as.numeric(rownames(tt.year))


# Convert from wide to long format
df.tt.sum <- tt.year %>% gather(field, year)
df.tt.sum$field <- factor(df.tt.sum$field, levels = fields)

colnames(df.tt.sum) <- c('year', 'field', 'jobs')


# Print out number of jobs posted by year:
tot <- with(df.tt.sum, tapply(jobs, list(field, year), sum)); tot


# Print out total number of jobs posted in period:
with(df.tt.sum, tapply(jobs, field, sum))


# Alternative for sanity check
# sapply(df.tt[fields], sum, INDEX = df.tt$fields)



################################## VISUALIZATION ##################################


# Trend lines using ggplot2

trends <- ggplot(df.tt.sum, aes(year, jobs, color = factor(field))) +
geom_point(size = 4) +
geom_line(size = 2) +
scale_x_continuous(breaks = dates) +
scale_color_discrete(name = 'Field') +
ggtitle(paste('Tenure track jobs posted on Linguist List:', start, '-', end)) +
ylim(0, 3 +max(df.tt.sum$jobs)) +
ylab('Number of jobs posted') + xlab('Year') +
theme(plot.title = element_text(size = 22, face = 'bold'), 
		axis.title.x = element_text(size = 16, face = 'italic'),
		axis.title.y = element_text(size = 16, face = 'italic'),
		axis.text = element_text(size = 12),
		legend.title = element_text(size = 16), 
		legend.title.align = .5
)

trends

# Save plot
ggsave(plot=trends, filename= paste('TT_Trends_',start,'-',end,'.pdf',sep = ''), height=8, width=14)


yearly <- ggplot(df.tt.sum, aes(field, jobs)) + geom_boxplot(aes(color = field)) + 
ggtitle(paste('Average yearly tenure track jobs posted on Linguist List:', start, '-', end)) +
ylab('Number of jobs posted') + xlab('Field') +
theme(plot.title = element_text(size = 22, face = 'bold'), 
		axis.title.x = element_text(size = 16, face = 'italic'),
		axis.title.y = element_text(size = 16, face = 'italic'),
		axis.text = element_text(size = 12), 
		legend.position = "none"
#		legend.title = element_text(size = 16), 
#		legend.title.align = .5
)

yearly

# Save plot
ggsave(plot= yearly, filename= paste('TT_Total_',start,'-',end,'.pdf',sep = ''), height=8, width=14)


################################## WRITE DATA ##################################
# Write data to csv files
write.csv(df, paste('All_jobs',start,'-',end,'.csv',sep = ''), fileEncoding = 'UTF-8')
write.csv(df.tt, paste('Tenure_track_jobs',start,'-',end,'.csv',sep = ''), fileEncoding = 'UTF-8')
write.csv(df.tt.sum, paste('Tenure_track_jobs_summary',start,'-',end,'.csv',sep = ''), fileEncoding = 'UTF-8')










