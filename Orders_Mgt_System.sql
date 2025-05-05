/*
==================================================================================
We'll develop a project for a "Fictional Online Retail Company". 
This project will cover creating a database, tables, and indexes, inserting data,
and writing various queries for reporting and data analysis.
==================================================================================

Project Overview: Fictional Online Retail Company
--------------------------------------
A.	Database Design
	-- Database Name: OnlineRetailDB

B.	Tables:
	-- Customers: Stores customer details.
	-- Products: Stores product details.
	-- Orders: Stores order details.
	-- OrderItems: Stores details of each item in an order.
	-- Categories: Stores product categories.
C.	Insert Sample Data:
	-- Populate each table with sample data.

D. Write Queries:
	-- Retrieve data (e.g., customer orders, popular products).
	-- Perform aggregations (e.g., total sales, average order value).
	-- Join tables for comprehensive reports.
	-- Use subqueries and common table expressions (CTEs).
*/

---create database:
CREATE DATABASE OnlineRetailDB
Go

---use database
USE OnlineRetailDB
GO

---create customers table
CREATE TABLE Customers(
		CustomerID INT Primary Key Identity(1,1),
		FirstName Nvarchar(50),
		LastName Nvarchar(50),
		Email Nvarchar(100),
		Phone Nvarchar(50),
		Address Nvarchar(255),
		City Nvarchar(50),
		State Nvarchar(50),
		ZipCode Nvarchar(50),
		Country Nvarchar(50),
		CreatedAt Datetime Default Getdate()
)

--create the products table:
CREATE TABLE Products(
		ProductID Int Primary Key Identity(1,1),
		ProductName Nvarchar(100),
		CategoryID Int
		,Price Decimal(10,2)
		,Stock Int
		,CreatedAt Datetime Default Getdate()
)

--create the categories table
CREATE TABLE Categories(
		CategoryID Int Primary Key Identity(1,1)
		,CategoryName Nvarchar(100)
		,Description Nvarchar(255)
)

---create the orders table
CREATE TABLE Orders(
		OrderID Int Primary Key Identity(1,1)
		,CustomerID Int
		,OrderDate Datetime Default Getdate()
		,TotalAmount Decimal(10,2)
		,FOREIGN KEY(CustomerID) REFERENCES Customers(CustomerID)
)

---create the OrderItems Table
CREATE TABLE OrderItems(
		OrderItemID Int Primary Key Identity(1,1)
		,OrderID Int
		,ProductID Int
		,Quantity Int
		,Price Decimal(10,2)
		,FOREIGN KEY(ProductID) REFERENCES Products(ProductID)
		,FOREIGN KEY(OrderID) REFERENCES Orders(OrderID)
)

---Insert Sample Data:
INSERT INTO Categories (CategoryName, Description)
VALUES
('Electronics','Devices and Gadgets'),
('Clothing', 'Apparel and Accessories'),
('Books', 'Printed and Electronic Books');

--Insert into the products table
INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES
('Smartphone', 1, 699.99, 50),
('Laptop', 1, 999.99, 30),
('T-shirt', 2, 19.99, 100),
('Jeans', 2, 49.99, 60),
('Fiction Novel', 3, 14.99, 200),
('Science Journal', 3, 29.99, 150)

