-- misc: basic clauses, count, distinct, like 
-- math functions
-- joins 
-- set theory clauses
-- filtering joins
-- case when



--------------------------------- misc: basic clauses, distinct, count, like ---------------------------------

-- primary key: cols that uniquely identifies a row. its unique and non nul
-- foreign key: col that reference another row via a unique key in same or other table. 
	-- foreign key values are restricted to the ones in the referenced col

-- top 100 rows in sales.customer table
select top 100 * 
from Sales.Customer;

-- illustration of where clause
SELECT *
FROM Sales.SalesOrderDetail
WHERE UnitPrice 
BETWEEN 100 AND 1000 -- between is inclusive
AND OrderQty <= 500
-- meet above conditions or the below combined condition
OR SalesOrderID = 43659 
AND OrderQty in (1);

-- illustration of group by clause to perform operations by group
-- total sale per sales order id
select SalesOrderID, 
	   sum(LineTotal) as [Total Sale],
	   sum(OrderQty) as [Total Qty],
	   count(*) as [Total diff items]
from sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING sum(OrderQty) < 20 -- use having when using aggregate functions
ORDER BY sum(LineTotal); -- order by has to go last

-- illustration of order by clause
select *
from sales.vSalesPerson
ORDER BY FirstName desc, LastName;

-- distinct territoryids including nulls
select distinct  TerritoryID
from sales.Customer;

-- count of number of rows in sales.customer
select count(*)
from sales.customer;

-- count of number of non missing StoreIds
select count(StoreID) as number_non_missing_storeID
from AdventureWorks2017.Sales.customer;

-- count of number of unique storeids including null
select count(distinct StoreID)
from sales.customer;

-- like or not like to search for pattern in a column
select top 100 * 
from sales.vSalesPerson
where FirstName like ('S%') 
or FirstName like ('%n')
or FirstName like ('Garre_t');

--------------------------------- math functions ---------------------------------

-- aggregate math functions
select AVG(LineTotal) as avg_total,
	   MIN(LineTotal) as min_total,
	   sum(LineTotal) as sum_total,
	   stdev(LineTotal) as standard_deviation,
	   var(LineTotal) as sample_variance
from sales.SalesOrderDetail;

-- math functions
select
	top 1000 totaldue,
	abs(totaldue) as absolute_value,
	square(totaldue) as square_value,
	sqrt(totaldue) as square_root,
	log(totaldue) as natural_log,
	ceiling(totaldue) as next_highest_int,
	floor(totaldue) as next_lowest_int,
	round(TotalDue, 1) as round_to_1_decimal,
	round(TotalDue, -1) as round_to_10s, -- round to tens place
	round(TotalDue, 0, 1) as truncate_value -- truncate to first whole digit
from
	sales.SalesOrderHeader;
	
-- divide by integer and you get integer in return
select (10/3);
select (10/3.0);

-- histogram of total due. number of sales in each bin of total due
select
	round(TotalDue, -3) as total_due_bin,
	count(*) as frequency
from
	sales.SalesOrderHeader
group by
	round(TotalDue, -3)
order by
	round(TotalDue, -3)

	
--------------------------------- joins ---------------------------------

-- inner join
-- only keep rows where there is a key match on both tables
select s.name, c.CustomerID
from sales.Customer as c
inner join sales.store as s 
 on c.StoreID = s.BusinessEntityID
 order by s.name
 
-- self join
-- compare values in a column with other values in the same column in the same table
-- orders that shipped to the same address. 19,816 orders 
select
	DISTINCT
	soh1.SalesOrderID,
	--soh2.SalesOrderID,
	--soh2.CustomerID,
	--soh2.CustomerID,
	soh1.ShipToAddressID as add1,
	soh2.ShipToAddressID as add2
from
	sales.SalesOrderHeader as soh1
inner join sales.SalesOrderHeader as soh2 on
	soh1.ShipToAddressID = soh2.ShipToAddressID
	and soh1.SalesOrderID <> soh2.SalesOrderID
order by add1

