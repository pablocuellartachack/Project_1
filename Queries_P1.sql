/* Creating the databases */


CREATE DATABASE Mens_Shoes;
CREATE DATABASE Womens_Shoes;


/* Creating tables before inserting data for the mens data */


Create Table Mens_Shoes.Shoe_Data (
	Brand varchar(64) NOT NULL,
    Mens_Price decimal(4,2) NOT NULL,
    Shoe_Condition varchar(20) NOT NULL,
    Currency varchar(3) NOT NULL,
	PK int AUTO_INCREMENT PRIMARY KEY
    );

ALTER TABLE Mens_Shoes.Shoe_Data
MODIFY Price decimal(7,2) NOT NULL;

ALTER TABLE Mens_Shoes.Shoe_Data
RENAME COLUMN Brand TO Mens_Brand;


/* Imported csv file into Mens Shoe_Data table */


SHOW GLOBAL VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = true;

LOAD DATA LOCAL INFILE '/Users/pc3/Desktop/Pricing Between Genders Analytics/GS_Prepped/Mens_Shoes_P1.csv'
INTO TABLE Mens_Shoes.Shoe_Data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


/* Narrowing Mens Shoe_Data to distinct brands with >=30 listings */


SELECT * 
FROM Mens_Shoes.Shoe_Data
WHERE Mens_Brand IN
(SELECT Mens_Brand
FROM Mens_Shoes.Shoe_Data
GROUP BY Mens_Brand 
HAVING COUNT(Mens_Brand)>30);

DELETE FROM Mens_Shoes.Shoe_Data
WHERE Mens_Brand IN (
SELECT Mens_Brand FROM (
SELECT Mens_Brand
FROM Mens_Shoes.Shoe_Data
GROUP BY Mens_Brand 
HAVING COUNT(Mens_Brand)<30) AS Clean_Shoe_Data
);

SHOW VARIABLES LIKE "sql_safe_updates";

SET SQL_SAFE_UPDATES = 0;

SELECT *
FROM Mens_Shoes.Shoe_Data;

SELECT count(distinct Mens_Brand)
FROM Mens_Shoes.Shoe_Data;


/* Creating table to gather distinct MENS brands and their average pricepoints */


CREATE TABLE Mens_Shoes.Mens_Averages (
	Mens_Brand varchar(64) UNIQUE NOT NULL,
    Count int NOT NULL,
    AVG_Price decimal(6,2) NOT NULL
);

ALTER TABLE Mens_Shoes.Mens_Averages
ADD COLUMN PK int AUTO_INCREMENT PRIMARY KEY;

INSERT INTO Mens_Shoes.Mens_Averages
SELECT 
    distinct(Mens_Brand),
    count(Mens_Brand),
    AVG(Mens_Price)
FROM Mens_Shoes.Shoe_Data
GROUP BY Mens_Brand;

SELECT *
FROM Mens_Shoes.Mens_Averages;


/* I'll be removing brands that have <30 entries */


SELECT count(*)
FROM Mens_Shoes.Mens_Averages
WHERE count>=30;

SELECT count(*)
FROM Mens_Shoes.Mens_Averages
WHERE count<30;

SHOW VARIABLES LIKE "sql_safe_updates";

DELETE FROM Mens_Shoes.Mens_Averages
WHERE count<30;


/* Creating tables before inserting data for the womens data */


CREATE TABLE Womens_Shoes.Shoe_Data (
	Womens_Brand varchar(64) NOT NULL,
    Womens_Price decimal(4,2) NOT NULL,
    Shoe_Condition varchar(20) NOT NULL,
    Currency varchar(3) NOT NULL,
	PK int AUTO_INCREMENT PRIMARY KEY
    );

ALTER TABLE Womens_Shoes.Shoe_Data
MODIFY Price decimal(7,2) NOT NULL;


/* Imported csv file into Womens Shoe_Data table */


SHOW GLOBAL VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = true;

LOAD DATA LOCAL INFILE '/Users/pc3/Desktop/Pricing Between Genders Analytics/GS_Prepped/Womens_Shoes_P1.csv'
INTO TABLE Womens_Shoes.Shoe_Data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


/* Narrowing Womens Shoe_Data to brands with >=30 listings */


SELECT * 
FROM Womens_Shoes.Shoe_Data
WHERE Womens_Brand IN
(SELECT Womens_Brand
FROM Womens_Shoes.Shoe_Data
GROUP BY Womens_Brand 
HAVING COUNT(Womens_Brand)>30);

DELETE FROM Womens_Shoes.shoe_data
WHERE Womens_Brand IN (
SELECT Womens_Brand FROM (
SELECT Womens_Brand
FROM Womens_Shoes.shoe_data
GROUP BY Womens_Brand 
HAVING COUNT(Womens_Brand)<30) AS Clean_Shoe_Data
);

