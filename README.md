# linglist-scrape
Author: Jesse Harris
Created: January 15, 2018
Updated: September 12, 2020

Description: An R Markdown script to scrape Linguist List for tenure track job information.

## Purpose
This R Markdown script downloads the Linguist List job posting [archives](http://linguistlist.org/jobs/browse-previous-jobs2.cfm) from 2004. After some reformatting, it removes all but tenure track job postings and categorizes the jobs according to keywords listed in the posting. The method for categorization largely follows previous efforts by Chris Potts, Heidi Harley, Stephanie Shih, and Rebecca Starr (see the Language Log postings on the [2008 data](http://languagelog.ldc.upenn.edu/nll/?p=1067), [2009 data](http://languagelog.ldc.upenn.edu/nll/?p=1491), and [2009-2012 data](http://languagelog.ldc.upenn.edu/nll/?p=4349)).


## Data collection

The script is heavily annotated, but assumes a working knowledge of R and R Markdown. The range can be adjusted by modifying the values for the *start* and *end* dates in the script.


## Output

Two kinds of files are produced by the script: data files in csv format, and plots in pdf format. The script produces three csv files with data from the period of interest:

1. All the jobs data after post-processing (including the original job listing),
2. All the tenure track jobs in the fields of interest, and
3. A basic summary of the number of jobs listed per year in each field.




## Attribution
This is work in progress. Use the code as you like, but please just give a [shout out](https://jesseharris.netlify.app/) if you use this script.  **Comments are most welcome!**

The script is maintained on a githib repository [here](https://github.com/jaharris/linglist-scrape).
