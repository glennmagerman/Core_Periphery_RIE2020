# Author: Glenn Magerman
# Version: Dec 2017.

# Calculating directed clustering coefficient (Fagiolo, 2007)
# Measure: C_out = A^2*A^T/d_out*(d_out-1)

#----------
# Prelims 
#----------
# Load packages
library(foreign)
library(Matrix)
library(igraph)
setwd("~/Dropbox/research/papers/pecking_order")

#------------------------------
# Directed clustering (outstar)
#------------------------------
for (t in 1995:2014) {
	data <- read.table(paste("./data/tmp/WTN_",t,".csv", sep=""), header = T, sep=",")
	g <- graph.data.frame(data, directed = T)
	A <- as.matrix(get.adjacency(g))
	d <- as.data.frame(degree(g, mode = "out"))
	B <- A %*% A %*% t(A)
	C <- as.data.frame(diag(B))
	C_out <- as.data.frame(C/(d*(d-1)))			# 212 obs in 1995
	write.csv(C_out, paste("./data/tmp/C_out_",t,".csv", sep=""), row.names=T)
}

quit()