---insert into customers table
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES
('Sameer', 'Khanna', 'sameer.khanna@example.com', '123-456-7890', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA'),
('Jane', 'Smith', 'jane.smith@example.com', '234-567-8901', '456 Oak St.', 'Madison', 
'WI', '53703', 'USA'),
('harshad', 'patel', 'harshad.patel@example.com', '345-678-9012', '789 Dalal St.', 'Mumbai', 
'Maharashtra', '41520', 'INDIA');

-- Insert sample data into Orders table
INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES 
(1, GETDATE(), 719.98),
(2, GETDATE(), 49.99),
(3, GETDATE(), 44.98);

-- Insert sample data into OrderItems table
INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES 
(1, 1, 1, 699.99),
(1, 3, 1, 19.99),
(2, 4, 1,  49.99),
(3, 5, 1, 14.99),
(3, 6, 1, 29.99);

--Query 1: Retrieve all orders and order items for a specific customer
select o.OrderID, o.OrderDate, o.TotalAmount, oi.ProductID, p.ProductName, oi.Quantity, oi.Price
from orders o
join orderItems oi
on o.OrderID = oi.OrderID
join Products p
on oi.ProductID = p.ProductID
where o.CustomerID = 1

---Query 2: Find the total sales for each product
select p.ProductID, p.ProductName, sum(oi.price * oi.quantity) as TotalSales
from products p
join orderitems oi
on p.ProductID = oi.ProductID
group by p.ProductName, p.ProductID
order by TotalSales desc

--Query 3: Calculate the average order value
select avg(TotalAmount) AverageOrderValue
from Orders

--Query 4: List the top 5 customers by total spending
select top(5) c.CustomerID, c.FirstName, c.LastName, sum(o.TotalAmount) as TotalSpent
from Customers c
join Orders o
on c.CustomerID = o.CustomerID
group by c.CustomerID, c.FirstName, c.LastName
order by TotalSpent desc

--top 5 using the window fn row number()
SELECT CustomerID, FirstName, LastName, TotalSpent, rn
FROM
(SELECT c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalSpent,
ROW_NUMBER() OVER (ORDER BY SUM(o.TotalAmount) DESC) AS rn
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerId
GROUP BY c.CustomerID, c.FirstName, c.LastName)
sub WHERE rn <= 5;

--Query 5: Retrieve the most popular product category
select cg.CategoryID, cg.CategoryName, sum(oi.Quantity) TotalQtySold
from orderItems oi
join products p
on oi.productID = p.productID
join categories cg
on p.categoryID = cg.categoryID
group by cg.CategoryID, cg.CategoryName
order by TotalQtySold desc

----- to insert a product with zero stock
INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES 
('Keyboard', 1, 39.99, 0)

--Query 6: List all products that are out of stock, i.e. stock = 0
select * from Products where Stock = 0

--Query 7: Find customers who placed orders in the last 30 days
select c.customerID, c.FirstName, c.LastName, c.Email, c.Phone
from Customers c
join Orders o
on c.CustomerID = o.CustomerID
where o.OrderDate >= DATEADD(day, -30, GETDATE())

--Query 8: Calculate the total number of orders placed each month
select year(orderdate) as 'Year',
		month(orderdate) as 'Month',
		count(OrderID) as TotalOrders
from Orders
group by year(orderdate), month(orderdate)
order by TotalOrders desc

--Query 9: Retrieve the details of the most recent order
select top(1) c.CustomerID, c.FirstName, c.LastName, o.OrderID, o.OrderDate, o.TotalAmount
from Customers c join orders o
on c.CustomerID = o.CustomerID
order by o.OrderDate desc


--Query 10: Find the average price of products in each category
 SELECT c.CategoryID, c.CategoryName, avg(p.Price) as avgPrice 
 FROM Products p JOIN Categories c
 ON p.CategoryID = c.CategoryID
 group by c.CategoryID, c.CategoryName
 order by avgPrice desc

 select * from OrderItems
 select * from Orders

 --Query 11: List customers who have never placed an order
 select c.CustomerID, c.FirstName, c.LastName
 from Customers c 
 left join Orders o
 on c.CustomerID =o.CustomerID
 where o.OrderID is null

 --Query 12: Retrieve the total quantity sold for each product
 select p.ProductID, p.ProductName, sum(oi.Quantity) as TotalQty
 from Products p join OrderItems oi
 on p.ProductID = oi.ProductID
 group by p.ProductID, p.ProductName
 order by TotalQty desc

 --Query 13: Calculate the total revenue generated from each category
 select cg.CategoryID, cg.CategoryName, sum(oi.Price) as TotalRev
 from Categories cg join Products p
 on cg.CategoryID = p.CategoryID
 join OrderItems oi
 on p.ProductID = oi.ProductID
 group by cg.CategoryID, cg.CategoryName
 order by TotalRev desc

 --Query 15: Retrieve orders with a total amount greater than a specific value (e.g., $500)
select OrderID, TotalAmount
from Orders 
where TotalAmount > 500

--Query 16: List products along with the number of orders they appear in
select p.ProductID, p.ProductName, COUNT(oi.OrderItemID) as No_of_Orders
from Products p join OrderItems oi
on p.ProductID = oi.ProductID
group by p.ProductID, p.ProductName
order by No_of_Orders desc

--Query 17: Find the top 3 most frequently ordered products
select top(3) p.ProductID, p.ProductName, COUNT(oi.OrderItemID) as No_of_Orders
from Products p join OrderItems oi
on p.ProductID = oi.ProductID
group by p.ProductID, p.ProductName
order by No_of_Orders desc

--Query 18: Calculate the total number of customers from each country
select Country, count(CustomerID) No_of_Customers
from Customers
group by Country

--Query 19: Retrieve the list of customers along with their total spending
SELECT c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalSpending
FROM Customers c JOIN Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName;


--Query 20: List orders with more than a specified number of items (e.g., 5 items)
SELECT o.OrderID, c.CustomerID, c.FirstName, c.LastName, COUNT(oi.OrderItemID) AS NumberOfItems
FROM Orders o JOIN OrderItems oi
ON o.OrderID = oi.OrderID
JOIN Customers c 
ON o.CustomerID = c.CustomerID
GROUP BY o.OrderID, c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(oi.OrderItemID) >= 1
ORDER BY NumberOfItems;

/*
===========================
LOG MAINTENANCE
===========================
Let's create additional queries that involve updating, deleting, and maintaining logs of these operations 
in the OnlineRetailDB database. 

To automatically log changes in the database, you can use triggers in SQL Server. 
Triggers are special types of stored procedures that automatically execute in response 
to certain events on a table, such as INSERT, UPDATE, or DELETE.

Here’s how you can create triggers to log INSERT, UPDATE, and DELETE operations 
for the tables in the OnlineRetailDB.

We'll start by adding a table to keep logs of updates and deletions.

Step 1: Create a Log Table
Step 2: Create Triggers for Each Table
	
	A. Triggers for Products Table
		-- Trigger for INSERT on Products table
		-- Trigger for UPDATE on Products table
		-- Trigger for DELETE on Products table

	B. Triggers for Customers Table
		-- Trigger for INSERT on Customers table
		-- Trigger for UPDATE on Customers table
		-- Trigger for DELETE on Customers table
*/

--create a log table
CREATE TABLE ChangeLog (
		LogID INT PRIMARY KEY IDENTITY (1,1)
		,TableName Nvarchar(50)
		,Operation Nvarchar(10)
		,RecordID INT
		,ChangeDate DATETIME DEFAULT GETDATE()
		,ChangedBy Nvarchar(100)
)

GO

---A. Triggers for the products table
---1. Trigger for INSERT
CREATE OR ALTER TRIGGER trg_insert_product
ON Products
AFTER INSERT
AS 
BEGIN
			---insert record into changelog table
			INSERT INTO ChangeLog(TableName, Operation, RecordID, ChangedBy)
			SELECT 'Products', 'INSERT', inserted.productID, SYSTEM_USER
			from inserted

			---display msg confirming the insert
			print 'Insert Operation Logged for Products Table.'
END
GO

---Try to insert into products table
Insert into Products(ProductName, CategoryID, Price, Stock)
Values('Wireless Mouse', 1, 4.99, 20)

INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES ('Spiderman Multiverse Comic', 3, 2.50, 150)

---Display Products Table
select * from Products

--Display the changelog table
select * from changelog

---trigger for update on products table
CREATE OR ALTER TRIGGER trg_update_product
ON products
AFTER UPDATE
AS
BEGIN
			---insert record into the changelog table
			INSERT INTO ChangeLog(TableName, Operation, RecordID, ChangedBy)
			SELECT 'products', 'UPDATE', inserted.productID, SYSTEM_USER
			from inserted

			--insert msg to sow that the trigger as fired
			PRINT 'UPDATE operation logged for Products table'

END
GO

-- Try to update any record from Products table
UPDATE Products SET Price = Price - 300 WHERE ProductID = 2;


-- Trigger for DELETE a record from Products table
CREATE OR ALTER TRIGGER trg_delete_Product
ON Products
AFTER DELETE
AS
BEGIN
	
	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'DELETE', deleted.ProductID, SYSTEM_USER
	FROM deleted;

	-- Display a message indicating that the trigger has fired.
	PRINT 'DELETE operation logged for Products table.';
END;
GO

-- Try to delete an existing record to see the effect of Trigger
DELETE FROM Products WHERE ProductID = 11;

-- B. Triggers for Customers Table
-- Trigger for INSERT on Customers table
CREATE OR ALTER TRIGGER trg_Insert_Customers
ON Customers
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'INSERT', inserted.CustomerID, SYSTEM_USER
	FROM inserted;

	-- Display a message indicating that the trigger has fired.
	PRINT 'INSERT operation logged for Customers table.';
END;
GO

-- Trigger for UPDATE on Customers table
CREATE OR ALTER TRIGGER trg_Update_Customers
ON Customers
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'UPDATE', inserted.CustomerID, SYSTEM_USER
	FROM inserted;

	-- Display a message indicating that the trigger has fired.
	PRINT 'UPDATE operation logged for Customers table.';
END;
GO

-- Trigger for DELETE on Customers table
CREATE OR ALTER TRIGGER trg_Delete_Customers
ON Customers
AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON;

	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'DELETE', deleted.CustomerID, SYSTEM_USER
	FROM deleted;

	-- Display a message indicating that the trigger has fired.
	PRINT 'DELETE operation logged for Customers table.';
END;
GO

-- Try to insert a new record to see the effect of Trigger
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Virat', 'Kohli', 'virat.kingkohli@example.com', '123-456-7890', 'South Delhi', 'Delhi', 
'Delhi', '5456665', 'INDIA');
GO
	
