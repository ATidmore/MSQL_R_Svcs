setwd("~/MS SQL Server/2016 R Services etc/Lending Club")

if (!('ggmap' %in% rownames(installed.packages()))){  
        install.packages('ggmap')  
}  
if (!('mapproj' %in% rownames(installed.packages()))){  
        install.packages('mapproj')  
}  
if (!('ROCR' %in% rownames(installed.packages()))){  
        install.packages('ROCR')  
}  
if (!('RODBC' %in% rownames(installed.packages()))){  
        install.packages('RODBC')  
}  

print("Libraries installed")