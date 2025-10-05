
# //////////////////////////////////////////////////////////////////////////////
# CMUS EXAMPLE 4 - TOPIC MODELING IN THE HIGHWAY DEBATE
# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


# 1 : Libraries ----------------------------------------------------------------


## ... 1 : Load libraries ------------------------------------------------------

# Note that the first three packages are commented because you do not need them to go through
# the last part of the code (text plots) and they require additional installation (RTools). 
# Feel free to install all of them if you think you will use whisper during the semester.

#install.packages("av")
#install.packages("remotes")
#remotes::install_github("bnosac/audio.whisper", ref = "0.2.2")
install.packages("quanteda")
install.packages("quanteda.texplots")
install.packages("seededlda")
install.packages("udpipe")

library(dplyr)                                                      # Base R.
library(tidyr)                                                      # Base R.
library(av)                                                         # Package for the conversion to audio files.
library(audio.whisper)                                              # The Whisper package for local automated transcript.
library(quanteda)                                                   # Package for topic modeling.
library(quanteda.textplots)                                         # Package to plot results from topic modeling.
library(seededlda)                                                  # For "terms".
library(udpipe)                                                     # Package to download textual models from the web.


## ... 2 : Working directory ---------------------------------------------------

setwd("C:/Users/alexis/Desktop/CMUS - W5")                          # Set the working directory.


# 2 : Whisper ------------------------------------------------------------------


## ... 1 : Convert a video file into an audio file ----------------------------- 

av_audio_convert('highway.mp4',                                     # Here we convert a video found online into a much lighter audio file for whisper.
                 'highway_wav2.wav',                                # Name the output file.
                 format = "wav", sample_rate = 16000,               # We choose the wav format - the sample rate is just to make sure that the quality is good enough but generally it's not necessary.
                 total_time = 120)                                  # With start_time = ... and total_time = ... you can specify the frame you want to convert - for the demo we just do the 120 initial seconds.


## ... 2 : Run the assisted transcript with Whisper ----------------------------

model <- whisper("tiny")                                            # This will download a speech recognition model - there are several versions ("tiny", "base", "small", "medium", "large", etc.). Each one is gradually better but also takes more computation time and resources. The data use in class has been done with the "small" model which provides good results, granted the necessary double check.

trans <- predict(model,                                             # predict() is the main function from audio.whisper - here we provide the model we have chose before (here, "tiny").
                 newdata = "highway_wav2.wav",                      # We also provide the audio file for which we want a transcript.
                 language = "fr", n_threads = 8)                    # We specify the language and the number of threads use (optional).

saveRDS(trans, file = "Data/transc_tiny")                           # We can then save the file in a RDS format for later uses.

readRDS("Data/transc_tiny")$data %>% as_tibble() %>%                # We can then load it again and convert the file from RDS format to the traditional tibble format.
  write.csv("Data/transc_tiny.csv",                                 # We can directly save it as a CSV file (like the one available online).
            fileEncoding = "windows-1252")                          # And we specify the encoding.


# 3 : Topic modeling -----------------------------------------------------------


## ... 1 : Get the data ready --------------------------------------------------

### >>> START HERE IF YOU USE THE PROVIDED DATA ON MOODLE ----
data <- read.csv("Data/transc_small_clean.csv",                     # Read the clean version of the data.
                 fileEncoding = "windows-1252") %>% 
  as_tibble() %>%                                                   # Convert into tibble.
  group_by(speaker) %>%                                             # We want to parse all elements from one speaker together. We start by grouping the data by speaker.
  summarise(text = paste0(text, collapse = "")) %>% ungroup() %>%   # We use summarise and paste0() to combine all text together - then we can ungroup the data if necessary.
  filter(speaker %in% c("AR", "BT", "DKB", "DR",                    # We only keep data for the speakers we care about.
                        "ITW", "JDQ", "MV"))

data_corpus <- corpus(data, docid_field = "speaker",                # To run topic analysis, we create 7 corpus of text - one for each speaker. 
                      text_field = "text")

data_tokens <- data_corpus %>%                                      # We will now create tokens, in other words separate our text into words.
  tokens(remove_punct = T, remove_symbols = T,                      # We can easily remove punctuation, symbols, and numbers from the text. 
         remove_numbers = T) %>%
  tokens_split("'", valuetype = "fixed") %>%                        # We add the apostle as another stop word to be removed (see below).
  tokens_remove(c(stopwords("fr"), "a")) %>%                        # Stop words are a list of word (different for each language) that do not really hold any analytical value - we can add any number of words we want (here, "a").
  tokens_wordstem(language = "fr")                                  # Stemming enables to reduce each word to its root (no plural, etc.).