-- Try to update an existing record to see the effect of Trigger
UPDATE Customers SET State = 'Florida' WHERE State = 'IL';
GO
	
-- Try to delete an existing record to see the effect of Trigger
DELETE FROM Customers WHERE CustomerID = 5;
GO


/*
===============================
Implementing Indexes
===============================

Indexes are crucial for optimizing the performance of your SQL Server database, 
especially for read-heavy operations like SELECT queries. 

Let's create indexes for the OnlineRetailDB database to improve query performance.

A. Indexes on Categories Table
	1. Clustered Index on CategoryID: Usually created with the primary key.
*/

USE OnlineRetailDB
CREATE CLUSTERED INDEX ind_categories_categoryID
on Categories(CategoryID)
GO ---doesn't work since the index was created when we assigned the primary key

/*
B. Indexes on Products Table
	1. Clustered Index on ProductID: This is usually created automatically when 
	   the primary key is defined.
	2. Non-Clustered Index on CategoryID: To speed up queries filtering by CategoryID.
	3. Non-Clustered Index on Price: To speed up queries filtering or sorting by Price.
*/

---drop foreign key from orders table
ALTER TABLE orderitems DROP CONSTRAINT FK__OrderItem__Produ__300424B4

---create non clustered indexes
-- Non-Clustered Index on CategoryID: To speed up queries filtering by CategoryID.
CREATE NONCLUSTERED INDEX IDX_Products_CategoryID
ON Products(CategoryID)
GO

