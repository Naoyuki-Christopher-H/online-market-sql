-- Create Database with error handling
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'online_market_sql')
BEGIN
    BEGIN TRY
        CREATE DATABASE online_market_sql;
        PRINT 'Database created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error creating database: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT 'Database already exists.';
END
GO

USE online_market_sql;
GO

-- Create Customers Table with better constraints
IF OBJECT_ID('Customers', 'U') IS NULL
BEGIN
    BEGIN TRY
        CREATE TABLE Customers
        (
            customer_id INT PRIMARY KEY IDENTITY(1,1),
            customer_name VARCHAR(50) NOT NULL,
            customer_last_name VARCHAR(50) NOT NULL,
            customer_email VARCHAR(100) UNIQUE CHECK (customer_email LIKE '%_@__%.__%'),
            customer_phone VARCHAR(25) NOT NULL,
            customer_address VARCHAR(200) NOT NULL,
            date_created DATETIME DEFAULT GETDATE(),
            date_modified DATETIME DEFAULT GETDATE()
        );
        PRINT 'Customers table created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error creating Customers table: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT 'Customers table already exists.';
END
GO

-- Create Products Table with better constraints
IF OBJECT_ID('Products', 'U') IS NULL
BEGIN
    BEGIN TRY
        CREATE TABLE Products
        (
            product_id INT PRIMARY KEY IDENTITY(1,1),
            product_name VARCHAR(50) NOT NULL,
            product_description VARCHAR(200) NOT NULL,
            product_price DECIMAL(10,2) NOT NULL CHECK (product_price > 0),
            product_stock_quantity INT NOT NULL CHECK (product_stock_quantity >= 0),
            date_created DATETIME DEFAULT GETDATE(),
            date_modified DATETIME DEFAULT GETDATE()
        );
        PRINT 'Products table created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error creating Products table: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT 'Products table already exists.';
END
GO

-- Create Orders Table with better constraints
IF OBJECT_ID('Orders', 'U') IS NULL
BEGIN
    BEGIN TRY
        CREATE TABLE Orders
        (
            order_id INT PRIMARY KEY IDENTITY(1,1),
            customer_id INT NOT NULL,
            product_id INT NOT NULL,
            order_date DATETIME NOT NULL DEFAULT GETDATE(),
            order_quantity INT NOT NULL CHECK (order_quantity > 0),
            order_status VARCHAR(20) DEFAULT 'Pending' CHECK (order_status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
            date_created DATETIME DEFAULT GETDATE(),
            date_modified DATETIME DEFAULT GETDATE(),

            -- Foreign Key Constraints
            FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES Products(product_id)
        );
        PRINT 'Orders table created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error creating Orders table: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT 'Orders table already exists.';
END
GO

-- Create a stored procedure for safe customer insertion
CREATE OR ALTER PROCEDURE sp_InsertCustomer
    @name VARCHAR(50),
    @last_name VARCHAR(50),
    @email VARCHAR(100),
    @phone VARCHAR(25),
    @address VARCHAR(200)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF EXISTS (SELECT 1 FROM Customers WHERE customer_email = @email)
        BEGIN
            RAISERROR('Email address already exists', 16, 1);
        END
        
        INSERT INTO Customers (customer_name, customer_last_name, customer_email, customer_phone, customer_address)
        VALUES (@name, @last_name, @email, @phone, @address);
        
        COMMIT TRANSACTION;
        PRINT 'Customer added successfully.';
        RETURN SCOPE_IDENTITY(); -- Return the new customer ID
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error adding customer: ' + ERROR_MESSAGE();
        RETURN -1;
    END CATCH
END
GO

-- Create a stored procedure for safe product insertion
CREATE OR ALTER PROCEDURE sp_InsertProduct
    @name VARCHAR(50),
    @description VARCHAR(200),
    @price DECIMAL(10,2),
    @quantity INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF @price <= 0
        BEGIN
            RAISERROR('Price must be greater than 0', 16, 1);
        END
        
        IF @quantity < 0
        BEGIN
            RAISERROR('Quantity cannot be negative', 16, 1);
        END
        
        INSERT INTO Products (product_name, product_description, product_price, product_stock_quantity)
        VALUES (@name, @description, @price, @quantity);
        
        COMMIT TRANSACTION;
        PRINT 'Product added successfully.';
        RETURN SCOPE_IDENTITY(); -- Return the new product ID
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error adding product: ' + ERROR_MESSAGE();
        RETURN -1;
    END CATCH
END
GO

-- Create a stored procedure for placing orders with inventory check
CREATE OR ALTER PROCEDURE sp_PlaceOrder
    @customer_id INT,
    @product_id INT,
    @quantity INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if customer exists
        IF NOT EXISTS (SELECT 1 FROM Customers WHERE customer_id = @customer_id)
        BEGIN
            RAISERROR('Customer does not exist', 16, 1);
        END
        
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = @product_id)
        BEGIN
            RAISERROR('Product does not exist', 16, 1);
        END
        
        -- Check inventory
        DECLARE @stock INT;
        SELECT @stock = product_stock_quantity FROM Products WHERE product_id = @product_id;
        
        IF @stock < @quantity
        BEGIN
            RAISERROR('Insufficient stock available', 16, 1);
        END
        
        -- Place the order
        INSERT INTO Orders (customer_id, product_id, order_quantity)
        VALUES (@customer_id, @product_id, @quantity);
        
        -- Update inventory
        UPDATE Products 
        SET product_stock_quantity = product_stock_quantity - @quantity,
            date_modified = GETDATE()
        WHERE product_id = @product_id;
        
        COMMIT TRANSACTION;
        PRINT 'Order placed successfully.';
        RETURN SCOPE_IDENTITY(); -- Return the new order ID
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error placing order: ' + ERROR_MESSAGE();
        RETURN -1;
    END CATCH
