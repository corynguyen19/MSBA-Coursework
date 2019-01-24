-- MIS381 Homework 4 --
-- Exercises using the Coffee and OfficeProduct data tables --

-- Part A --
-- Querying using the Coffee data tables --

-- Question 1 --
-- Extract the total sales for each product for each month --
select *
from    (
    select productid, extract(month from factdate) as salesmonth, actsales
    from factcoffee)
pivot (sum(actsales) for salesmonth in ('1' as January, '2' as February, '3' as March, '4' as April, '5' as May, '6' as June,
                                        '7' as July, '8' as August, '9' as September, '10' as October, '11' as November, '12' as December))
order by productid asc;

-- Question 2 --
-- Compare sales in 2012 to sales in 2013 --
create or replace view sales2012 as
    select statename, productid, sum(actsales) as total_sales
    from states, areacode, factcoffee
    where extract(year from factdate) = 2012 and factcoffee.areaid = areacode.areaid and areacode.stateid = states.stateid
    group by statename, productid;

create or replace view top_products2012 as    
with max2012 as
    (select statename, max(total_sales) as max_sales
    from sales2012
    group by statename)
select sales2012.statename, productid, max_sales
from sales2012, max2012
where max2012.max_sales = sales2012.total_sales and sales2012.statename = max2012.statename;

-- Part i --
-- Which state(s) had a product that was a best seller in both 2012 and 2013? --
create or replace view sales2013 as
    select statename, productid, sum(actsales) as total_sales
    from states, areacode, factcoffee
    where extract(year from factdate) = 2013 and factcoffee.areaid = areacode.areaid and areacode.stateid = states.stateid
    group by statename, productid;
 
create or replace view top_products2013 as   
with max2013 as
    (select statename, max(total_sales) as max_sales
    from sales2013
    group by statename)
select sales2013.statename, productid, max_sales
from sales2013, max2013
where max2013.max_sales = sales2013.total_sales and sales2013.statename = max2013.statename;

SELECT *
FROM top_products2012 
INNER JOIN top_products2013
ON top_products2012.statename = top_products2013.statename;

-- Part ii --
-- Are there states that had a different top selling product between 2012 and 2013? --
-- Based on the query in part i, there are no states where this happens --

-- Part iii --
-- Are there products that were top sellers in 2012, but not 2013? --
-- Based ont he query in part i, there are no products where this happens --

-- Question 3 --
-- Identify the two top selling products that are common to 2012 and 2013 --
create or replace view sales2012 as
    (select prodname, sum(actsales) as total_sales
    from factcoffee, prodcoffee
    where extract(year from factdate) = 2012 and factcoffee.productid = prodcoffee.productid
    group by prodname);

create or replace view sales2013 as
    (select prodname, sum(actsales) as total_sales
    from factcoffee, prodcoffee
    where extract(year from factdate) = 2013 and factcoffee.productid = prodcoffee.productid
    group by prodname);

select *
from sales2012
inner join sales2013
on sales2012.prodname = sales2013.prodname
order by sales2012.total_sales desc;
-- products Colombian and Lemon are the top sellers in both years

-- Question 4 --
-- What fraction of the top selling states contributes to at least 50% of the total sales? --
-- Do they also contribute to 50% of the profit share as well? --
select statename, total_sales, round(total_sales*100/819811, 2) as percent_share
from (
    select statename, sum(actsales) as total_sales
    from states, areacode, factcoffee
    where factcoffee.areaid = areacode.areaid and areacode.stateid = states.stateid
    group by statename)
order by total_sales desc;
-- Sum of all sales is 819811 --
-- The first 50% of sales is accounted for by the first 7/20 states: CA, NY, IL, NV, IO, CO, OR --

select statename, total_profit, round(total_profit*100/259543, 2) as percent_share
from (
    select statename, sum(actprofit) as total_profit
    from states, areacode, factcoffee
    where factcoffee.areaid = areacode.areaid and areacode.stateid = states.stateid
    group by statename)
order by total_profit desc;
-- first 50% of profits are accounted for by the first 6/20 states: CA, IL, IO, NY, CO, MA --

-- Question 5 --
-- Which product should be discontinued and why? --
select prodname, sum(actprofit) as total_sales
from factcoffee, prodcoffee
where factcoffee.productid = prodcoffee.productid
group by prodname
order by total_sales asc;
-- Discontinue Green Tea because it is the only product that has a negative profit --

-- Question 6 --
-- Look for seasonality trends in product sales --
-- We can reuse the query from question 1 --
-- Because we can't plot in SQL, query can be spooled then plotted in Excel --
set sqlformat csv
spool /Users/Cory/Desktop/sql_hw4_q6.csv
select *
from    (
    select extract(year from factdate) as salesyear, extract(month from factdate) as salesmonth, actsales
    from factcoffee)