-- Non-Clustered Index on Price: To speed up queries filtering or sorting by Price.
CREATE NONCLUSTERED INDEX INX_Products_Price
ON Products(Price)
GO

-- Recreate Foreign Key Constraint on OrderItems (ProductID Column)
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_Products
FOREIGN KEY (ProductID) REFERENCES Products(ProductID);
GO

/*
C. Indexes on Orders Table
	1. Clustered Index on OrderID: Usually created with the primary key.
	2. Non-Clustered Index on CustomerID: To speed up queries filtering by CustomerID.
	3. Non-Clustered Index on OrderDate: To speed up queries filtering or sorting by OrderDate.
*/

-- Drop Foreign Key Constraint from OrderItems Table - OrderID
ALTER TABLE OrderItems DROP CONSTRAINT FK__OrderItem__Order__30F848ED;

-- Non-Clustered Index on CustomerID: To speed up queries filtering by CustomerID.
CREATE NONCLUSTERED INDEX IDX_Orders_CustomerID
ON Orders(CustomerID);
GO

--  Non-Clustered Index on OrderDate: To speed up queries filtering or sorting by OrderDate.
CREATE NONCLUSTERED INDEX IDX_Orders_OrderDate
ON Orders(OrderDate);
GO

-- Recreate Foreign Key Constraint on OrderItems (OrderID Column)
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_OrderID_1234
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID);
GO

