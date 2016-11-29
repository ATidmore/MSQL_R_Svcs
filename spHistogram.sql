/* This SP uses R to create a histogram of "Loan Status" then writes that image to a temporary file.
You must then use Powershell to extract the plot image to your local client.
Adapted from: https://msdn.microsoft.com/en-us/library/mt683486.aspx
*/
use LendingData;

drop procedure [dbo].[HistogramOutputFile]

CREATE PROCEDURE [dbo].[HistogramOutputFile]  
AS  
BEGIN  
  SET NOCOUNT ON;  
  DECLARE @query nvarchar(max) =  N'SELECT loan_status FROM dbo.LoanHist '  
  EXECUTE sp_execute_external_script @language = N'R',  
  @script = N'  
   # Set output directory and load ggplot
   library(ggplot2);

    mainDir <- "C:\\temp\\plots"
	dir.create(mainDir, recursive = TRUE, showWarnings = FALSE)      
	setwd(mainDir);      
	print("Creating output plot files:", quote=FALSE)  

    # Open a jpeg file and output histogram of variable in that file.  
    dest_filename = tempfile(pattern = "Histogram_loanStatus_", tmpdir = mainDir)  
    dest_filename = paste(dest_filename, ".jpg",sep="")  
    
	print(dest_filename, quote=FALSE);  
	jpeg(filename=dest_filename);  
    
	g.StatusBar <- ggplot(InputDataSet, aes(loan_status)) + geom_bar(fill = "steelblue") + coord_flip() + theme(axis.text.x = element_text(angle = 90, hjust = 1))
	
    g.StatusBar 

	dev.off();  
       
    ',  
 @input_data_1 = @query  
 END  

 exec [HistogramOutputFile];

 /* Then, open Powershell and execute this:
 bcp "exec HistogramOutputFile" queryout "HistogramOutputFile.jpg" -S <SQL Server instance name> -d  <database name>  -U <user name> -P <password>  
 */