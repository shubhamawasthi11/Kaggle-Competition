

## File Descriptions

The data provided is split into two files:

NYTimesBlogTrain.csv = the training data set. It consists of 6532 articles.
NYTimesBlogTest.csv = the testing data set. It consists of 1870 articles.  

## Variable Descriptions

The dependent variable in this problem is the variable Popular, which labels if an article had 25 or more comments in its online comment section (equal to 1 if it did, and 0 if it did not). The dependent variable is provided in the training data set, but not the testing dataset.

The independent variables consist of 8 pieces of article data available at the time of publication, and a unique identifier:

NewsDesk = the New York Times desk that produced the story (Business, Culture, Foreign, etc.)
SectionName = the section the article appeared in (Opinion, Arts, Technology, etc.)
SubsectionName = the subsection the article appeared in (Education, Small Business, Room for Debate, etc.)
Headline = the title of the article
Snippet = a small portion of the article text
Abstract = a summary of the blog article, written by the New York Times
WordCount = the number of words in the article
PubDate = the publication date, in the format "Year-Month-Day Hour:Minute:Second"
UniqueID = a unique identifier for each article 

### AUC = 0.92830  - Top 20% 