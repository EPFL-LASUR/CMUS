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

# Third, we'll start exploring different kinds of networks

# Let's create an Erdős-Rényi random network with 11 nodes and 22 edges
g <- sample_gnm(11, 22)
plot(g)

# Let's see what's the degree distribution in this network
degree(g)
degree_distribution(g)

# What about the edge betweenness?
edge_betweenness(g)
ebs <- edge_betweenness(g)
as_edgelist(g)[ebs == max(ebs), ]

# Let's detect communities in this network
comm <- cluster_louvain(g)
plot(comm, g)

# Let's plot this same graph using a force-directed layout
layout <- layout_with_fr(g)
plot(g, layout = layout)

# Let's create a Watts-Strogatz small world network with 150 nodes
g <- sample_smallworld(1, 150, 5, 0.05)
plot(g)
#Let's compute the mean distance between any two nodes in the network
mean_distance(g)

# Create a Barabasi-Albert scale-free network (for example, the World Wide Web)
g <- sample_pa(200, power = 1, m = 1, directed = FALSE)
# Customize the graph appearance and visualize node degree and edge betweenness
V(gfb)$size <- 0.05*degree(gfb) # Vertex size based on degree
V(gfb)$color <- rainbow(100)[cut(degree(gfb), breaks = 100)] # Vertex color based on degree
E(gfb)$width <- edge_betweenness(gfb) * 0.00001 # Edge width based on betweenness
plot(gfb,
     vertex.label = NA, # Remove vertex labels
     edge.curved = 0.1, # Add curve to edges
     layout = layout_with_fr(gfb))

# Create and visualize a weighted graph (for example, the strength of relationships)
edges <- data.frame(
  from = sample(1:11, 22, replace = TRUE),
  to = sample(1:11, 22, replace = TRUE),
  weight = runif(22))
g <- graph_from_data_frame(edges, directed = FALSE)
plot(g,
     edge.width = E(g)$weight * 10, # Edge width based on weight
     vertex.size = 20,
     vertex.color = "lightblue",
     vertex.label.color = "black",
     edge.color = "gray50",
     layout = layout_in_circle(g))


# Finally, let's start playing with the real world network that you downloaded from
# https://snap.stanford.edu/data/
fb <- read.table("/Users/Downloads/facebook_combined.txt") # a facebook dataset
gfb <- graph_from_data_frame(fb, directed = FALSE)
em <- read.table("/Users/Downloads/email-Eu-core.txt") # an email dataset
gem <- graph_from_data_frame(em, directed = TRUE)

# Go ahead and apply the same methods on your network as with the above toy networks:
# Degree distribution
# Edge betweenness
# Community detection
# Plotting/visualization

# BONUS QUESTION: what kind of network does your real world network look like?