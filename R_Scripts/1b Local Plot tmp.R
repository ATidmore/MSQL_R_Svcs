library(ggplot2)

#plot is blank on remote server??? 
mainDir <- "C:/temp/plots"

dir.create(mainDir, recursive = TRUE, showWarnings = FALSE)  
setwd(mainDir);  
print("Creating output plot files:", quote=FALSE)  

# Open a png file and output histogram of tipped variable in that file.  
dest_filename = tempfile(pattern = "rHistogram_loanStatus_", tmpdir = mainDir)  

dest_filename = paste(dest_filename, ".jpg",sep="")  

print(dest_filename, quote=FALSE);  

jpeg(filename=dest_filename);  

g.StatusBar <- ggplot(LoanStats.xdf, aes(loan_status))
g.StatusBar <- g.StatusBar + geom_bar(fill = "steelblue") + coord_flip()
g.StatusBar <- g.StatusBar + theme(axis.text.x = element_text(angle = 90, hjust = 1))

dev.off();  
