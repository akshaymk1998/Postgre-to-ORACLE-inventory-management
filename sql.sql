|-------------------------------------CREATE TABLES AND DATABASE-------------------------------------|

CREATE DATABASE inventory_db;

CREATE SCHEMA inventory AUTHORIZATION postgres;

SELECT current_database();

-- Categories
CREATE TABLE inventory.categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

-- Suppliers
CREATE TABLE inventory.suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(150),
    contact_email VARCHAR(100)
);

-- Products
CREATE TABLE inventory.products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(150),
    category_id INT REFERENCES inventory.categories(category_id),
    supplier_id INT REFERENCES inventory.suppliers(supplier_id),
    unit_price NUMERIC(10,2),
    stock_quantity INT
);

-- Customers
CREATE TABLE inventory.customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150),
    phone VARCHAR(20)
);

-- Orders
CREATE TABLE inventory.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES inventory.customers(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20)
);

-- Order Items
CREATE TABLE inventory.order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES inventory.orders(order_id),
    product_id INT REFERENCES inventory.products(product_id),
    quantity INT,
    unit_price NUMERIC(10,2)
);

-- Payments
CREATE TABLE inventory.payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES inventory.orders(order_id),
    payment_date TIMESTAMP,
    amount NUMERIC(10,2),
    method VARCHAR(20)
);

-- Employees
CREATE TABLE inventory.employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    department_id INT REFERENCES inventory.departments(department_id),
    email VARCHAR(150)
);

-- Departments
CREATE TABLE inventory.departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100)
);

-- Shipments
CREATE TABLE inventory.shipments (
    shipment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES inventory.orders(order_id),
    shipped_date TIMESTAMP,
    tracking_number VARCHAR(50)
);

-- Warehouses
CREATE TABLE inventory.warehouses (
    warehouse_id SERIAL PRIMARY KEY,
    warehouse_name VARCHAR(100),
    location VARCHAR(150)
);

-- Inventory
CREATE TABLE inventory.inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES inventory.products(product_id),
    warehouse_id INT REFERENCES inventory.warehouses(warehouse_id),
    stock_level INT
);

-- Returns
CREATE TABLE inventory.returns (
    return_id SERIAL PRIMARY KEY,
    order_item_id INT REFERENCES inventory.order_items(order_item_id),
    return_date TIMESTAMP,
    reason VARCHAR(200)
);

-- Reviews
CREATE TABLE inventory.reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES inventory.products(product_id),
    customer_id INT REFERENCES inventory.customers(customer_id),
    rating INT,
    comment TEXT
);

-- Regions
CREATE TABLE inventory.regions (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(100)
);

create python script to dump dummy data in 
in tables





|------------------------------------CREATE VIEWS---------------------------------------|
CREATE OR REPLACE VIEW inventory.master_order_inventory AS
SELECT 
    o.order_id,
    o.order_date,
    o.status,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email AS customer_email,
    p.product_name,
    cat.category_name,
    s.supplier_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total,
    pay.amount AS payment_amount,
    pay.method AS payment_method,
    sh.shipped_date,
    sh.tracking_number,
    r.reason AS return_reason,
    r.return_date,
    w.warehouse_name,
    w.location AS warehouse_location,
    inv.stock_level
FROM inventory.orders o
JOIN inventory.customers c ON o.customer_id = c.customer_id
JOIN inventory.order_items oi ON o.order_id = oi.order_id
JOIN inventory.products p ON oi.product_id = p.product_id
JOIN inventory.categories cat ON p.category_id = cat.category_id
JOIN inventory.suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN inventory.payments pay ON o.order_id = pay.order_id
LEFT JOIN inventory.shipments sh ON o.order_id = sh.order_id
LEFT JOIN inventory.returns r ON oi.order_item_id = r.order_item_id
LEFT JOIN inventory.inventory inv ON p.product_id = inv.product_id
LEFT JOIN inventory.warehouses w ON inv.warehouse_id = w.warehouse_id;

----------------------------------------------------------------------------------------|
CREATE OR REPLACE VIEW inventory.v_order_summary AS
SELECT 
    o.order_id,
    o.order_date,
    o.status,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_name,
    cat.category_name,
    s.supplier_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total,
    pay.amount AS payment_amount,
    pay.method AS payment_method,
    sh.shipped_date,
    sh.tracking_number,
    r.reason AS return_reason
