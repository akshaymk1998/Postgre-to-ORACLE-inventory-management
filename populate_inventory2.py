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