/*
D. Indexes on OrderItems Table
	1. Clustered Index on OrderItemID: Usually created with the primary key.
	2. Non-Clustered Index on OrderID: To speed up queries filtering by OrderID.
	3. Non-Clustered Index on ProductID: To speed up queries filtering by ProductID.
*/

-- Clustered Index on OrderItemID
CREATE CLUSTERED INDEX IDX_OrderItems_OrderItemID
ON OrderItems(OrderItemID);
GO

-- Non-Clustered Index on OrderID: To speed up queries filtering by OrderID.
CREATE NONCLUSTERED INDEX IDX_OrderItems_OrderID
ON OrderItems(OrderID);
GO

--  Non-Clustered Index on ProductID: To speed up queries filtering by ProductID.
CREATE NONCLUSTERED INDEX IDX_OrderItems_ProductID
ON OrderItems(ProductID);
GO


/*

E. Indexes on Customers Table
	1. Clustered Index on CustomerID: Usually created with the primary key.
	2. Non-Clustered Index on Email: To speed up queries filtering by Email.
	3. Non-Clustered Index on Country: To speed up queries filtering by Country.
*/

-- Drop Foreign Key Constraint from Orders Table - CustomerID
ALTER TABLE Orders DROP CONSTRAINT FK__Orders__Customer__403A8C7D;

-- Clustered Index on CustomerID
CREATE CLUSTERED INDEX IDX_Customers_CustomerID
ON Customers(CustomerID);
GO

-- Non-Clustered Index on Email: To speed up queries filtering by Email.
CREATE NONCLUSTERED INDEX IDX_Customers_Email
ON Customers(Email);
GO

--  Non-Clustered Index on Country: To speed up queries filtering by Country.
CREATE NONCLUSTERED INDEX IDX_Customers_Country
ON Customers(Country);
GO

-- Recreate Foreign Key Constraint on Orders (CustomerID Column)
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_CustomerID
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);
GO

/*
===============================
Implementing Views
===============================

	Views are virtual tables that represent the result of a query. 
	They can simplify complex queries and enhance security by restricting access to specific data.

*/

-- View for Product Details: A view combining product details with category names.
CREATE VIEW vw_ProductDetails
AS
SELECT p.productID, p.ProductName, p.Price, c.CategoryName
from Products p join Categories c
on p.CategoryID = c.CategoryID
GO

---display the product details with their categories:
select * from vw_ProductDetails

---view to get a summary of all orders placed by a customer:
CREATE VIEW vw_customerOrders 
AS
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(o.orderID) as Total_Orders, 
		sum(oi.Quantity * p.Price) as TotalAmount
FROM Customers c
JOIN Orders o on c.CustomerID = o.CustomerID
inner join OrderItems oi on o.OrderID = oi.OrderID
inner join Products p on oi.ProductID = p.ProductID
GROUP BY c.CustomerID, c.FirstName, c.LastName
GO

select * from  vw_customerOrders where TotalAmount > 100

-- View for Recent Orders: A view to display orders placed in the last 30 days.
CREATE VIEW vw_RecentOrders 
AS
SELECT o.OrderID, o.OrderDate, c.CustomerID, c.FirstName, c.LastName,
SUM(oi.Quantity * oi.Price) as OrderAmount
FROM Customers c 
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, o.OrderDate, c.CustomerID, c.FirstName, c.LastName;
GO

--Query 31: Retrieve All Products with Category Names
--Using the vw_ProductDetails view to get a list of all products along with their category names.
SELECT * FROM vw_ProductDetails;

