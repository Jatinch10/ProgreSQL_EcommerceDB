# Advanced E-Commerce Database Project

This PostgreSQL project simulates an e-commerce platform, featuring user management, product catalogs, orders, payments, shipping, reviews, and advanced features like triggers, stored procedures, and views.

## Features
- **Users**: Manages customers and admins.
- **Orders**: Tracks customer orders.
- **Payments**: Processes payments for orders.
- **Shipping**: Tracks order shipments.
- **Reviews**: Allows customers to review products.
- **Advanced Features**:
  - **Triggers**: Updates product stock when an order is placed.
  - **Stored Procedures**: Generate customer reports dynamically.
  - **Views**: Simplifies complex queries for analytics.
  - **Indexes**: Optimizes query performance for frequent searches.

## Setup
1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/yourrepository.git
    ```
2. Set up PostgreSQL and create a database.
3. Run the SQL scripts provided to create tables and insert sample data.
4. Test the project by running queries against the database.

## Example Queries
- Generate a customer report:
  ```sql
  SELECT * FROM generate_customer_report(1);
