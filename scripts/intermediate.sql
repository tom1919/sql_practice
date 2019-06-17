-- casting data types
-- working with null values
-- working with text values
-- working with date values
-- subqueries, CTE, temp tables
-- window functions

--------------------------------- casting data types ---------------------------------

-- common data types: numeric, character, date/time, boolean
-- others: arrays, binary, geometric, xml, json...
-- also bunch of diff numeric types

select 
	SubTotal,
	cast(subtotal as integer) subtotal_int, -- subtotal::integer in postgres
	 subtotal_int2
from sales.SalesOrderHeader;

--------------------------------- working with null values ---------------------------------

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
	

--------------------------------- working with text values ---------------------------------

select top 100 * from person.Address

-- trim / remove specified characters
select DISTINCT addressline1, 
trim('0123456789 #/.,-' from AddressLine1) as street_name
from person.Address;

-- make text lower case and match pattern
select *
from person.Address
where lower(AddressLine1) like ('%c_nnor%'); -- % matches one or more char, _ matches 1 char

-- concatenate strings. trim leading spaces
select ltrim(CONCAT(AddressLine1, ', ', city)) as address
from person.Address;

-- subset n characters of a string
select DISTINCT addressline1, 
left(addressline1, 5) as first_5_chars
from person.Address;


--------------------------------- working with date values ---------------------------------

-- cast datetime to date
select
	OrderDate
from
	sales.SalesOrderHeader
where
	cast(OrderDate as date) = '2011-05-31';

-- difference between two dates as whole unit (eg. months, days , years)
select
	OrderDate,
	ShipDate,
	datediff(DD, OrderDate, ShipDate) as diff -- can also use MM, YY , HH
from
	sales.SalesOrderHeader;

-- add time to date
select
	OrderDate,
	ShipDate,
	dateadd(DD, 3, ShipDate) as expected_receive_date -- can also use MM, YY , HH
from
	sales.SalesOrderHeader;

-- return specified part of a date
select datepart(month, orderdate) -- can also do year, quarter, dayofyear, day, week, weekday etc.
from sales.SalesOrderHeader;

-- return specified part of a date
select DATE_TRUNC(month, orderdate) -- can also do year, quarter, dayofyear, day, week, weekday etc.
from sales.SalesOrderHeader;

-- select previous record
-- also theres lead() for subsequent row
-- days between orders
select
	orderdate,
	previous_date,
	datediff(DD,  previous_date, orderdate) as day_diff
from
	(
	select
		OrderDate,
		lag(orderdate) OVER (
	order by
		orderdate) AS previous_date
	from
		sales.SalesOrderHeader ) as sub_q
order by day_diff desc;


--------------------------------- subqueries, CTE, temp tables ---------------------------------

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
-- useful if the table is re-used multiple times
select
	sales_cte.salespersonid,
	sales_cte.total_sales,
	sp.SalesQuota
from
	sales_cte
left join Sales.SalesPerson sp on
	sales_cte.salespersonid = sp.BusinessEntityID
	
-- temp table
drop table if exists total_sales;

select
	soh.SalesPersonID,
	sum(soh.SubTotal) as total_sales into
		total_sales
	from
		sales.SalesOrderHeader soh
	where
		year(OrderDate) = (
		select
			max(year(orderdate))
		from
			sales.SalesOrderHeader)
	group by
		soh.SalesPersonID

select
	sq2.salespersonid,
	sq2.total_sales,
	sp.SalesQuota
from
	total_sales as sq2
left join Sales.SalesPerson sp on
	sq2.salespersonid = sp.BusinessEntityID

--------------------------------- window functions ---------------------------------

	
--OVER() clause: pass an aggregate function down a data set like subquery in select but faster	
-- processed after entire query except order by 
-- avg total due
select 
	SalesOrderID,
	TotalDue,
	avg(totaldue) over() as overall_avg
from sales.SalesOrderHeader;


-- rank()
-- rank info according to order by variable
-- rank of stores by total due
select 
	c.storeid,
	sum(TotalDue),
	rank() over(order by sum(soh.TotalDue)  desc) as total_due_rank