## ... 2 : Topic modeling with tokens ------------------------------------------

data_dfm <- data_tokens %>% dfm() %>%                               # dfm stands for Document Feature Matrix - we create a table with each speaker in rows and each words in columns.
  dfm_trim(min_termfreq = 2)                                        # We specify the minimum number of times each word has to appear to be accounted for.

lda_model <- textmodel_lda(data_dfm,                                # We run the topic modeling algorithm (Latent Dirichelet Allocation).
                           k = 4,                                   # For this example, we keep 4 themes - this has to be evaluated iteratively. 
                           auto_iter = T, verbose = T)

terms(lda_model, n = 20)                                            # We discover the associations between words and topics.

topics(lda_model)                                                   # Then we can know what topic each speaker uses the most.


## ... 3 : Advanced topic modeling with lemmas ---------------------------------

getlemma <- function(x) {                                           # We will now work with more complex algorithms to advance from tokens to lemmas - those only keep the roots of each word (no plural, etc.).
  print(substr(x, 1, 100))                                          # You do not need to understand this piece of the code - it's a function that will help get lemmas out of texts.
  ttg <- udpipe(x, object = udmodel)
  ttg <- ttg[ttg$upos %in% c("NOUN", "VERB", "ADJ"),]
  return(paste(ttg$lemma, collapse = " "))
}

udmodel <- udpipe_download_model(language = "french")               # You only need to do this once - it will download the model used for lemmisation (feel free to change the langage).

data_lems <- lapply(data$text, getlemma) %>%                        # We use the function created to extract the lemmas from the text.
  unlist() %>% tokens()                                             # We get the tokens in the same way than before.

docnames(data_lems) <- data$speaker                                 # We add a new information for the speakers - since the object is not a tibble, we have to use the "old-fashioned" way.

data_lems_dfm <- data_lems %>% dfm() %>% dfm_trim()                 # We create the DFM object once again.

lda_lems_model <- textmodel_lda(data_dfm, k = 4,                    # And run the same model.
                                auto_iter = T, verbose = T)

terms(lda_lems_model, 20) %>% as_tibble()                           # We can inspect the topics we have extracted.

topics(lda_lems_model)                                              # And see who are the speakers more akin to use some of them.


# ... 4 : Build networked textplots --------------------------------------------

fcmat_AR <- fcm(data_lems[1],                                       # For each speaker, we can extract the feature co-occurrence matrix - how many times each lemmas are used together (in a sentence, in a paragraph, etc.).
                context = "window", tri = F)                        # "window" means that the co-occurrences will be calculated within a specific frame - the default value is 5, you can change it with window = ... if "tri" is FALSE you will get the full matrix and not only the triangular one.

feat_AR <- colSums(fcmat_AR) %>% sort(decreasing = T) %>%           # To produce networked plots we need to reduce the size of the matrices - we count how many time each word appear and order them accordingly.
  head(30) %>% names()                                              # We decide to keep only the 30 most common words.

fcm_select(fcmat_AR, pattern = feat_AR) %>% textplot_network()      # We select the words we have identified and produce a text plot for Albert Rösti.

fcmat_BT <- fcm(data_lems[2],                                       # We do the same for Breanda Tuosto (Social Party).
                context = "window", tri = F)

feat_BT <- colSums(fcmat_BT) %>% sort(decreasing = T) %>% 
  head(30) %>% names()

fcm_select(fcmat_BT, pattern = feat_BT) %>% textplot_network()

fcmat_MV <- fcm(data_lems[7],                                       # We do the same for Moreno Volpi (Swiss Touring Club).
                context = "window", tri = F)

feat_MV <- colSums(fcmat_MV) %>% sort(decreasing = T) %>% 
  head(30) %>% names()

fcm_select(fcmat_MV, pattern = feat_MV) %>% textplot_network()

fcmat_ITW <- fcm(data_lems[5],                                      # We do the same for the interviewer (Swiss Television).
                 context = "window", tri = F)

feat_ITW <- colSums(fcmat_ITW) %>% sort(decreasing = T) %>% 
  head(30) %>% names()

fcm_select(fcmat_ITW, pattern = feat_ITW) %>% textplot_network()
