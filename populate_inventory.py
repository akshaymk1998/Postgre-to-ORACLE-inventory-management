from faker import Faker
import psycopg2
import random
from datetime import datetime

fake = Faker()

conn = psycopg2.connect(
    dbname="inventory_db",
    user="postgres",
    password="yourpassword",
    host="localhost",
    port="5432"
)
cur = conn.cursor()

# --- Categories ---
for _ in range(20):
    cur.execute("INSERT INTO categories (category_name) VALUES (%s)", (fake.word(),))

# --- Suppliers ---
for _ in range(50):
    cur.execute("INSERT INTO suppliers (supplier_name, contact_email) VALUES (%s, %s)",
                (fake.company(), fake.email()))

# --- Products ---
for _ in range(5000):
    cur.execute("""
        INSERT INTO products (product_name, category_id, supplier_id, unit_price, stock_quantity)
        VALUES (%s, %s, %s, %s, %s)
    """, (
        fake.word(),
        random.randint(1, 20),
        random.randint(1, 50),
        round(random.uniform(10, 500), 2),
        random.randint(1, 1000)
    ))

# --- Customers ---
for _ in range(10000):
    cur.execute("""
        INSERT INTO customers (first_name, last_name, email, phone)
        VALUES (%s, %s, %s, %s)
    """, (fake.first_name(), fake.last_name(), fake.email(), fake.phone_number()))

# --- Departments ---
for _ in range(10):
    cur.execute("INSERT INTO departments (department_name) VALUES (%s)", (fake.job(),))

# --- Employees ---
for _ in range(200):
    cur.execute("""
        INSERT INTO employees (first_name, last_name, department_id, email)
        VALUES (%s, %s, %s, %s)
    """, (
        fake.first_name(),
        fake.last_name(),
        random.randint(1, 10),
        fake.email()
    ))

# --- Orders ---
for _ in range(15000):
    cur.execute("""
        INSERT INTO orders (customer_id, order_date, status)
        VALUES (%s, %s, %s)
    """, (
        random.randint(1, 10000),
        fake.date_time_this_year(),
        random.choice(["Pending", "Shipped", "Delivered", "Cancelled"])
    ))

# --- Order Items ---
for _ in range(30000):
    cur.execute("""
        INSERT INTO order_items (order_id, product_id, quantity, unit_price)
        VALUES (%s, %s, %s, %s)
    """, (
        random.randint(1, 15000),
        random.randint(1, 5000),
        random.randint(1, 10),
        round(random.uniform(10, 500), 2)
    ))

# --- Payments ---
for _ in range(12000):
    cur.execute("""
        INSERT INTO payments (order_id, payment_date, amount, method)
        VALUES (%s, %s, %s, %s)
    """, (
        random.randint(1, 15000),
        fake.date_time_this_year(),
        round(random.uniform(50, 2000), 2),
        random.choice(["Card", "Cash", "UPI", "NetBanking"])
    ))

# --- Shipments ---
for _ in range(8000):
    cur.execute("""
        INSERT INTO shipments (order_id, shipped_date, tracking_number)
        VALUES (%s, %s, %s)
    """, (
        random.randint(1, 15000),
        fake.date_time_this_year(),
        fake.uuid4()
    ))

# --- Warehouses ---
for _ in range(20):
    cur.execute("INSERT INTO warehouses (warehouse_name, location) VALUES (%s, %s)",
                (fake.company(), fake.city()))

# --- Inventory ---
for _ in range(10000):
    cur.execute("""
        INSERT INTO inventory (product_id, warehouse_id, stock_level)
        VALUES (%s, %s, %s)
    """, (
        random.randint(1, 5000),
        random.randint(1, 20),
        random.randint(1, 500)
    ))

# --- Returns ---
for _ in range(2000):
    cur.execute("""
        INSERT INTO returns (order_item_id, return_date, reason)
        VALUES (%s, %s, %s)
    """, (
        random.randint(1, 30000),
        fake.date_time_this_year(),
        random.choice(["Damaged", "Wrong Item", "Customer Dissatisfaction"])
    ))

# --- Reviews ---
for _ in range(5000):
    cur.execute("""
        INSERT INTO reviews (product_id, customer_id, rating, comment)
        VALUES (%s, %s, %s, %s)
    """, (
        random.randint(1, 5000),
        random.randint(1, 10000),
        random.randint(1, 5),
        fake.sentence()
    ))

# --- Regions ---
for _ in range(10):
    cur.execute("INSERT INTO regions (region_name) VALUES (%s)", (fake.state(),))

conn.commit()
cur.close()
conn.close()