FROM sales.SalesOrderHeader as soh
inner join sales.Customer as c
	on soh.CustomerID = c.CustomerID
group by c.storeid;

-- partion by()
-- calc separate values for different categories. same col diff calc
-- separate windows based on columns you want to divide resutls
select
	salesorderid,
	SalesPersonID,
	CustomerID,
	TotalDue,
	avg(TotalDue) over(partition by SalesPersonID,
	CustomerID) as avg_due_by_sales_person_customer
from
	sales.SalesOrderHeader
where SalesPersonID is not null;



-- sliding window functions
-- calc relative to current row
	-- sliding window keywords:
		-- preceding: specifying number of rows before current row to included in calc
		-- following: specifying number of rows after current row to included in calc
		-- unbounded predceding: include every row since the beg.
		-- unbounded following: include every row since the end
		-- current row: stop calc at current row
select
	salesorderid,
	OrderDate,
	round(TotalDue, 0) as total_due,
	sum(round(TotalDue, 0)) over(order by OrderDate
	rows between unbounded preceding and current row) as cumulative_sum,
	-- sd calc seems off. double check this later
	stdev(round(TotalDue, 0)) over(order by OrderDate
	rows between 2 preceding and current row ) as rolling_sd_2 -- prev 2 rows and current included
from
	sales.SalesOrderHeader
where SalesPersonID = 274;

-- percentile
select
	SubTotal,
	CurrencyRateID,
	SalesPersonID,
	TerritoryID,
	case
		when subtotal > PERCENTILE_CONT(.98) WITHIN GROUP (
		order by SubTotal) over() then PERCENTILE_CONT(.98) WITHIN GROUP (
		order by SubTotal) over()
		when subtotal < PERCENTILE_CONT(.02) WITHIN GROUP (
		order by SubTotal) over() then PERCENTILE_CONT(.05) WITHIN GROUP (
		order by SubTotal) over()
		else SubTotal
	end as capped_subtotal
from
	sales.SalesOrderHeader

	
	
------------------------------- grouped z score-------------------------------------
select
	*,
	case
		when cap_z_cap3_z > 3 then 3
		when cap_z_cap3_z < -3 then -3
		else cap_z_cap3_z
	end as cap_z_cap3_z_cap3
from
	(
	select
		*,
		case
			when stdev(cap_z_cap3) over (PARTITION by CurrencyRateID,
			TerritoryID) = 0 then 0
			else (cap_z_cap3 - avg(cap_z_cap3) over(PARTITION by CurrencyRateID,
			TerritoryID)) / stdev(cap_z_cap3) over (PARTITION by CurrencyRateID,
			TerritoryID)
		end as cap_z_cap3_z
	from
		(
		select
			*,
			case
				when cap_z > 3 then 3
				when cap_z < -3 then -3
				else cap_z
			end as cap_z_cap3
		from
			(
			select
				*,
				avg(capped_subtotal) over(PARTITION by CurrencyRateID,
				SalesPersonID) as group_avg,
				stdev(capped_subtotal) over(PARTITION by CurrencyRateID,
				SalesPersonID) as group_sd,
				case
					when stdev(capped_subtotal) over (PARTITION by CurrencyRateID,
					SalesPersonID) = 0 then 0
					else (capped_subtotal - avg(capped_subtotal) over(PARTITION by CurrencyRateID,
					SalesPersonID)) / stdev(capped_subtotal) over (PARTITION by CurrencyRateID,
					SalesPersonID)
				end as cap_z
			from
				(
				select
					SubTotal,
					CurrencyRateID,
					SalesPersonID,
					TerritoryID,
					case
						when subtotal > PERCENTILE_CONT(.98) WITHIN GROUP (
					order by
						SubTotal) over () then PERCENTILE_CONT(.98) WITHIN GROUP (
					order by
						SubTotal) over ()
						when subtotal < PERCENTILE_CONT(.02) WITHIN GROUP (
					order by
						SubTotal) over () then PERCENTILE_CONT(.05) WITHIN GROUP (
					order by
						SubTotal) over ()
						else SubTotal
					end as capped_subtotal
				from
					sales.SalesOrderHeader) as sq1) sq2) sq3) sq4