-- left join
-- keep all rows on the left table
-- total sales for each customer
select
	c.CustomerID,
	sum(subtotal)
from
	sales.Customer as c
left join sales.SalesOrderHeader as soh on
	c. CustomerID = soh.CustomerID
group by
	c.CustomerID

-- full join
-- keep all rows on all tables
select 
	c.CustomerID,
	s.name as 'store_name',
	sp.BusinessEntityID as sales_personID
from sales.Customer as c 
	full join sales.store as s on 
	c.StoreID = s.BusinessEntityID
	full join sales.SalesPerson as sp on
	s.SalesPersonID = sp.BusinessEntityID
	 

-- cross join
-- each row from one input is matched with all rows from the other
select
	sp.BusinessEntityID as sales_person_id,
	st.territoryid,
	name 
	--st.CostYTD
from
	sales.SalesPerson as sp
cross join sales.SalesTerritory as st
order by sales_person_id
	
	
--------------------------------- set theory clasues ---------------------------------

-- union. row bind and removes dupes. all rows that are in either tables
select FirstName from Sales.vSalesPerson -- 17 rows
UNION -- 224 rows
select FirstName from HumanResources.vEmployee; -- 290 rows

-- union all. row bind and keeps dupes
select FirstName from Sales.vSalesPerson -- 17 rows
UNION ALL -- 307 rows
select FirstName from HumanResources.vEmployee; -- 290 rows

-- intersect. rows that are in both tables
select FirstName from Sales.vSalesPerson -- 17 rows
INTERSECT -- 17 rows
select FirstName from HumanResources.vEmployee; -- 290 rows


-- except. only rows in first table and not in second. removes dupes.
select DISTINCT FirstName from HumanResources.vEmployee -- 224 distinct rows / 290 total rows
EXCEPT -- 207 rows = 224 - 17
select  DISTINCT FirstName from Sales.vSalesPerson -- 17 rows

--------------------------------- filtering joins ---------------------------------

-- semi join. rows in first table that are also in second table
 SELECT
	DISTINCT firstname
from
	HumanResources.vEmployee -- 224 distinct rows
where
	firstname in (
	select
		firstname
	from
		sales.vSalesPerson -- 17 rows
		);
	

-- semi join. rows in first table that are not in second table. 207 rows
 SELECT
	DISTINCT firstname
from
	HumanResources.vEmployee -- 224 distinct rows
	where firstname not in (
	select
		firstname
	from
		sales.vSalesPerson -- 17 rows
);


--------------------------------- case when function ---------------------------------

-- basic case when
-- create column to categorize total due amt
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


-- columns for count of ids that match conditions
-- counts of 2011 and 2012 orders by region
-- dates are inclusive
select
	TerritoryID,
	count(case when orderdate BETWEEN '2011-01-01' and '2011-12-31'  then SalesOrderID end) as '2011 orders',
	count(case when orderdate BETWEEN '2012-01-01' and '2012-12-31' then SalesOrderID end) as '2012 orders'
from
	sales.SalesOrderHeader
group by
	TerritoryID
order by TerritoryID

-- using case when with multiple conditions
-- counts of sales in 2011 and 2012 by territory id where sales person id is not null
select
	TerritoryID,
	sum(case when orderdate BETWEEN '2011-01-01' and '2011-12-31' and SalesPersonID is not null then 1 end) as '2011 orders'
	sum(case when orderdate BETWEEN '2012-01-01' and '2012-12-31' and SalesPersonID is not null then 1 end) as '2012 orders'
from
	sales.SalesOrderHeader
group by
	TerritoryID
order by TerritoryID

-- avg total due in each territory id for 2011 and 2012
select
	TerritoryID,
	avg(case when orderdate BETWEEN '2011-01-01' and '2011-12-31'  then TotalDue end) as '2011 orders',
	avg(case when orderdate BETWEEN '2012-01-01' and '2012-12-31' then TotalDue end) as '2012 orders'
from
	sales.SalesOrderHeader
group by
	TerritoryID
order by TerritoryID












