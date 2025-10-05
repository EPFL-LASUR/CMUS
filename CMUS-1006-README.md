# 1. Introduction
For today’s session, we will use R as a companion for collecting data (web scraping) and for assisting with qualitative data analysis.
We will address two research questions:
* Q1 - What sociopolitical values drove the Swiss population’s vote during the 2024 highway ballot
* Q2 - Who were the agents of the motonormative discourse during the 2024 highway campaign?

We will use the rvest / selenider framework in R for the web scraping example, and a mix of Whisper and quanteda for topic modeling.

## 1.1 Web Scrapping

Web scraping can be a useful way to collect data when the Panel Lémanique does not cover your research question(s).
However, it can also be technically challenging depending on the target website(s) and may raise important privacy concerns.
In the context of this session, the example code scrapes data from the Swiss Federal Statistical Office to collect all results for national ballots since 1961.

## 1.2 Topic Modeling

Topic modeling allows researchers to analyze qualitative data—such as texts or transcripts—using quantitative indicators.
The example will first make use of Whisper, which can assist with transcribing interviews, videos, and other audio materials.
A major advantage compared to traditional AI tools (e.g., ChatGPT) is that you can download the models to your own computer, so your data remain private and are not shared with external services.

# 2. The 2024 Highway Ballot in the Swiss Political Landscape

To answer Q1, we will combine web scraping and Geometric Data Analysis (GDA), which was introduced in Week 2 (MCA).

You will need three complementary data sources available on Moodle in your "WORKING DIRECTORY/Data" folder for the code to work:
1. Municipal characteristics (1)
2. Municipal characteristics (2)
3. Full ballot data

# 2.1 Web Scrapping Swiss Ballots

This process will be demonstrated in class. Remember the following steps:
* In your open selenider browser, you can find the selector code for any part of a webpage.
* Click on the “Select an element in the page to inspect it” button in the upper-right pane (Ctrl + Shift + C).
* Select the element on the webpage you want to interact with.
* In the Elements panel, a few lines will be highlighted in blue.
* Click on the “…” menu, go to Copy → Copy selector.
* You can now paste the selector into your R code to interact with that element.

Also note that the provided loop only scrapes the five oldest ballots for demonstration purposes.
You can increase this number up to n_ballot (currently 499), but be aware that this may require a significant amount of computational time.

# 2.2 The Swiss Political Landscape and Principal Component Analysis (PCA)

PCA is another form of Geometric Data Analysis (GDA) (see Week 2) but is used for continuous variables.
Here, this is appropriate since our variables represent the share of “yes” votes per municipality for each ballot.
The purpose and statistical logic of PCA are very similar to Multiple Correspondence Analysis (MCA): both aim to summarize large datasets by identifying a smaller number of dimensions.
Each dimension corresponds to a political divide (sociopolitical values) reflected in the results of the ballots.

### Assessments

For the following assessments, look for the section labeled “START HERE FOR THE ASSESSMENT” in the code outline.
You do not need to perform the web scraping step if you download the "Full ballot data" file from Moodle.

### Assessment 1.1 – What are the most important dimensions regarding the 2024 highway ballot?

The output of this assessment should be a table with 10 rows (dimensions) and 3 columns (dimension, coordinate, contribution).

### Assessment 1.2 - On which side of each dimension is the 2024 highway ballot situated?

Run the code that provides results for the plane formed by dimensions 1 and 3.
What are the driving forces behind the 2024 highway ballot?

You can explore other dimensions as well. As defined in the code, they can be interpreted as follows:
* D1 - Social conservatism vs. progressivism
* D2 - Sociotechnical skepticism vs. innovation
* D3 - Market liberalism vs. intervensionnism
* D8 - Eco-environmental sustainability vs. efficiency

### Assessment 1.3 - How does support for major Swiss political parties correlate with each dimension?

The output should be a correlation plot (see Week 4), showing how each municipality’s coordinates on the PCA dimensions correlate with the share of the population supporting different political parties.

# 3. Framing Political Discourses During the 2024 Highway Ballot

To answer Q2, we will use a combination of automated speech recognition and topic modeling.

You will need the complementary file “Whisper transcript”, available on Moodle in your "WORKING DIRECTORY/Data" folder, for the code to work.

## 3.1 Automated Transcript with Whisper

Whisper is a great tool for transcribing audio files into text without sharing sensitive data with external AI platforms.
Here, we download the speech recognition models locally and let the processing happen on our own computers.
However, the audio.whisper package requires a bit of additional setup — including installation from GitHub and RTools.
Feel free to install it if you plan to use it later in the semester, though it’s not necessary if you already have access to text files.

You can find the Whisper documentation on the CMUS Moodle page.

## 3.2 Topic Modeling with Quanteda

Topic modeling is a powerful method for analyzing qualitative textual data. It helps uncover associations between words based on their co-occurrence patterns, identify the main topics in a discourse, and associate each topic with specific speakers, documents, or sections.

There is no assessment for this code, but (for French speakers) you can try to define what each of the four topics emerging from the model relates to — both in the tokens and lemmas sections.
