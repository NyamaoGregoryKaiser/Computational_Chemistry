# Health Information System Database Schema

## Overview

This document describes the database schema for the Health Information System. The system uses MySQL as the database engine and consists of several tables to manage clients, health programs, and their relationships.

## Tables

### Health Programs (`api_healthprogram`)

Stores information about health programs available in the system.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key, auto-increment |
| name | VARCHAR(100) | Name of the health program |
| description | TEXT | Detailed description of the program |
| created_at | DATETIME | When the program was created |
| updated_at | DATETIME | When the program was last updated |

### Clients (`api_client`)

Stores information about clients registered in the system.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key, auto-increment |
| first_name | VARCHAR(100) | Client's first name |
| last_name | VARCHAR(100) | Client's last name |
| date_of_birth | DATE | Client's date of birth |
| gender | VARCHAR(1) | Client's gender ('M', 'F', or 'O') |
| phone_number | VARCHAR(15) | Client's phone number (optional) |
| email | VARCHAR(254) | Client's email address (optional) |
| address | TEXT | Client's physical address (optional) |
| registration_date | DATE | When the client was registered |

### Enrollments (`api_enrollment`)

Junction table that manages the many-to-many relationship between clients and health programs.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key, auto-increment |
| enrollment_date | DATE | When the client enrolled in the program |
| notes | TEXT | Additional notes about the enrollment (optional) |
| client_id | INT | Foreign key to client table |
| program_id | INT | Foreign key to health program table |

Constraints:
- `client_id` and `program_id` combination must be unique
- Foreign key references with cascade delete

### Users (`users_user`)

Custom user model that extends Django's built-in user model.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key, auto-increment |
| password | VARCHAR(128) | Hashed password |
| last_login | DATETIME | Last login timestamp |
| is_superuser | TINYINT(1) | Whether the user has superuser privileges |
| username | VARCHAR(150) | Username |
| first_name | VARCHAR(150) | User's first name |
| last_name | VARCHAR(150) | User's last name |
| is_staff | TINYINT(1) | Whether the user can access the admin site |
| is_active | TINYINT(1) | Whether the user account is active |
| date_joined | DATETIME | When the user joined |
| email | VARCHAR(254) | User's email address (unique) |
| is_doctor | TINYINT(1) | Whether the user is a doctor |

## Relationships

1. **Clients to Health Programs** (Many-to-Many):
   - A client can be enrolled in multiple health programs
   - A health program can have multiple clients
   - The relationship is managed through the `api_enrollment` table

## Indexes

- Primary keys on all tables
- Foreign key indexes on `api_enrollment` (`client_id`, `program_id`)
- Unique constraint on `api_enrollment` (`client_id`, `program_id`)
- Unique constraint on `users_user` (`email`)

## Entity Relationship Diagram

```
    +----------------+       +------------------+       +----------------+
    |                |       |                  |       |                |
    |   Client       |       |   Enrollment     |       |  HealthProgram |
    |                |       |                  |       |                |
    | id (PK)        |       | id (PK)          |       | id (PK)        |
    | first_name     |       | enrollment_date  |       | name           |
    | last_name      |<----->| notes            |<----->| description    |
    | date_of_birth  |       | client_id (FK)   |       | created_at     |
    | gender         |       | program_id (FK)  |       | updated_at     |
    | phone_number   |       |                  |       |                |
    | email          |       +------------------+       +----------------+
    | address        |
    | registration   |
    |                |
    +----------------+
``` 