SELECT *
FROM Womens_Shoes.Shoe_Data;

SELECT count(distinct Womens_Brand)
FROM Womens_Shoes.Shoe_Data;


/* Creating new table gathering distinct WOMENS brands and their average pricepoints */


CREATE TABLE Womens_Shoes.Womens_Averages (
	Womens_Brand varchar(64) UNIQUE NOT NULL,
    Count int NOT NULL,
    AVG_Price decimal(7,2) NOT NULL
);

ALTER TABLE Womens_Shoes.Womens_Averages
ADD COLUMN PK int AUTO_INCREMENT PRIMARY KEY;

INSERT INTO Womens_Shoes.Womens_Averages
SELECT 
    distinct(Womens_Brand),
    count(Womens_Brand),
    avg(Price)
FROM Womens_Shoes.Shoe_Data
GROUP BY Womens_Brand;

SELECT *
FROM Womens_Shoes.Womens_Averages;


/* I'll be removing brands that have <30 entries */


SELECT count(*)
FROM Womens_Shoes.Womens_Averages
WHERE count>=30;

SELECT count(*)
FROM Womens_Shoes.Womens_Averages
WHERE count<30;

SHOW VARIABLES LIKE "sql_safe_updates";

DELETE FROM Womens_Shoes.Womens_Averages
WHERE count<30;

SELECT *
FROM Womens_Shoes.Womens_Averages;


/* Joining both genders AVGs into a single table (Accomodating field names for joined table) */


ALTER TABLE Womens_Shoes.Womens_Averages
RENAME COLUMN Count to Womens_Count;

ALTER TABLE Mens_Shoes.Mens_Averages
RENAME COLUMN Count to Mens_Count;

ALTER TABLE Womens_Shoes.Womens_Averages
RENAME COLUMN AVG_Price to Womens_Price;

ALTER TABLE Mens_Shoes.Mens_Averages
RENAME COLUMN AVG_Price to Mens_Price;

ALTER TABLE Womens_Shoes.Womens_Averages
RENAME COLUMN PK to Womens_PK;

ALTER TABLE Mens_Shoes.Mens_Averages
RENAME COLUMN PK to Mens_PK;

DROP TABLE mens_shoes.joined_average_data;
CREATE TABLE mens_shoes.joined_average_data
SELECT mens_averages.*, womens_averages.*
FROM mens_shoes.mens_averages
RIGHT JOIN womens_shoes.womens_averages ON mens_averages.Mens_PK = womens_averages.Womens_PK
GROUP BY womens_averages.Womens_PK;

SELECT *
FROM mens_shoes.joined_average_data;


/* Joining both genders Shoe_Data into a single table (Accomodating field names for joined table) */
/* Realized there is no need to keep Shoe_Condition and Currency, they have been cleaned prior to only be New* and USD* */


ALTER TABLE Womens_Shoes.Shoe_Data
DROP COLUMN Shoe_Condition,
DROP COLUMN Currency;

ALTER TABLE Mens_Shoes.Shoe_Data
DROP COLUMN Shoe_Condition,
DROP COLUMN Currency;

ALTER TABLE Womens_Shoes.Shoe_Data
RENAME COLUMN PK to Womens_PK;

ALTER TABLE Mens_Shoes.Shoe_Data
RENAME COLUMN PK to Mens_PK;

ALTER TABLE Mens_Shoes.Shoe_Data
DROP COLUMN Mens_PK;

ALTER TABLE Mens_Shoes.Shoe_Data
ADD COLUMN Mens_PK int AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE Womens_Shoes.Shoe_Data
DROP COLUMN Womens_PK;

ALTER TABLE Womens_Shoes.Shoe_Data
ADD COLUMN Womens_PK int AUTO_INCREMENT PRIMARY KEY;


DROP TABLE mens_shoes.joined_shoe_data;
CREATE TABLE mens_shoes.joined_shoe_data
SELECT mens_shoes.shoe_data.*, womens_shoes.shoe_data.*
FROM womens_shoes.shoe_data
RIGHT JOIN mens_shoes.shoe_data ON mens_shoes.shoe_data.Mens_PK = womens_shoes.shoe_data.Womens_PK
GROUP BY mens_shoes.shoe_data.Mens_PK;

SELECT *
FROM Mens_Shoes.joined_shoe_data;


/* Final results
 (All Shoe_Data for brands with >30 listings by gender)
 (Price averages for brands with >30 listings by gender) */


SELECT *
FROM Mens_Shoes.joined_average_data;

SELECT *
FROM Mens_Shoes.joined_shoe_data;


/* Downloading results into Files */
/* Used table data export wizard for joined_average_data & joined_shoe_data */