FROM inventory.orders o
JOIN inventory.customers c ON o.customer_id = c.customer_id
JOIN inventory.order_items oi ON o.order_id = oi.order_id
JOIN inventory.products p ON oi.product_id = p.product_id
JOIN inventory.categories cat ON p.category_id = cat.category_id
JOIN inventory.suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN inventory.payments pay ON o.order_id = pay.order_id
LEFT JOIN inventory.shipments sh ON o.order_id = sh.order_id
LEFT JOIN inventory.returns r ON oi.order_item_id = r.order_item_id;
---------------------------------------------------------------------------------------|
CREATE OR REPLACE VIEW inventory.v_inventory_warehouse AS
SELECT 
    w.warehouse_name,
    w.location,
    p.product_name,
    cat.category_name,
    inv.stock_level
FROM inventory.inventory inv
JOIN inventory.products p ON inv.product_id = p.product_id
JOIN inventory.categories cat ON p.category_id = cat.category_id
JOIN inventory.warehouses w ON inv.warehouse_id = w.warehouse_id;
---------------------------------------------------------------------------------------|
CREATE OR REPLACE VIEW inventory.v_employee_department AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    d.department_name,
    r.region_name
FROM inventory.employees e
JOIN inventory.departments d ON e.department_id = d.department_id
LEFT JOIN inventory.regions r ON d.department_id = r.region_id; -- adjust if region-department mapping differs
---------------------------------------------------------------------------------------|
CREATE OR REPLACE VIEW inventory.v_product_reviews AS
SELECT 
    p.product_name,
    c.first_name || ' ' || c.last_name AS customer_name,
    r.rating,
    r.comment
FROM inventory.reviews r
JOIN inventory.products p ON r.product_id = p.product_id
JOIN inventory.customers c ON r.customer_id = c.customer_id;
---------------------------------------------------------------------------------------|
--####################################################################################--

|----------------------------------PYTHON RANDOM SCRIPT--------------------------------|

install python
(python manahger)

cmd/bash
command
pip install psycopg2 faker
o/p
Microsoft Windows [Version 10.0.26200.8246]
(c) Microsoft Corporation. All rights reserved.

C:\Users\aksha>pip install psycopg2 faker
Collecting psycopg2
  Downloading psycopg2-2.9.12-cp314-cp314-win_amd64.whl.metadata (5.1 kB)
Collecting faker
  Downloading faker-40.19.1-py3-none-any.whl.metadata (16 kB)
Collecting tzdata (from faker)
  Downloading tzdata-2026.2-py2.py3-none-any.whl.metadata (1.4 kB)
