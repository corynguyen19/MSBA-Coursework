-- MIS381 Homework 3 --
-- Exercise using the OfficeProduct data tables --

-- Question 1 --
-- Create the Managers, Products, Orders, Customers, and OrderDET tables with appropriate keys and constraints --
-- After tables are created, import data form Excel spreadsheets in OfficeProduct --

CREATE TABLE Managers	(
	regid Integer PRIMARY KEY,
	region VARCHAR2(10),
	regmanager varchar2(10),
    CONSTRAINT ch_region CHECK (region IN ('East', 'South', 'West', 'Central')));
    
CREATE TABLE Products	(
	prodid Integer PRIMARY KEY,
	prodname VARCHAR2(100),
	prodcat varchar2(30),
    prodsubcat varchar2(30),
	prodcont varchar2(20),
	produnitprice Number(7,2),
	prodmargin Number(5,3),
    CONSTRAINT ch_prodcat CHECK (prodcat IN ('Technology', 'Furniture', 'Office Supplies')),
    CONSTRAINT ch_prodcont CHECK (prodcont IN ('Jumbo Drum', 'Medium Box', 'Jumbo Box', 'Wrap Bag', 'Large Box', 'Small Box', 'Small Pack'))
    );

CREATE TABLE Orders	(
	orderid Integer PRIMARY KEY,
	status VARCHAR2(10)
    );
    
CREATE TABLE Customers	(
	custid Integer PRIMARY KEY,
    custname VARCHAR2(35),
    custreg Number(1,0),
    custstate varchar2(20),
	custcity varchar2(20),
	custzip Number(5,0),
	custseg varchar2(15),
    CONSTRAINT ch_custseg CHECK (custseg IN ('Home Office','Corporate', 'Small Business', 'Consumer')),
    CONSTRAINT custregFk FOREIGN KEY(custreg) references managers(regid) on delete cascade
    );
    
CREATE TABLE OrderDET	(
	orderid Integer,
    custid Integer,
    prodid Integer,
    ordpriority varchar2(15),
	orddiscount Number(3,2),
	ordshipmode Varchar2(15),
	orddate date,
    ordshipdate date,
    ordshipcost Number(5,2),
    ordqty Number,
    ordsales Number(8,2),
    CONSTRAINT orderdetPk PRIMARY KEY(orderid, custid, prodid),
    CONSTRAINT ch_ordpriority CHECK (ordpriority IN ('Low', 'Medium', 'High', 'Critical', 'Not Specified')),
    CONSTRAINT ordshipmode CHECK (ordshipmode IN ('Regular Air', 'Delivery Truck', 'Express Air')),
    CONSTRAINT ordFk FOREIGN KEY(orderid) REFERENCES Orders(orderid),
    CONSTRAINT custFk FOREIGN KEY(custid) REFERENCES Customers(custid),
    CONSTRAINT prodFk FOREIGN KEY(prodid) REFERENCES Products(prodid)
    );
    
-- Question 2 --
-- Perform analysis on cancelled orders in the order table --

-- Part A --
-- Find the fraction of orders that were cancelled --
select count(status) as cancelled_orders
    from orders
    where status = 'Returned';

select count(orderid) as total_orders
    from orders; -- There are 60 cancelled orders out of the 6428 total orders. This is .93% of all orders.

-- Part B --
-- Find the sales figures associated with the cancelled orders --
select *
from (
    select orderdet.orderid, ordsales
    from orders, orderdet
    where status = 'Returned' and orders.orderid = orderdet.orderid) -- 96 sales figures associated with the orders
where rownum <= 10;

-- Part C --
-- Find the Top 5 customers associated cancelled orders --
select *
from(
    select orderdet.custid, count(orderdet.orderid) as total_cancelled
    from customers, orderdet, orders
    where status = 'Returned' and customers.custid = orderdet.custid and orders.orderid = orderdet.orderid
    group by orderdet.custid
    order by total_cancelled desc)
where rownum <= 5; 
-- The top 5 customers have the ID numbers: 1228, 1314, 699, 3075, 1106 --

-- Question 3 --
-- Perform analysis on customer data --

-- Part A --
-- Find the top 10 customers in terms of revenues generated --
select *
from (
    select orderdet.custid, sum(ordsales) as total_sales
    from customers, orderdet
    where customers.custid = orderdet.custid
    group by orderdet.custid
    order by total_sales desc)
where rownum <= 10; -- Top 10 are 3075, 308, 2571, 2107, 553, 1733, 640, 1999, 2867, 349

-- Part B --
-- Are there customers who buy mostly some categories of products and there is a potential for them to buy other product categories? --
select *
from    (
    select custid, prodcat, count(orderdet.prodid) as total_prods
    from orderdet, products
    where products.prodid = orderdet.prodid
    group by custid, prodcat)
    pivot (sum(total_prods) for prodcat in ('Technology' as Technology, 'Furniture' as Furniture, 'Office Supplies' as Office))
    order by custid;

-- Question 4 --
-- Calculate the differences in actual sales and theoretical prices by using the formula --
-- ((unit price * number of units*(1-discount) + shipping cost) to solve for price --

-- Part A --
-- How do total sales compare to theoretical prices --
select sum(theoretical_prices) as total_price, sum(ordsales) as total_sales, (sum(theoretical_prices) - sum(ordsales)) as difference
from    (
    select orderdet.prodid, (produnitprice*ordqty*(1-orddiscount)+ordshipcost) as theoretical_prices, ordsales
    from orderdet, products
    where products.prodid = orderdet.prodid); -- Total sales are less than theoretical prices by $21791.26

-- Part B --
-- Are different managers consistently selling the products above or below the theoretical prices? --
select regmanager, sum(theoretical_prices) as total_price, sum(ordsales) as total_sales, (sum(theoretical_prices) - sum(ordsales)) as difference
from    (
    select regmanager, custreg, orderdet.prodid, (produnitprice*ordqty*(1-orddiscount)+ordshipcost) as theoretical_prices, ordsales
    from managers, customers, orderdet, products
    where products.prodid = orderdet.prodid and orderdet.custid = customers.custid and customers.custreg = managers.regid)
group by regmanager; -- Everyone is pricing less than theoretical sales overall. William has the largest discrepancies.