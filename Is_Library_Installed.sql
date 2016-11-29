EXEC sp_execute_external_script @language = N'R',  
                                  @script = N'  
	#print(data.frame(cnt = sum(rownames(installed.packages(lib = .libPaths()))=="caret"), path = .libPaths()))

	library(ROSE, quietly = T)
	library(ROCR, quietly = T)
	library(caret, quiet = T)
	library(randomForest)

		'
,@output_data_1_name = N'OutputDataSet'
with result sets undefined

/*
If the result is 0, then go to SQL Server 2016 installation directory -> run R.exe as Admin -> install.packages("desired library name") 
*/