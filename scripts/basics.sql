-- misc: clauses, count, distinct, like 
-- joins
-- set theory clauses
-- filtering joins
-- subqueries

--------------------------------- misc: clauses, count, distinct, like 

-- top 100 rows in sales.customer table
select top 100 * 
from Sales.Customer;

-- distinct territoryids
select distinct  TerritoryID
from sales.Customer;

-- count of number of rows in sales.customer
select count(*)
from sales.customer;

-- count of number of non missing storeids
select count(StoreID) as number_non_missing_storeID
from AdventureWorks2017.Sales.customer;

-- count of number of unique storeids
select count(distinct StoreID)
from sales.customer;

-- illustration of where clause
SELECT *
FROM Sales.SalesOrderDetail
WHERE UnitPrice 
BETWEEN 100 AND 1000 -- between is inclusive
AND OrderQty <= 500
-- meet above conditions or the below combined condition
OR SalesOrderID = 43659 
AND OrderQty in (1);

-- like or not like to search for pattern in a column
select top 100 * 
from sales.vSalesPerson
where FirstName like ('S%') 
or FirstName like ('%n')
or FirstName like ('Garre_t');

-- aggregate functions
select AVG(LineTotal) as avg_total,
	   MIN(LineTotal) as min_total,
	   sum(LineTotal) as sum_total
from sales.SalesOrderDetail;

-- divide by integer and you get integer in return
select (10/3);
select (10/3.0);

-- illustration of order by clause
select *
from sales.vSalesPerson
ORDER BY FirstName desc, LastName;


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


------------------------------------ joins

-- joining data in sql datacamp course
-- intro to joins section
-- outer and cross joins section
-- completed but didn't save. redo it later

------------------------------------- set theory clasues

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

-------------------------------------- filtering joins

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


------------------------------------------- subqueries

-- subquery in where clause
-- bonuses that are greater than avg
select
	*
from
	Sales.SalesPerson
where
	Bonus > (
		select AVG(bonus)
	from
		sales.SalesPerson);
	
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
	st.TerritoryID = subquery.Territoryid
	
-- the orders of each product that had the max order qty	
select
	sod.SalesOrderID, 
	sod.ProductID,
	sod.OrderQty
from
	sales.SalesOrderDetail sod
inner join (
		select max(OrderQty) max_qty,
		ProductID
	from
		sales.SalesOrderDetail
	group by
		ProductID) sq on
	sod.OrderQty = sq.max_qty
	and sod.ProductID = sq.productid;
