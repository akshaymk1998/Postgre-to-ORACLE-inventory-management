
--IN ORACLE CREATE THE TABLES
|--------------------------------------------------------------------------------------------------|
-- sqlldr userid=akshay/amk@//localhost:1521/orclpdb control="C:\Users\aksha\Downloads\data_load.txt" log="C:\Users\aksha\Downloads\load.log"
 
CREATE TABLE master_order_inventory
( order_id	NUMBER,
order_date	date,
status	    varchar(20),
customer_name	varchar(200),
customer_email	varchar(200),
product_name	varchar(200),
category_name	varchar(200),
supplier_name	varchar(200),
quantity	    number,
unit_price	    number(10,2),
line_total	    NUMBER,
payment_amount	number(10,2),
payment_method	varchar(25),
shipped_date	DATE,
tracking_number	varchar(200),
return_reason	varchar(200),
return_date	    DATE,
warehouse_name	varchar(200),
warehouse_location	varchar(200),
stock_level     NUMBER
);

select * from  master_order_inventory ;

|--------------------------------------------------------------------------------------------------|
-- sqlldr userid=akshay/amk@//localhost:1521/orclpdb control="C:\Users\aksha\Downloads\data_load.txt" log="C:\Users\aksha\Downloads\load.log"

CREATE  TABLE master_order_inventory
( order_id	NUMBER,
order_date	varchar(200),
status	    varchar(20),
customer_name	varchar(200),
customer_email	varchar(200),
product_name	varchar(200),
category_name	varchar(200),
supplier_name	varchar(200),
quantity	    number,
unit_price	    number(10,2),
line_total	    NUMBER,
payment_amount	number(10,2),
payment_method	varchar(25),
shipped_date	varchar(200),
tracking_number	varchar(200),
return_reason	varchar(200),
return_date	    varchar(200),
warehouse_name	varchar(200),
warehouse_location	varchar(200),
stock_level     NUMBER
);

select * from  master_order_inventory ;
|--------------------------------------------------------------------------------------------------|
CREATE TABLE employee_department 
(employee_id number,
first_name varchar(100),
last_name varchar(100),
email varchar(150),
department_name varchar(100),
region_name varchar(100));

select * from  employee_department ;
|--------------------------------------------------------------------------------------------------|
create table inventory_warehouse  
(warehouse_name varchar(100),
location varchar(150), 
product_name varchar(150),
category_name varchar(100),
stock_level number);

SELECT * FROM inventory_warehouse;
|--------------------------------------------------------------------------------------------------|    
 CREATE TABLE order_summary 
( order_id number,
order_date varchar(100),
status varchar(20), 
customer_name VARCHAR(200),
product_name varchar(150),
category_name varchar(150),
supplier_name varchar(150),
quantity NUMBER, 
unit_price NUMBER(10,2),
line_total NUMBER(10,2),
payment_amount NUMBER(10,2),
payment_method varchar(20),
shipped_date varchar(20) ,
tracking_number varchar(50),
return_reason VARCHAR(200));

SELECT * FROM   order_summary;
|--------------------------------------------------------------------------------------------------|
CREATE TABLE product_reviews
(
product_name VARCHAR(150), 
customer_name VARCHAR(200),
rating NUMBER, 
--comments VARCHAR(500)
);
|--------------------------------------------------------------------------------------------------|


|---------------------------------------PL/SQL CREATED---------------------------------------------|
CREATE OR REPLACE PROCEDURE create_and_merge_all_data IS
BEGIN
    -- Drop the consolidated table if it already exists
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE all_data_summary CASCADE CONSTRAINTS';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -942 THEN -- ignore "table does not exist"
                RAISE;
            END IF;
    END;

    -- Create the consolidated table
    EXECUTE IMMEDIATE '
        CREATE TABLE all_data_summary (
            source_table       VARCHAR2(50),
            order_id           NUMBER,
            order_date         VARCHAR2(100),
            status             VARCHAR2(50),
            customer_name      VARCHAR2(200),
            customer_email     VARCHAR2(200),
            product_name       VARCHAR2(200),
            category_name      VARCHAR2(200),
            supplier_name      VARCHAR2(200),
            quantity           NUMBER,
            unit_price         NUMBER(10,2),
            line_total         NUMBER(10,2),
            payment_amount     NUMBER(10,2),
            payment_method     VARCHAR2(50),
            shipped_date       VARCHAR2(100),
            tracking_number    VARCHAR2(200),
            return_reason      VARCHAR2(200),
            return_date        VARCHAR2(100),
            warehouse_name     VARCHAR2(200),
            warehouse_location VARCHAR2(200),
            stock_level        NUMBER,
            department_name    VARCHAR2(200),
            region_name        VARCHAR2(200),
            rating             NUMBER
        )
    ';

    -- Merge from order_summary
    INSERT INTO all_data_summary (
        source_table, order_id, order_date, status, customer_name,
        product_name, category_name, supplier_name, quantity, unit_price,
        line_total, payment_amount, payment_method, shipped_date,
        tracking_number, return_reason
    )
    SELECT 'ORDER_SUMMARY', order_id, order_date, status, customer_name,
           product_name, category_name, supplier_name, quantity, unit_price,
           line_total, payment_amount, payment_method, shipped_date,
           tracking_number, return_reason
    FROM order_summary;

    -- Merge from employee_department
    INSERT INTO all_data_summary (
        source_table, customer_name, customer_email, department_name, region_name
    )
    SELECT 'EMPLOYEE_DEPARTMENT',
           first_name || ' ' || last_name,
           email,
           department_name,
           region_name
    FROM employee_department;

    -- Merge from inventory_warehouse
    INSERT INTO all_data_summary (
        source_table, warehouse_name, warehouse_location,
        product_name, category_name, stock_level
    )
    SELECT 'INVENTORY_WAREHOUSE',
           warehouse_name, location,
           product_name, category_name, stock_level
    FROM inventory_warehouse;

    -- Merge from product_reviews
    INSERT INTO all_data_summary (
        source_table, product_name, customer_name, rating
    )
    SELECT 'PRODUCT_REVIEWS',
           product_name, customer_name, rating
    FROM product_reviews;

    COMMIT;
END;
/

EXEC create_and_merge_all_data;

SELECT * FROM all_data_summary;

|---------------------------------------PL/SQL CREATED---------------------------------------------|