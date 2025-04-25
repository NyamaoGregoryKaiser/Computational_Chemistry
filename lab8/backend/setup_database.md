# Database Setup Instructions

This document explains how to set up the MySQL database for the Health Information System.

## Prerequisites

- WAMP Server installed and running
- MySQL server running
- Django project code available

## Option 1: Using the SQL Script

1. Open phpMyAdmin in your web browser (typically at http://localhost/phpmyadmin)
2. Log in with your credentials (default: username 'root' with no password)
3. Click on the "SQL" tab
4. Copy the contents of `database_setup.sql` into the SQL query box
5. Click "Go" to execute the script

This will:
- Create the database if it doesn't exist
- Create all necessary tables
- Populate the tables with test data

## Option 2: Using Django Migrations

1. Make sure WAMP server is running
2. Create the database manually using phpMyAdmin:
   - Click "New" in the left sidebar
   - Enter "health_info_system" as the database name
   - Click "Create"

3. Open a terminal and navigate to the project directory:
   ```
   cd lab8/backend
   ```

4. Create migrations for all apps:
   ```
   python manage.py makemigrations api users
   ```

5. Apply the migrations to create database tables:
   ```
   python manage.py migrate
   ```

6. Create a superuser to access the admin interface:
   ```
   python manage.py createsuperuser
   ```

7. Load test data (if you've created fixtures):
   ```
   python manage.py loaddata sample_data
   ```

## Option 3: Hybrid Approach

1. Create the database using phpMyAdmin as in Option 2
2. Run migrations to create tables:
   ```
   python manage.py migrate
   ```
3. Use SQL commands to insert test data:
   ```
   python manage.py dbshell < test_data.sql
   ```

## Accessing the Data

After setup, you can:
- Use phpMyAdmin to browse and manage the data
- Access the data through the Django admin interface at `http://localhost:8000/admin/`
- Access the API endpoints to work with the data programmatically

## Default User Credentials

The test data includes several pre-created users:

| Username | Email | Password | Role |
|----------|-------|----------|------|
| admin | admin@example.com | admin123 | Administrator |
| doctor1 | jsmith@example.com | doctor123 | Doctor |
| doctor2 | mjohnson@example.com | doctor123 | Doctor |
| doctor3 | rwilliams@example.com | doctor123 | Doctor |
| staff1 | sdavis@example.com | staff123 | Staff | 