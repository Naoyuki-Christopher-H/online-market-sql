# Online Market SQL Database System

## Overview

This project implements a comprehensive SQL database system for an online marketplace. 
The database tracks customers, products, and orders with proper relationships and constraints. 
The implementation includes tables, stored procedures, views, and functions to support essential e-commerce operations.

## Database Schema

### Tables

1. **Customers**
   - Stores customer information including name, contact details, and address
   - Includes creation and modification timestamps

2. **Products**
   - Contains product details with name, description, price, and inventory
   - Enforces positive pricing and non-negative inventory constraints

3. **Orders**
   - Records customer purchases with product references
   - Tracks order status (Pending, Shipped, Delivered, Cancelled)
   - Maintains referential integrity with customers and products

## Key Features

### Data Integrity
- Proper primary and foreign key relationships
- Check constraints for valid email formats, positive prices, and quantities
- Default values for timestamps and order status

### Business Logic
- Inventory management during order processing
- Order status tracking
- Stock level monitoring with status indicators

### Error Handling
- Comprehensive TRY-CATCH blocks throughout
- Transaction management for data consistency
- Meaningful error messages for troubleshooting

### Reporting Capabilities
- Order details view combining customer, product, and order information
- Sales reporting by product
- Inventory status reporting

## Stored Procedures

1. **sp_InsertCustomer**
   - Safely adds new customers with email uniqueness validation

2. **sp_InsertProduct**
   - Adds products with price and quantity validation

3. **sp_PlaceOrder**
   - Processes orders with inventory checks
   - Updates product stock levels automatically

4. **sp_UpdateProductPrice**
   - Validates and updates product prices

5. **sp_DeleteCustomer**
   - Safely removes customers after order validation

## Views

1. **vw_OrderDetails**
   - Combines order, customer, and product information
   - Calculates order totals

## Functions

1. **fn_CalculateTotalSales**
   - Computes total sales revenue by product

## Installation

1. Execute the entire script in SQL Server Management Studio or compatible tool
2. The script will:
   - Create the database if it doesn't exist
   - Create all tables with proper constraints
   - Set up stored procedures, views, and functions
   - Populate initial test data

## Usage Examples

- Add new customers using `sp_InsertCustomer`
- Manage products with `sp_InsertProduct` and `sp_UpdateProductPrice`
- Process orders through `sp_PlaceOrder`
- Generate reports using the `vw_OrderDetails` view
- Monitor inventory levels with the stock status query

## Best Practices Implemented

- Proper transaction management
- Comprehensive error handling
- Data validation at multiple levels
- Separation of concerns through stored procedures
- Timestamp tracking for auditing
- Meaningful constraint naming

## Maintenance

The database includes modification timestamps on all tables to support auditing and change tracking. 
The script is designed to be idempotent, allowing safe re-execution without data loss.

## DISCLAIMER  

UNDER NO CIRCUMSTANCES SHOULD IMAGES OR EMOJIS BE INCLUDED DIRECTLY IN 
THE README FILE. ALL VISUAL MEDIA, INCLUDING SCREENSHOTS AND IMAGES OF 
THE APPLICATION, MUST BE STORED IN A DEDICATED FOLDER WITHIN THE PROJECT 
DIRECTORY. THIS FOLDER SHOULD BE CLEARLY STRUCTURED AND NAMED ACCORDINGLY 
TO INDICATE THAT IT CONTAINS ALL VISUAL CONTENT RELATED TO THE APPLICATION 
(FOR EXAMPLE, A FOLDER NAMED IMAGES, SCREENSHOTS, OR MEDIA).

I AM NOT LIABLE OR RESPONSIBLE FOR ANY MALFUNCTIONS, DEFECTS, OR ISSUES THAT 
MAY OCCUR AS A RESULT OF COPYING, MODIFYING, OR USING THIS SOFTWARE. IF YOU 
ENCOUNTER ANY PROBLEMS OR ERRORS, PLEASE DO NOT ATTEMPT TO FIX THEM SILENTLY 
OR OUTSIDE THE PROJECT. INSTEAD, KINDLY SUBMIT A PULL REQUEST OR OPEN AN ISSUE 
ON THE CORRESPONDING GITHUB REPOSITORY, SO THAT IT CAN BE ADDRESSED APPROPRIATELY 
BY THE MAINTAINERS OR CONTRIBUTORS.

---
