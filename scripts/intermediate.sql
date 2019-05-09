-- dealing with null values
-- date functions
-- math functions
-- case when

-------------------------------- null values

-- replace null values
SELECT
	CarrierTrackingNumber,
	isnull(CarrierTrackingNumber, 'MISSING') CarrierTrackingNumber2
FROM
	Sales.SalesOrderDetail
where
	CarrierTrackingNumber is null ;
	
-- COALESCE statement. replace null value with first non null value 
-- replace null values
SELECT
	CarrierTrackingNumber,
	coalesce(CarrierTrackingNumber, SalesOrderID, 'MISSING') AS Location
FROM
	Sales.SalesOrderDetail
where
	CarrierTrackingNumber is null ;
	
----------------------------------- date functions

-- difference between two dates
select
	OrderDate,
	ShipDate,
	datediff(DD, OrderDate, ShipDate) -- can also use MM, YY , HH
from
	sales.SalesOrderHeader;

-- add time to date
select
	OrderDate,
	ShipDate,
	dateadd(DD, 3, ShipDate) as expected_receive_date -- can also use MM, YY , HH
from
	sales.SalesOrderHeader;
	
------------------------------------- math functions

-- rounding 
select top 1000 round(TotalDue, 1) -- round to 1 decimal place
from sales.SalesOrderHeader

select top 1000 round(TotalDue, -1) -- round to tens place
from sales.SalesOrderHeader

-- truncating
select top 1000 round(TotalDue, 0, 1) -- round to tens place
from sales.SalesOrderHeader

select
	top 1000 totaldue,
	abs(totaldue) as absolute_value,
	square(totaldue) as square_value,
	sqrt(totaldue) as square_root,
	log(totaldue) as natural_log,
	ceiling(totaldue) as next_highest_int,
	floor(totaldue) as next_lowest_int,
	round(TotalDue, 1) as round_to_1_decimal,
	round(TotalDue, -1) as round_to_10s,
	round(TotalDue, 0, 1) as truncate_valueGO
from
	sales.SalesOrderHeader
	
-------------------------------------- case when functions

select
	SalesOrderID,
	TotalDue,
	case
		when TotalDue < 100
		and TerritoryID = 1 then 'less than 100 in T1'
		when TotalDue BETWEEN 100 and 500
		and TerritoryID = 1 then 'between 100 and 500 in T1'
		else 'greater than 500 or not in T1'
	end as total_due_description
from
	sales.SalesOrderHeader