--Query 32: Retrieve Products within a Specific Price Range
--Using the vw_ProductDetails view to find products priced between $100 and $500.
SELECT * FROM vw_ProductDetails WHERE Price BETWEEN 10 AND 500;

--Query 33: Count the Number of Products in Each Category
--Using the vw_ProductDetails view to count the number of products in each category.
SELECT CategoryName, Count(ProductID) AS ProductCount
FROM vw_ProductDetails GROUP BY CategoryName; 

--Query 34: Retrieve Customers with More Than 1 Orders
--Using the vw_CustomerOrders view to find customers who have placed more than 1 orders.
SELECT * FROM vw_CustomerOrders WHERE TotalOrders > 1;

--Query 35: Retrieve the Total Amount Spent by Each Customer
--Using the vw_CustomerOrders view to get the total amount spent by each customer.
SELECT CustomerID, FirstName, LastName, TotalAmount FROM vw_CustomerOrders
ORDER BY TotalAmount DESC;

--Query 36: Retrieve Recent Orders Above a Certain Amount
--Using the vw_RecentOrders view to find recent orders where the total amount is greater than $1000.
SELECT * FROM vw_RecentOrders WHERE OrderAmount > 1000;

--Query 37: Retrieve the Latest Order for Each Customer
--Using the vw_RecentOrders view to find the latest order placed by each customer.
SELECT ro.OrderID, ro.OrderDate, ro.CustomerID, ro.FirstName, ro.LastName, ro.OrderAmount
FROM vw_RecentOrders ro
INNER JOIN 
(SELECT CustomerID, Max(OrderDate) as LatestOrderDate FROM vw_RecentOrders GROUP BY CustomerID)
latest
ON ro.CustomerID = latest.CustomerID AND ro.OrderDate = latest.LatestOrderDate
ORDER BY ro.OrderDate DESC;
GO

--Query 38: Retrieve Products in a Specific Category
--Using the vw_ProductDetails view to get all products in a specific category, such as 'Electronics'.
SELECT * FROM vw_ProductDetails WHERE CategoryName = 'Books';

--Query 39: Retrieve Total Sales for Each Category
--Using the vw_ProductDetails and vw_CustomerOrders views to calculate the total sales for each category.
SELECT pd.CategoryName, SUM(oi.Quantity * p.Price) AS TotalSales
FROM OrderItems oi
INNER JOIN Products p ON oi.ProductID = p.ProductID
INNER JOIN vw_ProductDetails pd ON p.ProductID = pd.ProductID
GROUP BY pd.CategoryName
ORDER BY TotalSales DESC;

--Query 40: Retrieve Customer Orders with Product Details
--Using the vw_CustomerOrders and vw_ProductDetails views to get customer orders along with the details 
-- of the products ordered.
SELECT co.CustomerID, co.FirstName, co.LastName, o.OrderID, o.OrderDate,
pd.ProductName, oi.Quantity, pd.Price
FROM Orders o 
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
INNER JOIN vw_ProductDetails pd ON oi.ProductID = pd.ProductID
INNER JOIN vw_CustomerOrders co ON o.CustomerID = co.CustomerID
ORDER BY o.OrderDate DESC;

--Query 41: Retrieve Top 5 Customers by Total Spending
--Using the vw_CustomerOrders view to find the top 5 customers based on their total spending.
SELECT TOP 5 CustomerID, FirstName, LastName, TotalAmount 
FROM vw_CustomerOrders ORDER BY TotalAmount DESC;

--Query 42: Retrieve Products with Low Stock
--Using the vw_ProductDetails view to find products with stock below a certain threshold, such as 10 units.
SELECT pd.*, p.Stock
FROM vw_ProductDetails pd join Products p
on pd.ProductID = p.ProductID
where p.Stock < 10

--Query 43: Retrieve Orders Placed in the Last 7 Days
--Using the vw_RecentOrders view to find orders placed in the last 7 days.
SELECT * from vw_RecentOrders WHERE OrderDate >= DATEADD(DAY, -7, GETDATE());

