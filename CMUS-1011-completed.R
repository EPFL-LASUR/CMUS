#install.packages('igraph')
#install.packages('ggraph')
#install.packages('tidygraph')
library(igraph)
library(ggraph)
library(tidygraph)

# First, let's create a simple toy network from an adjacency matrix
data <- matrix(sample(0:2, 25, replace = TRUE), nrow = 5)
colnames(data) <- rownames(data) <- LETTERS[1:5]
network <- graph_from_adjacency_matrix(data)
plot(network)

# Second, let's create a simple toy network from an edge list
links <- data.frame(
  source = c("A", "A", "A", "A", "A", "F", "B"),
  target = c("B", "B", "C", "D", "F", "A", "E")
)
network <- graph_from_data_frame(d = links, directed = F)
plot(network)

# Now, let's start playing with the real world network that you downloaded from
# https://snap.stanford.edu/data/
fb <- read.table("/Users/Downloads/facebook_combined.txt") # a facebook dataset
gfb <- graph_from_data_frame(fb, directed = FALSE)
plot(gfb)
em <- read.table("/Users/Downloads/email-Eu-core.txt") # an email dataset
gem <- graph_from_data_frame(em, directed = TRUE)
plot(gem)