END
GO

-- Populate Customers Table using stored procedure
DECLARE @result INT;
EXEC @result = sp_InsertCustomer 
    'John', 'Doe', 'john.doe@example.com', '123-456-7890', '123 Elm Street, Springfield';
    
EXEC @result = sp_InsertCustomer 
    'Jane', 'Smith', 'jane.smith@example.com', '987-654-3210', '456 Oak Avenue, Springfield';
GO

-- Populate Products Table using stored procedure
DECLARE @result INT;
EXEC @result = sp_InsertProduct 
    'Laptop', '14 Inch Laptop with 16GB RAM and 512GB SSD', 799.99, 10;
    
EXEC @result = sp_InsertProduct 
    'Smartphone', 'LTE Smartphone with 128GB storage', 499.99, 20;
    
EXEC @result = sp_InsertProduct 
    'Tablet', '12 Inch Tablet with stylus support', 299.99, 15;
GO

-- Populate Orders Table using stored procedure
DECLARE @result INT;
EXEC @result = sp_PlaceOrder 1, 1, 1;
EXEC @result = sp_PlaceOrder 1, 2, 2;
EXEC @result = sp_PlaceOrder 2, 3, 1;
GO

-- Create a view for order details
CREATE OR ALTER VIEW vw_OrderDetails AS
SELECT 
    o.order_id,
    c.customer_name + ' ' + c.customer_last_name AS customer_full_name,
    p.product_name,
    p.product_price,
    o.order_quantity,
    (p.product_price * o.order_quantity) AS total_price,
    o.order_date,
    o.order_status
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON o.product_id = p.product_id;
GO

-- Select Specific Orders for Customer 1 with error handling
BEGIN TRY
    SELECT 
        o.order_id, 
        p.product_name, 
        o.order_quantity, 
        o.order_date,
        (p.product_price * o.order_quantity) AS order_total
    FROM Orders o
    JOIN Products p ON o.product_id = p.product_id
    WHERE o.customer_id = 1
    ORDER BY o.order_date;
END TRY
BEGIN CATCH
    PRINT 'Error retrieving orders: ' + ERROR_MESSAGE();
END CATCH
GO

-- Group Orders by Product and Calculate Total Quantity Ordered with error handling
BEGIN TRY
    SELECT 
        p.product_name, 
        SUM(o.order_quantity) AS total_quantity,
        SUM(p.product_price * o.order_quantity) AS total_revenue
    FROM Orders o
    JOIN Products p ON o.product_id = p.product_id
    GROUP BY p.product_name
    ORDER BY total_quantity DESC;
END TRY
BEGIN CATCH
    PRINT 'Error generating product sales report: ' + ERROR_MESSAGE();
END CATCH
GO

-- Safe product price update with transaction
CREATE OR ALTER PROCEDURE sp_UpdateProductPrice
    @product_id INT,
    @new_price DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF @new_price <= 0
        BEGIN
            RAISERROR('Price must be greater than 0', 16, 1);
        END
        
        UPDATE Products
        SET product_price = @new_price,
            date_modified = GETDATE()
        WHERE product_id = @product_id;
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Product not found', 16, 1);
        END
        
        COMMIT TRANSACTION;
        PRINT 'Product price updated successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error updating product price: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- Safe customer deletion with transaction
CREATE OR ALTER PROCEDURE sp_DeleteCustomer
    @customer_id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check for existing orders
        IF EXISTS (SELECT 1 FROM Orders WHERE customer_id = @customer_id)
        BEGIN
            -- Alternatively, you could archive the customer instead of deleting
            RAISERROR('Cannot delete customer with existing orders', 16, 1);
        END
        
        DELETE FROM Customers
        WHERE customer_id = @customer_id;
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Customer not found', 16, 1);
        END
        
        COMMIT TRANSACTION;
        PRINT 'Customer deleted successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error deleting customer: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- Display All Products and Their Stock Quantity with error handling
BEGIN TRY
    SELECT 
        product_name, 
        product_stock_quantity,
        CASE 
            WHEN product_stock_quantity = 0 THEN 'Out of Stock'
            WHEN product_stock_quantity < 5 THEN 'Low Stock'
            ELSE 'In Stock'
        END AS stock_status
    FROM Products
    ORDER BY product_name;
END TRY
BEGIN CATCH
    PRINT 'Error retrieving product inventory: ' + ERROR_MESSAGE();
END CATCH
GO

-- Create a function to calculate total sales
CREATE OR ALTER FUNCTION fn_CalculateTotalSales(@product_id INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);
    
    SELECT @total = SUM(p.product_price * o.order_quantity)
    FROM Orders o
    JOIN Products p ON o.product_id = p.product_id
    WHERE p.product_id = @product_id;
    
    RETURN ISNULL(@total, 0);
END;
GO

-- Example usage of the function
BEGIN TRY
    SELECT 
        product_name,
        dbo.fn_CalculateTotalSales(product_id) AS total_sales
    FROM Products;
END TRY
BEGIN CATCH
    PRINT 'Error calculating total sales: ' + ERROR_MESSAGE();
END CATCH
GO