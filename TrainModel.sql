use LendingData;
GO

/* "preTrain" accomplishes a bit of feature engineering before we split Train and Test 
--> As mentioned in the demo, 2012-15 Loans look most stable and have had time to be fully repaid. We don't include 2016 loans as their pay-off status is
to be determined. 
--> It was also decided to coalesce the Loan Status values down to simply Pass-Fail */
drop table if exists dbo.LoanApp_preTrain;

select id,
	issue_d,
	cast(dti as float) as dti, 
	annual_inc, 
	purpose, 
	mort_acc,
	inq_last_6mths  ,
	case when upper(loan_status) in ('FULLY PAID') then 1 else 0  end as successfully_paid
into dbo.LoanApp_preTrain
from  dbo.LoanHist
where year(cast(issue_d as date)) between 2012 and 2015
	and upper(loan_status) not in ('GRACE PERIOD','CURRENT')
	and upper(loan_status) not like '%DOES NOT MEET%';

drop table if exists dbo.LoanApp_train;

/* Generate the test set, now with 80% of the available data. 
--> We risk introducing bias into our model, but the IVs and unbalanced DV look like they could use some additional data as reinforcement
*/
select id,
	issue_d,
	cast(dti as float) as dti, 
	annual_inc, 
	purpose, 
	mort_acc,
	inq_last_6mths  ,
	successfully_paid
into dbo.LoanApp_train
from  dbo.LoanApp_preTrain
tablesample(80 percent) repeatable(1234)
;

/* Here is the table that stores the literal Model object */
drop table if exists dbo.Loan_App_TrainedModels


create  table dbo.Loan_App_TrainedModels
/* I wish this table could be more robust, but the insert containing the model binary object can only include that field 
--> "default" and "identity" properties help get some metadata in there during insert
*/
 ( 
   model varbinary(max) not null
	, create_date datetime not null default getdate() 
	, model_id int identity not null

 );


 /* Create the Training Stored Procedure 
 --> i.e. this is where the magic happens 
 A bit about R: "#" denote comments within the R-code block.
				semi-colons or other line-delimiters are not necessary.
				"print" will pipe data out of the SP.
				"OutputDataSet" is the actual output of the SP - and here, what gets inserted into "TrainedModels"
				*/

drop procedure if exists [TrainLoanModel] ;
GO

CREATE PROCEDURE [TrainLoanModel]  
/* This particular model is straight-forward:
--> Specify the levels for the Purpose variable in order to not have conflicts during Test
--> Use ROSE ("Random Over Sampling Examples") to overcome unbalanced target variable
--> Build a Random Forest using 100 Trees */
AS  
BEGIN  
  DECLARE @inquery nvarchar(max) = N'  
    select   *
	from  LoanApp_train' 
  INSERT INTO Loan_App_TrainedModels  (model)
  EXEC sp_execute_external_script @language = N'R',  
                                  @script = N'  
		library(randomForest, quietly = T)
		library(ROSE, quietly = T)

		set.seed(1234)
		
		InputDataSet$purpose <- factor(InputDataSet$purpose, levels = c("car","credit_card","debt_consolidation","home_improvement","house","major_purchase"
										,"medical","moving","other","renewable_energy","small_business","vacation","wedding"))
		
		InputDataSet$successfully_paid <- as.factor(InputDataSet$successfully_paid)

		data.rose <- ROSE(successfully_paid ~ dti + annual_inc+  mort_acc + inq_last_6mths + purpose, data = InputDataSet, seed =3)$data

		RF.mod <- randomForest(as.factor(successfully_paid) ~ inq_last_6mths + mort_acc + dti + annual_inc + purpose, data = data.rose, type = "classification" 
								,importance = TRUE, ntree = 100)

		print(summary(RF.mod))
		
		trained_model <- data.frame(model=as.raw(serialize(RF.mod, NULL)))',  
    @input_data_1 = @inquery,
    @output_data_1_name = N'trained_model'  
;
END  
GO  


/* Run it! */
exec [TrainLoanModel];