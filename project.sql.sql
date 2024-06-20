USE `410971109`;
CREATE TABLE Brands (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE Models (
    id INTEGER PRIMARY KEY,
    brand_id INTEGER,
    name TEXT NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES Brands(id)
);

CREATE TABLE Vehicles (
    vin TEXT PRIMARY KEY,
    model_id INTEGER,
    color TEXT,
    engine TEXT,
    transmission TEXT,
    FOREIGN KEY (model_id) REFERENCES Models(id)
);

CREATE TABLE Dealers (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT
);

CREATE TABLE Customers (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    gender TEXT,
    annual_income REAL
);

CREATE TABLE Sales (
    id INTEGER PRIMARY KEY,
    dealer_id INTEGER,
    customer_id INTEGER,
    vin TEXT,
    sale_date DATE,
    price REAL,
    FOREIGN KEY (dealer_id) REFERENCES Dealers(id),
    FOREIGN KEY (customer_id) REFERENCES Customers(id),
    FOREIGN KEY (vin) REFERENCES Vehicles(vin)
);

CREATE TABLE Suppliers (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE Parts (
    id INTEGER PRIMARY KEY,
    model_id INTEGER,
    supplier_id INTEGER,
    part_name TEXT NOT NULL,
    manufacture_date DATE,
    FOREIGN KEY (model_id) REFERENCES Models(id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(id)
);

CREATE TABLE ManufacturingPlants (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT
);

CREATE TABLE PlantParts (
    plant_id INTEGER,
    part_id INTEGER,
    PRIMARY KEY (plant_id, part_id),
    FOREIGN KEY (plant_id) REFERENCES ManufacturingPlants(id),
    FOREIGN KEY (part_id) REFERENCES Parts(id)
);

INSERT INTO Brands (id, name) VALUES (1, 'Volkswagen'), (2, 'Audi');

INSERT INTO Models (id, brand_id, name) VALUES
(1, 1, 'Polo'),
(2, 1, 'Golf'),
(3, 2, 'A4');

INSERT INTO Vehicles (vin, model_id, color, engine, transmission) VALUES
('1HGBH41JXMN109186', 1, 'Red', 'V4', 'Manual'),
('1HGCM82633A123456', 2, 'Blue', 'V6', 'Automatic'),
('1HGCM82633A654321', 3, 'Black', 'V8', 'Automatic');

INSERT INTO Dealers (id, name, address, phone) VALUES
(1, 'Dealer One', '123 Main St', '555-1234'),
(2, 'Dealer Two', '456 Elm St', '555-5678');

INSERT INTO Customers (id, name, address, phone, gender, annual_income) VALUES
(1, 'John Doe', '789 Oak St', '555-8765', 'Male', 50000),
(2, 'Jane Smith', '321 Pine St', '555-4321', 'Female', 60000);

INSERT INTO Sales (id, dealer_id, customer_id, vin, sale_date, price) VALUES
(1, 1, 1, '1HGBH41JXMN109186', '2023-01-15', 20000),
(2, 2, 2, '1HGCM82633A123456', '2023-02-20', 25000);

INSERT INTO Suppliers (id, name) VALUES (1, 'Getrag');

INSERT INTO Parts (id, model_id, supplier_id, part_name, manufacture_date) VALUES
(1, 1, 1, 'Transmission', '2023-01-01'),
(2, 2, 1, 'Transmission', '2023-02-01');

INSERT INTO ManufacturingPlants (id, name, location) VALUES
(1, 'Plant One', 'Location One');

INSERT INTO PlantParts (plant_id, part_id) VALUES
(1, 1),
(1, 2);

SELECT v.vin, c.name 
FROM Vehicles v
JOIN Sales s ON v.vin = s.vin
JOIN Customers c ON s.customer_id = c.id
JOIN Parts p ON p.model_id = v.model_id
JOIN PlantParts pp ON pp.part_id = p.id
WHERE p.part_name = 'Transmission' 
AND p.supplier_id = 1
AND p.manufacture_date BETWEEN '2023-01-01' AND '2023-12-31';

SELECT d.name, SUM(s.price) AS total_sales 
FROM Dealers d
JOIN Sales s ON d.id = s.dealer_id
GROUP BY d.name
ORDER BY total_sales DESC
LIMIT 1;

SELECT b.name, COUNT(v.vin) AS unit_sales
FROM Brands b
JOIN Models m ON b.id = m.brand_id
JOIN Vehicles v ON m.id = v.model_id
JOIN Sales s ON v.vin = s.vin
GROUP BY b.name
ORDER BY unit_sales DESC
LIMIT 2;

SELECT strftime('%Y-%m', s.sale_date) AS month, COUNT(v.vin) AS sales
FROM Vehicles v
JOIN Sales s ON v.vin = s.vin
WHERE v.model_id IN (SELECT id FROM Models WHERE name LIKE '%SUV%')
GROUP BY month
ORDER BY sales DESC
LIMIT 1;

SELECT d.name, AVG(julianday('now') - julianday(s.sale_date)) AS avg_inventory_time
FROM Dealers d
JOIN Sales s ON d.id = s.dealer_id
JOIN Vehicles v ON s.vin = v.vin
WHERE s.sale_date IS NOT NULL
GROUP BY d.name
ORDER BY avg_inventory_time DESC
LIMIT 1;