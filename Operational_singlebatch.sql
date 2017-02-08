use LendingData;

delete from LoanResults where year(issue_d) = 2016	;

declare @model varbinary(max) = (select top 1 model  from Loan_App_TrainedModels order by create_date desc) 
  , @inquery nvarchar(max) = N'  
    select id
		, issue_d
		, dti
		, annual_inc
		, purpose
		, mort_acc
		, inq_last_6mths
	from LoanStage '
  insert into LoanResults (id, issue_d, dti, annual_inc, purpose, mort_acc, inq_last_6mths, succ_paid_pred)
  exec sp_execute_external_script @language = N'R',
                                  @script = N'
		library(randomForest)

		mod <- unserialize(as.raw(model))
		
		InputDataSet$purpose <- factor(InputDataSet$purpose, levels = c("car","credit_card","debt_consolidation","home_improvement","house","major_purchase","medical","moving","other","renewable_energy","small_business","vacation","wedding"))
		
		scores<- predict( mod, newdata = InputDataSet[, 3:7], type = "prob")

		OutputDataSet <- data.frame(id=InputDataSet$id, issue_d=InputDataSet$issue_d, dti=InputDataSet$dti, annual_inc=InputDataSet$annual_inc, purpose=InputDataSet$purpose, mort_acc=InputDataSet$mort_acc, inq_last_6mths=InputDataSet$inq_last_6mths, succ_paid_pred=scores[ ,1])
		'
,@input_data_1 = @inquery
,@params = N'@model varbinary(max)' 
,@model = @model