--Query 44: Retrieve Products Sold in the Last Month
--Using the vw_RecentOrders view to find products sold in the last month.
SELECT p.ProductID, p.ProductName, SUM(oi.Quantity) AS TotalSold
FROM vw_RecentOrders ro
INNER JOIN OrderItems oi ON ro.OrderID = oi.OrderID
INNER JOIN Products p ON oi.ProductID = p.ProductID
WHERE ro.OrderDate >= DATEADD(MONTH, -1, GETDATE())
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSold DESC;


/*
=========================================================
Implementing Security / Role-Based Access Control (RBAC)
=========================================================

To manage access control in SQL Server, you'll need to use a combination of SQL Server's security features, 
such as logins, users, roles, and permissions. 

Here's a step-by-step guide on how to do this:

### Step 1: Create Logins
----------------------------------
			First, create logins at the SQL Server level. 
			Logins are used to authenticate users to the SQL Server instance.
*/
-- Create a login with SQL Server Authentication
CREATE LOGIN SeroneyUser WITH PASSWORD = 'strongpassword';

/*
### Step 2: Create Users
----------------------------------
			Next, create users in the `OnlineRetailDB` database for each login. 
			Users are associated with logins and are used to grant access to the database.
*/
USE OnlineRetailDB;
GO

-- Create a user in the database for the SQL Server Login
CREATE USER SeroneyUser FOR LOGIN SeroneyUser;


/*
### Step 3: Create Roles
----------------------------------
			Define roles in the database that will be used to group users with similar permissions. 
			This helps simplify permission management.
*/
-- Create roles in the database
CREATE ROLE SalesRole;
CREATE ROLE MarketingRole;

/*
### Step 4: Assign Users to Roles
----------------------------------
			Add the users to the appropriate roles.
*/
-- Add users to roles
EXEC sp_addrolemember 'SalesRole', 'SeroneyUser';

/*
### Step 5: Grant Permissions
----------------------------------
			Grant the necessary permissions to the roles based on the access requirements
*/
-- GRANT SELECT permission on the Customers Table to the SalesRole
GRANT SELECT ON Customers TO SalesRole;

-- GRANT INSERT permission on the Orders Table to the SalesRole
GRANT INSERT ON Orders TO SalesRole;

-- GRANT UPDATE permission on the Orders Table to the SalesRole
GRANT UPDATE ON Orders TO SalesRole;

-- GRANT SELECT permission on the Products Table to the SalesRole
GRANT SELECT ON Products TO SalesRole;

SELECT * FROM Customers;
DELETE FROM Customers;

SELECT * FROM Orders;
DELETE FROM Orders;
INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES (1, GETDATE(), 600);

SELECT * FROM Products;
DELETE FROM Products;


/*
### Step 6: Revoke Permissions (if needed)
----------------------------------
			If you need to revoke permissions, you can use the `REVOKE` statement.
*/
-- REVOKE INSERT permission on the Orders to the SalesRole
REVOKE INSERT ON Orders FROM SalesRole;

/* 
### Step 7: View Effective Permissions
----------------------------------
			You can view the effective permissions for a user using the query
--*/
----SELECT * FROM fn_my_permissions(NULL,'DATABASE');

----Summary
--==================
--	1. Create Logins: Authenticate users at the SQL Server level.
--	2. Create Users: Create users in the database for the logins.
--	3. Create Roles: Group users with similar permissions.
--	4. Assign Users to Roles: Add users to appropriate roles.
--	5. Grant Permissions: Grant necessary permissions to roles.
--	6. Revoke Permissions: Revoke permissions if needed.
--	7. View Effective Permissions: Check the effective permissions for users.
--	*/

--/*
--	Here are 20 different scenarios for access control in SQL Server. 
--	These scenarios cover various roles and permissions that can be assigned to users 
--	in the `OnlineRetailDB` database.
--*/

--- Scenario 1: Read-Only Access to All Tables
CREATE ROLE ReadOnlyRole;
GRANT SELECT ON SCHEMA::dbo TO ReadOnlyRole;

--- Scenario 2: Data Entry Clerk (Insert Only on Orders and OrderItems)
CREATE ROLE DataEntryClerk;
GRANT INSERT ON Orders TO DataEntryClerk;
GRANT INSERT ON OrderItems TO DataEntryClerk;