pivot (sum(actsales) for salesmonth in ('1' as January, '2' as February, '3' as March, '4' as April, '5' as May, '6' as June,
                                        '7' as July, '8' as August, '9' as September, '10' as October, '11' as November, '12' as December))
order by salesyear asc;
spool off

-- Part i --
-- Are there trends for any particular product? --
set sqlformat csv
spool /Users/Cory/Desktop/sql_hw4_q6.csv
select *
from    (
    select prodname, extract(month from factdate) as salesmonth, actsales
    from factcoffee, prodcoffee
    where prodcoffee.productid = factcoffee.productid)
pivot (sum(actsales) for salesmonth in ('1' as January, '2' as February, '3' as March, '4' as April, '5' as May, '6' as June,
                                        '7' as July, '8' as August, '9' as September, '10' as October, '11' as November, '12' as December))
order by prodname asc;
spool off

-- Part ii --
-- Are there any trends in states for certain products? --
select *
from    (
    select statename, productid, actsales
    from factcoffee, states, areacode
    where factcoffee.areaid = areacode.areaid and areacode.stateid = states.stateid)
pivot (sum(actsales) for productid in ('1' as Amaretto, '2' as Colombian, '3' as Decaf_Irish_Cream, '4' as Caffe_Latte, '5' as Caffe_Mocha, '6' as Decaf_Espresso,
                                        '7' as Regular_Espresso, '8' as Chamomile, '9' as Lemon, '10' as Mint, '11' as Darjeeling, '12' as Earl_Grey, '13' as Green_Tea))
order by statename asc;

-- Question 7 --
-- Insert a column for Sales Quarter into the factcoffee table and perform queries using this column --
create table factcoffee_new as
    (select *
    from factcoffee);

alter table factcoffee_new
    add quarter varchar(10);
    
update factcoffee_new
    set quarter = (case when to_char(factdate,'Q') = 1 then 'Q1'
                        when to_char(factdate,'Q') = 2 then 'Q2'
                        when to_char(factdate,'Q') = 3 then 'Q3'
                        else 'Q4'
                        end);
 -- Part i --
 -- Find the total sales for each quarter in each year --
select *
from    (
    select extract(year from factdate) as salesyear, quarter, actsales
    from factcoffee_new)
pivot (sum(actsales) for quarter in ('Q1' as Q1, 'Q2' as Q2, 'Q3' as Q3, 'Q4' as Q4))
order by salesyear asc;

-- Part ii --
-- Which quarter has the greatest sales and profits? --
select *
from    (
    select extract(year from factdate) as salesyear, quarter, actprofit
    from factcoffee_new)
pivot (sum(actprofit) for quarter in ('Q1' as Q1, 'Q2' as Q2, 'Q3' as Q3, 'Q4' as Q4))
order by salesyear asc;
-- the best quarter in both years in terms of sales and profits is Q3 --

-- Question 8 --
-- Create a new table that captures for each state, product, and quarter combination: --
-- the total sales, total profits, percentage margin, total marketing expenses, and rank order of salesfor each quarter. --
select statename, prodname, quarter, total_sales, total_profits, percent_margin, expenses,
    rank() over (partition by quarter order by total_sales desc) "Rank"
from (
    select statename, prodname, quarter, sum(actsales) as total_sales, sum(actprofit) as total_profits,
        round(sum(actprofit)*100/sum(actsales),2) as percent_margin, sum(actexpenses) as expenses
    from factcoffee_new, areacode, states, prodcoffee
    where factcoffee_new.areaid = areacode.areaid and areacode.stateid = states.stateid and factcoffee_new.productid = prodcoffee.productid
    group by statename, prodname, quarter)
order by total_sales desc;

-- Part B --
-- Querying using the OfficeProduct data tables --

-- Question 1 --
-- Rank the managers based on sales generated --
select regmanager, sum(ordsales) as sales
from orderdet, managers, customers
where customers.custid = orderdet.custid and customers.custreg = managers.regid
group by regmanager
order by sales desc;
-- Chris, Erin, William, Sam (high to low)

-- Question 2 --
-- Find products with worst average shipping times --
select prodname, avg(extract(day from ordshipdate) - extract(day from orddate)) as ship_time
from orderdet, products
where orderdet.prodid = products.prodid
group by prodname
order by ship_time desc;
-- worst ship times: float fram, coloring pencils, vacuum, chair mats, xerox 209, avery 484 --

-- Question 3 --
-- What fraction of the revenues is generated from the top 10% of the customers? --
with temporarytable as
    (select custid, sum(ordsales) as sales
    from orderdet
    group by custid)
select percentile_disc(0.90) within group (order by sales) as sales_90th_pctile
from   temporarytable; -- 90th percentile is at 7179.92

