/* Create a SQLite database called Residential_Properties.db. Then, create tables called
Characteristics, Sales, and Locations that contain the exact field names described above and
import each data file into the respective table. */

.open --new "/workspaces/Property-Sales-Data/Residential_Properties.db"

CREATE TABLE Characteristics (
    pid TEXT PRIMARY KEY,
    propertyusecode TEXT,
    totalareasqft INTEGER,
    totalcamaareasqft INTEGER,
    totalbedroom INTEGER,
    totalbath INTEGER,
    datebuilt TEXT
);

CREATE TABLE Sales(
    pid TEXT,
    saledatelatest TEXT,
    salepricelatest INTEGER, 
    FOREIGN KEY(pid) REFERENCES Characteristics(pid)
);

CREATE TABLE Locations(
    pid TEXT,
    situscity TEXT,
    situszip TEXT,
    FOREIGN KEY(pid) REFERENCES Characteristics(pid)
);

/* We must use a tab separator, since these are .txt files with tab delimiters */

.separator "\t"   
.import --skip 1 "/workspaces/Property-Sales-Data/property_characteristics.txt" Characteristics
.import --skip 1 "/workspaces/Property-Sales-Data/sales_dates_and_prices.txt" Sales
.import --skip 1 "/workspaces/Property-Sales-Data/cities_and_zipcodes.txt" Locations

.mode column
.headers on

/* Test queries to make sure the data imported properly */

SELECT * FROM Characteristics LIMIT 5;
SELECT * FROM Sales LIMIT 5;
SELECT * FROM Locations LIMIT 5;

/* C. Query the database to determine the total number of sales associated with each of the
property types/use codes. Assign the alias ‘Number of Sales’ and ensure that the output is
reported in descending order by the number of sales. */

/* First, let us see how many property use codes there are */

SELECT DISTINCT propertyusecode
FROM Characteristics;

/* Looks to be 10 unique property use codes. */

/* Now, the main query that sorts the number of sales by property use code  in descending order. */

SELECT C.propertyusecode AS "Property Use Code", 
COUNT(S.pid) AS "Number of Sales"
FROM Characteristics C
JOIN Sales S ON C.pid = S.pid
GROUP BY C.propertyusecode
ORDER BY COUNT(S.pid) DESC;

/* D. The property use codes are not informative. For example, it is unclear what a ‘130’ is. Use
a SQLite update statement to replace the use codes with their titles described in ‘Code
Descriptions and Lookup Tables’. After doing so, repeat the query from C.
Note: Codes 100-106 can all be called/updated to ‘Single Family’. Also, for codes 130, 131,
135, and 140 you can exclude ‘Single Family Residential -’ from the updated string names. */

UPDATE Characteristics
SET propertyusecode = 'Single Family'
WHERE propertyusecode IN ('101', '102', '103', '104', '105', '106');

UPDATE Characteristics
SET propertyusecode = 'Lake Front'
WHERE propertyusecode = '130';

UPDATE Characteristics
SET propertyusecode = 'Canal Front'
WHERE propertyusecode = '131';

UPDATE Characteristics
SET propertyusecode = 'Lake View'
WHERE propertyusecode = '135';

UPDATE Characteristics
SET propertyusecode = 'Golf'
WHERE propertyusecode = '140';

/* E. Query the database to obtain summary information on the characteristics of all properties in
the database, including the average, minimum, and maximum total square footage and square
footage under central air. Repeat this for the number of bedrooms and bathrooms. Assign
aliases in the process. */

SELECT 
    propertyusecode AS "Property",
    ROUND(AVG(totalareasqft), 2) AS "Avg Total SqFt",
    MIN(totalareasqft) AS "Min Total SqFt",
    MAX(totalareasqft) AS "Max Total SqFt",
    ROUND(AVG(totalcamaareasqft), 2) AS "Avg SqFt Under Central Air",
    MIN(totalcamaareasqft) AS "Min SqFt Under Central Air",
    MAX(totalcamaareasqft) AS "Max SqFt Under Central Air"
FROM Characteristics
GROUP BY propertyusecode;

SELECT 
    propertyusecode AS "Property",
    CAST(AVG(totalbedroom) AS INTEGER) AS "Avg Number of Bedrooms",
    MIN(totalbedroom) AS "Min Number of Bedrooms",
    MAX(totalbedroom) AS "Max Number of Bedrooms",
    CAST(AVG(totalbath) AS INTEGER) AS "Avg Number of Bathrooms",
    MIN(totalbath) AS "Min Number of Bathrooms",
    MAX(totalbath) AS "Max Number of Bathrooms"
FROM Characteristics
GROUP BY propertyusecode;

/* F. Modify E to obtain summary information for at least 2 of the property types for comparison
(e.g., to compare lakefront properties with different property types). */

SELECT 
    propertyusecode AS "Property",
    ROUND(AVG(totalareasqft), 2) AS "Avg Total SqFt",
    MIN(totalareasqft) AS "Min Total SqFt",
    MAX(totalareasqft) AS "Max Total SqFt",
    ROUND(AVG(totalcamaareasqft), 2) AS "Avg SqFt Under Central Air",
    MIN(totalcamaareasqft) AS "Min SqFt Under Central Air",
    MAX(totalcamaareasqft) AS "Max SqFt Under Central Air"
