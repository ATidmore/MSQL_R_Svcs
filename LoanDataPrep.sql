/* LoanHist is "all" of the historical data for the intents and purposes of the demo */
drop table if exists dbo.LoanHist;

select 
	id,
	issue_d,
	cast(dti as float) as dti, 
	annual_inc, 
	purpose, 
	mort_acc,
	inq_last_6mths  ,
	loan_status
into dbo.LoanHist
from dbo.LoanStats -- the original data set with 100+ vars and raw loan status
tablesample (50 percent) repeatable (1234) -- just an arbitrary sample to reduce data volume from original dataset

;

/* LoanStage will hold the Loan records staged to be assigned a value by the model - i.e. the Operational data */

drop table if exists dbo.LoanStage;

select top 10000
	id,
	issue_d,
	dti, 
	annual_inc, 
	purpose, 
	mort_acc,
	inq_last_6mths  ,
	successfully_paid 
into dbo.LoanStage -- staging some LoanStats data as if it is new, incoming data
	from (
		select 
			id,
			issue_d,
			dti, 
			annual_inc, 
			purpose, 
			mort_acc,
			inq_last_6mths  ,
			cast(null as int) as successfully_paid -- remove the existing status/flag
		from dbo.LoanStats
		where id not in (select id from LoanHist) -- don't pick up any data potentially used for training or testing
		and year(cast(issue_d as date)) = 2016 -- Get current Loans only (arbitrary)
		) as subq
	order by newid() 
;


/* LoanResults will hold the Loan data after it has been fed to the model - initially holds Test data, then will hold the Operational data */
drop table if exists LoanResults;

select top 0
	id,
	issue_d,
	dti, 
	annual_inc, 
	purpose, 
	mort_acc,
	inq_last_6mths  ,
	cast(null as float) as succ_paid_pred,
	cast(null as int) as succ_paid_actual -- Can be subsequently updated as we learn of pay-off status
into LoanResults 
from LoanStage;

