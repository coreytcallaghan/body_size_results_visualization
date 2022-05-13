library(phytools)
library(readr)
library(dplyr)
# devtools::install_bioc("ggtree")
library(ggtree)

#Roderick super tree at the moment
birdies<-read.tree("tree/onetree.tre")

#ebird for taxonomy lookup
read_csv("taxonomy/eBird-Clements-Checklist-v2016-10-August-2016.csv") %>%
  filter(Category=="species")->lo

#syncing names to make family level tree
tree_birds<-data.frame(gs=birdies$tip.label)
lo$`Scientific name`<-sub(" ","_",lo$`Scientific name`)
tree_birds$Family<-lo$Family[match(tree_birds$gs,lo$`Scientific name`)]
tree_birds%>%
  filter(!is.na(Family))%>%
  group_by(Family)%>%
  summarize(gs=gs[1]) -> one_sp_family_lookup

family_tree<-drop.tip(birdies,birdies$tip.label[!birdies$tip.label%in%one_sp_family_lookup$gs])
family_tree$tip.label<-one_sp_family_lookup$Family[match(family_tree$tip.label,one_sp_family_lookup$gs)]
write.tree(family_tree,"tree/jetz_family_tree.tre")

# corey data
load("Visualizing phylogeny example/Data/corey_data.RData")
corey_df<-data.frame(gs=corey_data$SCIENTIFIC_NAME)

corey_df$Family<-lo$Family[match(sub(" ","_",corey_df$gs),lo$`Scientific name`)]

group_by(corey_df,Family) %>% summarize(sp.count=length(unique(gs))) -> corey_order





#filtering down to orders in the tree
lo1%>%select(Family,sp.count)%>%
  filter(Family%in%family_tree$tip.label)->df

# ggtree doesn't play nicely with tibbles
df1<-data.frame(df$sp.count)
row.names(df1)<-df$Family

df1$prop.seen<-corey_order$sp.count[match(row.names(df1),corey_order$Family)]



ggg<-ggtree(family_tree,layout="radial")+ggtitle("Corey's sampling of global birds")
g <-gheatmap(ggg, df1, offset = 3, width=0.1,low = "blue",high = "red", colnames = FALSE)
print(g)



df2<-data.frame(prop.seen=df1$prop.seen/df1$df.sp.count)
row.names(df2)<-row.names(df1)
df2$prop.seen[is.na(df2$prop.seen)]<-0


ggg<-ggtree(family_tree,layout="radial")+ggtitle("Corey's proportional sampling of global birds")
g <-gheatmap(ggg, df2, offset = 3, width=0.1,low = "blue",high = "red", colnames = FALSE)
print(g)


