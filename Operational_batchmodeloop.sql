use LendingData;

delete from LoanResults where year(issue_d) = 2016	;

declare @i int
	, @model varbinary(max)
	, @sqinput nvarchar(max)
set @i = 1;


while @i <= 6
begin
	print str(@i)+' Loop Beginning';
	set @sqinput = N'select id, issue_d, dti, annual_inc, purpose, mort_acc, inq_last_6mths from LoanStage where month(issue_d) = '+str(@i);
	set @model = (select top 1 model  from Loan_App_TrainedModels order by create_date desc) ;
	set @i = @i + 1
	insert into LoanResults (id, issue_d, dti, annual_inc, purpose, mort_acc, inq_last_6mths, succ_paid_pred)
	exec sp_execute_external_script @language = N'R',
		@script = N'
		library(randomForest)

		mod <- unserialize(as.raw(model));
		InputDataSet$purpose <- factor(InputDataSet$purpose, levels = c("car","credit_card","debt_consolidation","home_improvement","house","major_purchase","medical","moving","other","renewable_energy","small_business","vacation","wedding"))
		
		scores<- predict( mod, newdata = InputDataSet[, 3:7], type = "prob")

		OutputDataSet <- data.frame(id=InputDataSet$id, issue_d=InputDataSet$issue_d, dti=InputDataSet$dti, annual_inc=InputDataSet$annual_inc, purpose=InputDataSet$purpose, mort_acc=InputDataSet$mort_acc, inq_last_6mths=InputDataSet$inq_last_6mths, succ_paid_pred=scores[ ,1])
		
		'
	,@input_data_1 = @sqinput
	,@params = N'@model varbinary(max)' 
	,@model = @model
end  
GO

