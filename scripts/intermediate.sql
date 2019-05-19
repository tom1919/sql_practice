-- dealing with null values
-- date functions
-- math functions
-- subqueries

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

------------------------------------------- subqueries

-- subquery in select clause
-- number of sales people per territory
select
	distinct st.name,
	(
		select count(*)
	from
		Sales.SalesPerson sp
	where
		st.territoryid = sp.TerritoryID) as num
from
	sales.SalesTerritory st;

-- subquery inside the from clause
-- number of sales person in each territory
select
	st.name,
	subquery.cnt
from
	sales.SalesTerritory st
inner join (
	select
		count(*) as cnt,
		sp.Territoryid as Territoryid
	from
		sales.salesperson sp
	group by
		TerritoryID) subquery on
	st.TerritoryID = subquery.Territoryid;


-- subquery inside the from clause. 2nd example
-- the orders of each product that had the max order qty	
select
	sod.SalesOrderID,
	sod.ProductID,
	sod.OrderQty
from
	sales.SalesOrderDetail sod
inner join (
	select
		max(OrderQty) max_qty,
		ProductID
	from
		sales.SalesOrderDetail
	group by
		ProductID) sq on
	sod.OrderQty = sq.max_qty
	and sod.ProductID = sq.productid;


-- subquery in where clause
-- bonuses that are greater than avg
select
	*
from
	Sales.SalesPerson
where
	Bonus > (
	select
		AVG(bonus)
	from
		sales.SalesPerson);
	

-- correlated subqueries. reference column(s) in main query
-- evaluated once per row so its slow
-- sales persons that have bonus of 5000
SELECT
	DISTINCT 
	p.LastName,
	p.FirstName,
	e.BusinessEntityID
FROM
	Person.Person AS p
JOIN HumanResources.Employee AS e ON
	e.BusinessEntityID = p.BusinessEntityID
WHERE
	5000.00 IN (
		SELECT Bonus
	FROM
		Sales.SalesPerson sp
	WHERE
		e.BusinessEntityID = sp.BusinessEntityID);
	

-- nested subqueries
-- useful for multi step transformations
-- each sales person total sales for latest year and their sales quota
select
	sq2.salespersonid,
	sq2.total_sales,
	sp.SalesQuota
from
	(
	select
		soh.SalesPersonID,
		sum(soh.SubTotal) as total_sales
	from
		sales.SalesOrderHeader soh
	where
		year(OrderDate) = (
		select
			max(year(orderdate))
		from
			sales.SalesOrderHeader)
	group by
		soh.SalesPersonID ) as sq2
left join Sales.SalesPerson sp on
	sq2.salespersonid = sp.BusinessEntityID
		
-- common table expressions (CTE)
-- each sales person total sales for latest year and their sales quota
-- organize prev subqueries sequentially 
-- created cte must be called, error otherwise

-- innermost subquery
with latest_year  as (
select
	max(year(orderdate)) as yyyy
from
	sales.SalesOrderHeader 
	),
-- outer subquery
sales_cte as (
select
	soh.SalesPersonID,
	sum(soh.SubTotal) as total_sales
from
	sales.SalesOrderHeader soh
where
	year(OrderDate) = (
		select yyyy
	from
		latest_year
		)
group by
	soh.SalesPersonID 
	)

-- join sales cte
select
	sales_cte.salespersonid,
	sales_cte.total_sales,
	sp.SalesQuota
from
	sales_cte
left join Sales.SalesPerson sp on
	sales_cte.salespersonid = sp.BusinessEntityID
	

































