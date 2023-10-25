use [Datawarehouse Northwind]
go

-- Create the Customers table
CREATE TABLE dbo.customer_dim
(
    customer_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    customer_id nchar(10) NOT NULL,
    company_name nvarchar(40) NOT NULL,
    contact_name nvarchar(30),
    contact_title nvarchar(30)
);
-- Create the date_dim table
CREATE TABLE dbo.date_dim
(
    date_key INT NOT NULL PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter INT,
    quarter_name VARCHAR(20),
    month INT,
    month_name VARCHAR(20),
    week INT,
    day INT,
    day_name VARCHAR(9)
);

-- Create the employee dimension table
CREATE TABLE dbo.employee_dim
(	employee_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	employee_id int NOT NULL,
    first_name nvarchar(10) NOT NULL,
	last_name nvarchar(20) NOT NULL,
    title nvarchar(30),
	TitleOfCourtesy nvarchar(25),
    birth_date DATETIME,
    hire_date DATETIME,
    address nvarchar(60),
    city nvarchar(15),
    region nvarchar(15),
    country nvarchar(15),
	postal_code nvarchar(10),
    reports_to SMALLINT
);

-- Create the products Dimension table
CREATE TABLE dbo.product_dim
(
    product_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    product_id int NOT NULL,
    product_name nvarchar(40) NOT NULL,
	quantity_per_unit nvarchar(20),
    unit_price REAL,
	units_in_stock SMALLINT,
	units_on_order SMALLINT,
	ReorderLevel smallint,
    Discontinued smallint, 
    category_name nvarchar(15) NOT NULL
);


-- Create the suppliers Dimension table 
CREATE TABLE dbo.supplier_dim
(
    supplier_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    supplier_id int NOT NULL,
    company_name nvarchar(40) NOT NULL,
    contact_title nvarchar(30),
    address nvarchar(60),
    city nvarchar(15),
    region nvarchar(15),
    country nvarchar(15),
	postal_code nvarchar(10)
);

-- Create the Shipper dimension table
CREATE TABLE dbo.shipper_dim
(
    shipper_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    shipper_id int NOT NULL,
    company_name nvarchar(40) NOT NULL,
);


-- Create the ship_info dimension table
CREATE TABLE dbo.ship_info
(
    shipinfo_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    customer_key INT,
    ship_address nvarchar(60),
    ship_city nvarchar(15),
    ship_region nvarchar(15),
    ship_country nvarchar(15)
);

-- Create the orders fact table
CREATE TABLE dbo.orders_fact
(
    order_key INT IDENTITY(1,1) NOT NULL ,
	orderID INT NOT NULL ,
    employee_key INT NOT NULL,
    shipper_key INT NOT NULL,
    customer_key INT NOT NULL,
    supplier_key INT NOT NULL,
    product_key INT NOT NULL,
    shipinfo_key INT NOT NULL,
	order_date int NOT NULL,
    required_date int NOT NULL,
    shipped_date int NOT NULL,
    freight REAL,
    unit_price REAL,
    quantity INT,
    discount REAL,
    actual_cost REAL
	);

ALTER table dbo.orders_fact add constraint PK_Fact_order primary key(order_key,orderID,employee_key,shipper_key,customer_key,
																	supplier_key,product_key,shipinfo_key,order_date,
																	required_date,shipped_date)

-- Add Foreign Key Constraints
ALTER TABLE dbo.orders_fact
    ADD CONSTRAINT FK_orders_fact_customer_key FOREIGN KEY (customer_key)
    REFERENCES dbo.customer_dim (customer_key);

ALTER TABLE dbo.orders_fact
    ADD CONSTRAINT FK_orders_fact_employee_key FOREIGN KEY (employee_key)
    REFERENCES dbo.employee_dim (employee_key);

ALTER TABLE dbo.orders_fact
    ADD CONSTRAINT FK_orders_fact_product_key FOREIGN KEY (product_key)
    REFERENCES dbo.product_dim (product_key);

ALTER TABLE dbo.orders_fact
    ADD CONSTRAINT FK_orders_fact_supplier_key FOREIGN KEY (supplier_key)
    REFERENCES dbo.supplier_dim (supplier_key);

ALTER TABLE dbo.orders_fact
    ADD CONSTRAINT FK_orders_fact_shipper_key FOREIGN KEY (shipper_key)
    REFERENCES dbo.shipper_dim (shipper_key);

ALTER TABLE dbo.orders_fact
    ADD CONSTRAINT FK_orders_fact_shipinfo_key FOREIGN KEY (shipinfo_key)
    REFERENCES dbo.ship_info (shipinfo_key);

alter table dbo.orders_fact
	add constraint FK_fact_orderDate_key foreign key (order_date)
	references dbo.date_dim (date_key);

ALTER TABLE dbo.orders_fact
    ADD CONSTRAINT FK_fact_requiredDate_key FOREIGN KEY (required_date)
    REFERENCES dbo.date_dim (date_key);


ALTER TABLE dbo.orders_fact
    ADD CONSTRAINT FK_fact_shippedDate_key FOREIGN KEY (shipped_date)
    REFERENCES dbo.date_dim (date_key);

ALTER TABLE dbo.ship_info
    ADD CONSTRAINT FK_ship_info_customer_key FOREIGN KEY (customer_key)
    REFERENCES dbo.customer_dim (customer_key);

/* population of Date dimension */

DECLARE @StartDate DATE = '1996-07-04';  --the first order placed  date 
DECLARE @EndDate DATE = '2030-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    DECLARE @DateKey INT = CONVERT(INT, FORMAT(@StartDate, 'yyyyMMdd'));

    INSERT INTO date_dim (date_key, full_date, year, quarter, quarter_name, month, month_name, week, day, day_name)
    VALUES (
        @DateKey,
        @StartDate,
        DATEPART(YEAR, @StartDate),
        DATEPART(QUARTER, @StartDate),
        'Q' + CAST(DATEPART(QUARTER, @StartDate) AS VARCHAR(2)),
        DATEPART(MONTH, @StartDate),
        DATENAME(MONTH, @StartDate),
        DATEPART(WEEK, @StartDate),
        DATEPART(DAY, @StartDate),
        DATENAME(WEEKDAY, @StartDate)
    );

    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;