FROM Characteristics
WHERE propertyusecode IN ('Lake Front', 'Canal Front')
GROUP BY propertyusecode;

SELECT 
    propertyusecode AS "Property",
    CAST(AVG(totalbedroom) AS INTEGER) AS "Avg Number of Bedrooms",
    MIN(totalbedroom) AS "Min Number of Bedrooms",
    MAX(totalbedroom) AS "Max Number of Bedrooms",
    CAST(AVG(totalbath) AS INTEGER) AS "Avg Number of Bathrooms",
    MIN(totalbath) AS "Min Number of Bathrooms",
    MAX(totalbath) AS "Max Number of Bathrooms"
FROM Characteristics
WHERE propertyusecode IN ('Lake Front', 'Canal Front')
GROUP BY propertyusecode;

/* G. Query the database to obtain summary information on property age (in years) as of 2023. To
do so you will need to work with datebuilt */

SELECT 
    propertyusecode AS "Property",
    ROUND(AVG((2023 - CAST(SUBSTR(datebuilt, 1, 4) AS INTEGER))), 2) AS "Average Property Age (Years)",
    MIN((2023 - CAST(SUBSTR(datebuilt, 1, 4) AS INTEGER))) AS "Minimum Property Age (Years)",
    MAX((2023 - CAST(SUBSTR(datebuilt, 1, 4) AS INTEGER))) AS "Maximum Property Age (Years)"
FROM Characteristics
GROUP BY propertyusecode;

/* For some reason, the minimum property age of the Lake View properties is -45 years. This cannot be possible. */

SELECT pid, datebuilt
FROM Characteristics
WHERE (2023 - SUBSTR(datebuilt, 1, 4)) < 0;

/* Looks like this is an error in the data. The datebuilt is listed as 20680101, which is why the minimum age is appearing as -45. */

/* H. Query the database to obtain summary information on the most recent sales prices, including
the average, minimum, and maximum. Assign aliases in the process. */

SELECT 
    C.propertyusecode AS "Property",
    S.salepricelatest AS "Recent Sales Price",
    ROUND(AVG(S.salepricelatest), 2) AS "Avg Sales Price",
    MIN(S.salepricelatest) AS "Min Sale Price",
    MAX(S.salepricelatest) AS "Max Sale Price"
FROM Characteristics AS C
JOIN Sales AS S ON C.pid = S.pid
GROUP BY C.propertyusecode;

/* It makes sense that the Single Family entry does not have a Recent Sales Price, since it is a grouping of multiple property use codes. */

/* I. Modify H in order to obtain summary information on sales of properties that sold between
2013 and 2018. To do so you will need to work with saledatelatest. Report the results on a
yearly basis (versus for all years). Assign aliases in the process. */

SELECT 
    C.propertyusecode AS "Property",
    SUBSTR(S.saledatelatest, 1, 4) AS "Sale Year",
    S.salepricelatest AS "Recent Sales Price",
    ROUND(AVG(S.salepricelatest), 2) AS "Avg Sales Price",
    MIN(S.salepricelatest) AS "Min Sale Price",
    MAX(S.salepricelatest) AS "Max Sale Price"
FROM Characteristics AS C
JOIN Sales AS S ON C.pid = S.pid
WHERE CAST(SUBSTR(S.saledatelatest, 1, 4) AS INTEGER) BETWEEN 2013 AND 2018
GROUP BY C.propertyusecode, SUBSTR(S.saledatelatest, 1, 4)
ORDER BY "Property", "Sale Year";

/* J. Modify I to report summary information on a yearly basis i) at the city level and ii) at the
zipcode level within each city. What conclusions do you draw about the sales prices of
residential properties throughout Orange County? Your team members want to know, so be
prepared to explain. */

SELECT 
    L.situscity AS "City",
    /* L.situszip AS "Zip Code", */
    SUBSTR(S.saledatelatest, 1, 4) AS "Sale Year",
    ROUND(AVG(S.salepricelatest), 2) AS "Avg Sales Price",
    MIN(S.salepricelatest) AS "Min Sale Price",
    MAX(S.salepricelatest) AS "Max Sale Price"
FROM Locations AS L
JOIN Sales AS S ON L.pid = S.pid
WHERE CAST(SUBSTR(S.saledatelatest, 1, 4) AS INTEGER) BETWEEN 2013 AND 2018
GROUP BY L.situscity, /*L.situszip,*/ SUBSTR(S.saledatelatest, 1, 4);

/* K. Execute a query that joins all 3 tables and export the output to a file called
Residential_Properties.csv (or Residential_Properties.txt). Open the file outside of SQLite
(e.g., in Excel) to confirm it contains all fields and rows in the individual tables or in the data
files downloaded in A. */

.headers on
.mode csv
.output "/workspaces/Property-Sales-Data/Residential_Properties.csv"

SELECT *
FROM Characteristics AS C
JOIN Sales AS S ON C.pid = S.pid
JOIN Locations AS L ON C.pid = L.pid;

.output stdout

.exit