select sum(sales) as total_revenues
from (
    select *
    from (
        select custid, sum(ordsales) as sales
        from orderdet
        group by custid
        order by sales desc)
    where sales >= 7179.92); -- The top 10% is responsible for $4892310.23

select sum(ordsales) as total_revenues
from orderdet; -- The total revenues is $8789557.34; the top 10% is responsible for 55.66%

-- Question 4 --
-- Is the top 10% of customers among the leaders in number of orders placed? --
with temporarytable as
    (select custid, count(ordsales) as sales
    from orderdet
    group by custid)
select percentile_disc(0.90) within group (order by sales) as sales_90th_pctile
from   temporarytable; -- The top 10% of customers place 7 or more orders

create or replace view top_purchasers as
(select *
    from (
        select custid, sum(ordsales) as sales
        from orderdet
        group by custid
        order by sales desc)
    where sales >= 7179.92);
    
create or replace view top_orderers as
(select *
    from (
        select custid, count(ordsales) as orders
        from orderdet
        group by custid
        order by orders desc)
    where orders >= 7);

select top_purchasers.custid, sales, orders
from top_purchasers
inner join top_orderers
on top_purchasers.custid = top_orderers.custid;
-- There are 129 customers who are both top 10% purchasers and orderers. This represents 47.78%

-- Question 5 --
-- For each city and product combination, find the total sales and rank order in each city by total sales --
select prodname, custcity, sales,
rank() over (partition by custcity
order by sales desc) "Rank"
from (
    select prodname, custcity, sum(ordsales) as sales
    from orderdet, products, managers, customers
    where orderdet.prodid = products.prodid and orderdet.custid = customers.custid
    group by prodname, custcity)
order by custcity asc;

-- Question 6 --
-- Which are the top 5 customers in each of the years --
select *
from (
    select custname, ordyear, purchases,
    rank() over (partition by ordyear order by purchases desc) "Rank"
    from (
        select custname, extract(year from orddate) as ordyear, sum(ordsales) as purchases
        from orderdet, customers
        where orderdet.custid = customers.custid
        group by custname, extract(year from orddate)))
where "Rank" <= 5
order by ordyear, "Rank" asc; -- There are only 4 entries in 2014 if we use ordshipdate; 0 if we use orddate

-- Part i --
-- Who are the common customers across all 4 years? --
select *
from (
    select custname, count(ordyear) as years_active
    from (
        select custname, extract(year from orddate) as ordyear, count(ordsales) as orders
        from orderdet, customers
        where orderdet.custid = customers.custid
        group by custname, extract(year from orddate))
    group by custname)
where years_active = 4
order by custname asc; -- There were 175 customers who ordered all 4 years

-- Part ii --
-- Are there customers in any year that are distinct? --
create or replace view distinct_customers as
(select *
from (
    select custname, count(ordyear) as years_active
    from (
        select custname, extract(year from orddate) as ordyear, count(ordsales) as orders
        from orderdet, customers
        where orderdet.custid = customers.custid
        group by custname, extract(year from orddate))
    group by custname)
where years_active = 1);

select distinct customers.custname, extract(year from orddate) as ordyear
from orderdet, customers, distinct_customers
where orderdet.custid = customers.custid and customers.custname = distinct_customers.custname
order by customers.custname asc; -- There are 1170 customers that were distinct across all 4 years

-- Question 7 --
-- Find the number of orders in each subcategory in states Michigan and Washington --
create or replace view michigan as
(select *
from (
    select custstate, prodsubcat, count(orderid) as michigan_orders
    from orderdet, products, customers
    where orderdet.custid = customers.custid and products.prodid = orderdet.prodid
    group by custstate, prodsubcat)
where custstate = 'Michigan');

create or replace view washington as
(select *
from (
    select custstate, prodsubcat, count(orderid) as washington_orders
    from orderdet, products, customers
    where orderdet.custid = customers.custid and products.prodid = orderdet.prodid
    group by custstate, prodsubcat)
where custstate = 'Washington');

select michigan.prodsubcat, michigan_orders, washington_orders
from michigan
full outer join washington
on michigan.prodsubcat = washington.prodsubcat

-- Question 8 --
-- Find the total orders in each quarter --
select to_char(orddate,'Q') as quarter, count(orderid) as orders
from orderdet
group by to_char(orddate,'Q')
order by quarter asc;

-- Question 9 --
-- For each quarter and customer segment, find the total sales --
select *
from (
    select custseg, to_char(orddate,'Q') as quarter, ordsales
    from orderdet, customers
    where orderdet.custid = customers.custid)
pivot (sum(ordsales) for quarter in ('1' as Q1, '2' as Q2, '3' as Q3, '4' as Q4));