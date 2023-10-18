--Requirements:
-- We want to stack the tables on top of one another, since they have the same fields in each sheet. We can do this one of 2 ways:
-- Drag each table into the canvas and use a union step to stack them on top of one another
-- Use a wildcard union in the input step of one of the tables
-- Some of the fields aren't matching up as we'd expect, due to differences in spelling. Merge these fields together
-- Make a Joining Date field based on the Joining Day, Table Names and the year 2023
-- Now we want to reshape our data so we have a field for each demographic, for each new customer
-- Make sure all the data types are correct for each field
-- Remove duplicates
-- If a customer appears multiple times take their earliest joining date

WITH cte2 AS(

WITH CTE AS

(SELECT *, 'PD2023_WK04_JANUARY' AS TABLE_NAME FROM PD2023_WK04_JANUARY
UNION ALL
SELECT *,'PD2023_WK04_FEBRUARY' AS TABLE_NAME FROM PD2023_WK04_FEBRUARY
UNION ALL
SELECT *, 'PD2023_WK04_MARCH' AS TABLE_NAME FROM PD2023_WK04_MARCH
UNION ALL
SELECT *, 'PD2023_WK04_APRIL' AS TABLE_NAME FROM PD2023_WK04_APRIL
UNION ALL
SELECT *, 'PD2023_WK04_MAY' AS TABLE_NAME FROM PD2023_WK04_MAY
UNION ALL
SELECT *, 'PD2023_WK04_JUNE' AS TABLE_NAME FROM PD2023_WK04_JUNE
UNION ALL
SELECT *, 'PD2023_WK04_JULY' AS TABLE_NAME FROM PD2023_WK04_JULY
UNION ALL
SELECT *, 'PD2023_WK04_AUGUST' AS TABLE_NAME FROM PD2023_WK04_AUGUST
UNION ALL
SELECT *, 'PD2023_WK04_SEPTEMBER' AS TABLE_NAME FROM PD2023_WK04_SEPTEMBER
UNION ALL
SELECT *, 'PD2023_WK04_OCTOBER' AS TABLE_NAME FROM PD2023_WK04_OCTOBER
UNION ALL
SELECT *, 'PD2023_WK04_NOVEMBER' AS TABLE_NAME FROM PD2023_WK04_NOVEMBER
UNION ALL
SELECT *, 'PD2023_WK04_DECEMBER' AS TABLE_NAME FROM PD2023_WK04_DECEMBER)

SELECT ID,
DATE_FROM_PARTS( 2023,MONTH(DATE(SPLIT_PART(TABLE_NAME, '_', 3),'MMMM')),JOINING_DAY) AS JOINING_DATE,
"'Account Type'" AS ACCOUNT_TYPE,
"'Date of Birth'"::date AS DATE_OF_BIRTH,
"'Ethnicity'" AS ETHNICITY,
ROW_NUMBER() OVER(PARTITION BY ID ORDER BY JOINING_DATE) AS filter_duplicates 
FROM CTE
PIVOT (MIN(VALUE) FOR DEMOGRAPHIC IN ('Ethnicity','Account Type', 'Date of Birth')))

SELECT 
ID,
JOINING_DATE,
DATE_OF_BIRTH,
ETHNICITY
FROM cte2
WHERE FILTER_DUPLICATES = 1