--- Scenario 3: Product Manager (Full Access to Products and Categories)
CREATE ROLE ProductManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO ProductManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Categories TO ProductManagerRole;

--- Scenario 4: Order Processor (Read and Update Orders)
CREATE ROLE OrderProcessorRole;
GRANT SELECT, UPDATE ON Orders TO OrderProcessorRole;

--- Scenario 5: Customer Support (Read Access to Customers and Orders)
CREATE ROLE CustomerSupportRole;
GRANT SELECT ON Customers TO CustomerSupportRole;
GRANT SELECT ON Orders TO CustomerSupportRole;

--- Scenario 6: Marketing Analyst (Read Access to All Tables, No DML)
CREATE ROLE MarketingAnalystRole;
GRANT SELECT ON SCHEMA::dbo TO MarketingAnalystRole;

--- Scenario 7: Sales Analyst (Read Access to Orders and OrderItems)
CREATE ROLE SalesAnalystRole;
GRANT SELECT ON Orders TO SalesAnalystRole;
GRANT SELECT ON OrderItems TO SalesAnalystRole;

--- Scenario 8: Inventory Manager (Full Access to Products)
CREATE ROLE InventoryManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO InventoryManagerRole;

--- Scenario 9: Finance Manager (Read and Update Orders)
CREATE ROLE FinanceManagerRole;
GRANT SELECT, UPDATE ON Orders TO FinanceManagerRole;

--- Scenario 10: Database Backup Operator (Backup Database)
CREATE ROLE BackupOperatorRole;
GRANT BACKUP DATABASE TO BackupOperatorRole;

--- Scenario 11: Database Developer (Full Access to Schema Objects)
CREATE ROLE DatabaseDeveloperRole;
GRANT CREATE TABLE, ALTER, DROP ON SCHEMA::dbo TO DatabaseDeveloperRole;

--- Scenario 12: Restricted Read Access (Read Only Specific Columns)
CREATE ROLE RestrictedReadRole;
GRANT SELECT (FirstName, LastName, Email) ON Customers TO RestrictedReadRole;

--- Scenario 13: Reporting User (Read Access to Views Only)
CREATE ROLE ReportingRole;
GRANT SELECT ON SalesReportView TO ReportingRole;
GRANT SELECT ON InventoryReportView TO ReportingRole;

--- Scenario 14: Temporary Access (Time-Bound Access)
-- Grant access
CREATE ROLE TempAccessRole;
GRANT SELECT ON SCHEMA::dbo TO TempAccessRole;

-- Revoke access after the specified period
REVOKE SELECT ON SCHEMA::dbo FROM TempAccessRole;

--- Scenario 15: External Auditor (Read Access with No Data Changes)
CREATE ROLE AuditorRole;
GRANT SELECT ON SCHEMA::dbo TO AuditorRole;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO AuditorRole;

--- Scenario 16: Application Role (Access Based on Application)
CREATE APPLICATION ROLE AppRole WITH PASSWORD = 'StrongPassword1';
GRANT SELECT, INSERT, UPDATE ON Orders TO AppRole;

--- Scenario 17: Role-Based Access Control (RBAC) for Multiple Roles 
-- Combine roles
CREATE ROLE CombinedRole;
EXEC sp_addrolemember 'SalesRole', 'CombinedRole';
EXEC sp_addrolemember 'MarketingRole', 'CombinedRole';

--- Scenario 18: Sensitive Data Access (Column-Level Permissions)
CREATE ROLE SensitiveDataRole;
GRANT SELECT (Email, Phone) ON Customers TO SensitiveDataRole;

--- Scenario 19: Developer Role (Full Access to Development Database)
CREATE ROLE DevRole;
GRANT CONTROL ON DATABASE::OnlineRetailDB TO DevRole;

--- Scenario 20: Security Administrator (Manage Security Privileges)
CREATE ROLE SecurityAdminRole;
GRANT ALTER ANY LOGIN TO SecurityAdminRole;
GRANT ALTER ANY USER TO SecurityAdminRole;
GRANT ALTER ANY ROLE TO SecurityAdminRole;