Downloading psycopg2-2.9.12-cp314-cp314-win_amd64.whl (2.8 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.8/2.8 MB 8.7 MB/s  0:00:00
Downloading faker-40.19.1-py3-none-any.whl (2.0 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.0/2.0 MB 9.4 MB/s  0:00:00
Downloading tzdata-2026.2-py2.py3-none-any.whl (349 kB)
Installing collected packages: tzdata, psycopg2, faker
   ━━━━━━━━━━━━━━━━━━━━━━━━━━╸━━━━━━━━━━━━━ 2/3 [faker]  WARNING: The script faker.exe is installed in 'C:\Users\aksha\AppData\Local\Python\pythoncore-3.14-64\Scripts' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
Successfully installed faker-40.19.1 psycopg2-2.9.12 tzdata-2026.2

what we will get
--psycopg2 → lets Python connect to PostgreSQL.

--faker → generates fake data for your tables.
import psycopg2
from faker import Faker
import random

faker = Faker()

conn = psycopg2.connect(
    dbname="inventory_db",
    user="postgres",
    password="1234",   # replace with your actual password
    host="localhost",
    port="5432"
)
cur = conn.cursor()

# --- Parent tables first ---

# Categories
for _ in range(20):
    cur.execute("INSERT INTO inventory.categories (category_name) VALUES (%s)", (faker.word(),))
cur.execute("SELECT category_id FROM inventory.categories")
category_ids = [row[0] for row in cur.fetchall()]

# Suppliers
for _ in range(200):
    cur.execute("INSERT INTO inventory.suppliers (supplier_name, contact_email) VALUES (%s, %s)",
                (faker.company()[:150], faker.email()[:100]))
cur.execute("SELECT supplier_id FROM inventory.suppliers")
supplier_ids = [row[0] for row in cur.fetchall()]

# Customers
for _ in range(10000):
    cur.execute("""INSERT INTO inventory.customers 
                   (first_name, last_name, email, phone) 
                   VALUES (%s, %s, %s, %s)""",
                (faker.first_name()[:100], faker.last_name()[:100],
                 faker.email()[:150], faker.phone_number()[:20]))
cur.execute("SELECT customer_id FROM inventory.customers")
customer_ids = [row[0] for row in cur.fetchall()]

# Departments
for _ in range(50):
    cur.execute("INSERT INTO inventory.departments (department_name) VALUES (%s)", (faker.job()[:100],))
cur.execute("SELECT department_id FROM inventory.departments")
department_ids = [row[0] for row in cur.fetchall()]

# Warehouses
for _ in range(100):
    cur.execute("INSERT INTO inventory.warehouses (warehouse_name, location) VALUES (%s, %s)",
                (faker.company()[:100], faker.city()[:150]))
cur.execute("SELECT warehouse_id FROM inventory.warehouses")
warehouse_ids = [row[0] for row in cur.fetchall()]

# Regions
for _ in range(50):
    cur.execute("INSERT INTO inventory.regions (region_name) VALUES (%s)", (faker.state()[:100],))
cur.execute("SELECT region_id FROM inventory.regions")
region_ids = [row[0] for row in cur.fetchall()]

conn.commit()

# --- Child tables using valid IDs ---

# Products
for _ in range(10000):
    cur.execute("""INSERT INTO inventory.products 
                   (product_name, category_id, supplier_id, unit_price, stock_quantity) 
                   VALUES (%s, %s, %s, %s, %s)""",
                (faker.word()[:150], random.choice(category_ids), random.choice(supplier_ids),
                 round(random.uniform(10, 500), 2), random.randint(1, 100)))
cur.execute("SELECT product_id FROM inventory.products")
product_ids = [row[0] for row in cur.fetchall()]

# Employees
for _ in range(2000):
    cur.execute("""INSERT INTO inventory.employees 
                   (first_name, last_name, department_id, email) 
                   VALUES (%s, %s, %s, %s)""",
                (faker.first_name()[:100], faker.last_name()[:100],
                 random.choice(department_ids), faker.email()[:150]))

# Orders
for _ in range(10000):
    cur.execute("""INSERT INTO inventory.orders 
                   (customer_id, order_date, status) 
                   VALUES (%s, %s, %s)""",
                (random.choice(customer_ids), faker.date_time_this_year(),
                 random.choice(["Pending", "Shipped", "Delivered", "Cancelled"])))
cur.execute("SELECT order_id FROM inventory.orders")
order_ids = [row[0] for row in cur.fetchall()]

# Order Items
for _ in range(10000):
    cur.execute("""INSERT INTO inventory.order_items 
                   (order_id, product_id, quantity, unit_price) 
                   VALUES (%s, %s, %s, %s)""",
                (random.choice(order_ids), random.choice(product_ids),
                 random.randint(1, 10), round(random.uniform(10, 500), 2)))
cur.execute("SELECT order_item_id FROM inventory.order_items")
order_item_ids = [row[0] for row in cur.fetchall()]

# Payments
for _ in range(5000):
    cur.execute("""INSERT INTO inventory.payments 
                   (order_id, payment_date, amount, method) 
                   VALUES (%s, %s, %s, %s)""",
                (random.choice(order_ids), faker.date_time_this_year(),
                 round(random.uniform(50, 1000), 2), random.choice(["Card", "Cash", "UPI", "NetBanking"])))

# Inventory
for _ in range(5000):
    cur.execute("""INSERT INTO inventory.inventory 
                   (product_id, warehouse_id, stock_level) 
                   VALUES (%s, %s, %s)""",
                (random.choice(product_ids), random.choice(warehouse_ids), random.randint(1, 200)))

# Shipments
for _ in range(5000):
    cur.execute("""INSERT INTO inventory.shipments 
                   (order_id, shipped_date, tracking_number) 
                   VALUES (%s, %s, %s)""",
                (random.choice(order_ids), faker.date_time_this_year(), str(faker.uuid4())[:50]))

# Returns
for _ in range(2000):
    cur.execute("""INSERT INTO inventory.returns 
                   (order_item_id, return_date, reason) 
                   VALUES (%s, %s, %s)""",
                (random.choice(order_item_ids), faker.date_time_this_year(), faker.sentence()[:200]))

# Reviews
for _ in range(5000):
    cur.execute("""INSERT INTO inventory.reviews 
                   (product_id, customer_id, rating, comment) 
                   VALUES (%s, %s, %s, %s)""",
                (random.choice(product_ids), random.choice(customer_ids),
                 random.randint(1, 5), faker.text()[:500]))

conn.commit()
cur.close()
conn.close()
print("50k+ dummy records inserted successfully without FK or length errors!")


CMD/BASH >> PYTHON PATH FOR THE PYTHON SCRIPT

C:\Users\aksha>python "D:\postgress py and table datasets\populate_inventory2.py"
50k+ dummy records inserted successfully without FK or length errors!


|---------------------------------------------DUMPED DATA------------------------------------------------|