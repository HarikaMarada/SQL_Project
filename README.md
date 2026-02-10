# ⚡ Energy Consumption Management System (SQL Project)

## 📖 Project Overview

The **Energy Consumption Management System** is a database project developed using **SQL** to monitor, record, and manage electricity/energy usage data.

The system helps organizations or households track energy consumption, calculate bills, analyze usage patterns, and maintain consumer records efficiently.

This project demonstrates database design concepts such as **tables, relationships, constraints, queries, and reporting**.

---

## 🚀 Features

* Store consumer details
* Record monthly energy consumption
* Calculate electricity bills
* Track meter readings
* Generate consumption reports
* View payment status
* Analyze high/low energy usage

---

## 🛠️ Technologies Used

* **Database Language:** SQL
* **Database System:** MySQL / Oracle / SQL Server / PostgreSQL
* **Tools:** MySQL Workbench / SQL Developer / phpMyAdmin

---

## 📂 Project Structure

```
energy-consumption-management/
│
├── schema.sql        # Table creation scripts
├── insert_data.sql   # Sample data
├── queries.sql       # Reports & analysis queries
├── procedures.sql    # Stored procedures (optional)
├── triggers.sql      # Triggers (optional)
└── README.md         # Documentation
```

---

## 🧱 Database Design

### Main Tables

1. **Consumers**

   * consumer_id (PK)
   * name
   * address
   * phone_no

2. **Meters**

   * meter_id (PK)
   * consumer_id (FK)
   * installation_date

3. **Readings**

   * reading_id (PK)
   * meter_id (FK)
   * month
   * units_consumed

4. **Billing**

   * bill_id (PK)
   * consumer_id (FK)
   * total_units
   * amount
   * due_date
   * payment_status

---

## 🔗 Entity Relationships

* One consumer → One meter
* One meter → Many readings
* One consumer → Many bills

---

## ▶️ How to Run the Project

1. Install any SQL Database (MySQL recommended)
2. Open SQL tool (Workbench / SQL Developer)
3. Run schema file:

```sql
SOURCE schema.sql;
```

4. Insert sample data:

```sql
SOURCE insert_data.sql;
```

5. Execute queries:

```sql
SOURCE queries.sql;
```

---

## 📊 Sample Queries

### View All Consumers

```sql
SELECT * FROM Consumers;
```

### Monthly Consumption Report

```sql
SELECT consumer_id, month, units_consumed
FROM Readings;
```

### Calculate Bill

```sql
SELECT consumer_id,
       units_consumed * 5 AS bill_amount
FROM Readings;
```

---

## ⚙️ Advanced Concepts Used

* Primary & Foreign Keys
* Joins
* Aggregate Functions
* Views
* Stored Procedures
* Triggers (for auto bill generation)

---

## 🔮 Future Enhancements

* Web interface integration
* Smart meter IoT data input
* Automated email billing
* Energy usage prediction
* Mobile app dashboard

---

## 👨‍💻 Author

**Your Name**
Database / SQL Developer

---

## 📜 License

This project is created for academic and educational purposes.
