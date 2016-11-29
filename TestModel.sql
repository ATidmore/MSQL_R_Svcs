use LendingData;

truncate table LoanResults;

declare @model varbinary(max) =
  (select top 1 model  from Loan_App_TrainedModels order by create_date desc) 
  , @inquery nvarchar(max) = N'  
    select id
		, issue_d
		, dti
		, annual_inc
		, purpose
		, mort_acc
		, inq_last_6mths
		, successfully_paid
	from  dbo.LoanApp_preTrain
	where id not in (select id from LoanApp_train)' 
  insert into LoanResults
  exec sp_execute_external_script @language = N'R',
                                  @script = N'
		library(caret)
		library(randomForest)

		mod <- unserialize(as.raw(model))
		InputDataSet$id <- as.numeric(InputDataSet$id)
		InputDataSet$purpose <- factor(InputDataSet$purpose, levels = c("car","credit_card","debt_consolidation","home_improvement","house","major_purchase","medical","moving","other","renewable_energy","small_business","vacation","wedding"))
		
		scores<- predict( mod, newdata = InputDataSet[, 3:7], type = "prob")

		OutputDataSet <- data.frame(id=InputDataSet$id, issue_d=InputDataSet$issue_d, dti=InputDataSet$dti, annual_inc=InputDataSet$annual_inc, purpose=InputDataSet$purpose, mort_acc=InputDataSet$mort_acc, inq_last_6mths=InputDataSet$inq_last_6mths, succ_paid_pred=scores[ ,1], succ_paid_actual=InputDataSet$successfully_paid)
		
		print(confusionMatrix(data = ifelse(OutputDataSet$succ_paid_pred <= 0.45,0,1), ref = OutputDataSet$succ_paid_actual, positive = "1"))
		'
,@input_data_1 = @inquery
,@params = N'@model varbinary(max)' 
,@model = @model

--select top 10 * from LoanResults;