--Requirements
--For the transactions file:
--Filter the transactions to just look at DSB 
--These will be transactions that contain DSB in the Transaction Code field
--Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
--Change the date to be the quarter 
--Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person) 
--For the targets file:
--Pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter 
 --Rename the fields
--Remove the 'Q' from the quarter field and make the data type numeric 
--Join the two datasets together 
--You may need more than one join clause!
--Remove unnecessary fields
--Calculate the Variance to Target for each row

WITH CTE AS(
SELECT 
CASE ONLINE_OR_IN_PERSON
WHEN 1 THEN 'Online'
WHEN 2 THEN 'In-Person'
END AS ONLINE_OR_IN_PERSON,
QUARTER(DATE(TRANSACTION_DATE, 'DD/MM/YYYY HH:MI:SS')) AS QUARTER,
SUM(VALUE) AS VALUE
FROM PD2023_WK01 
WHERE CONTAINS(TRANSACTION_CODE, 'DSB')
GROUP BY 1, 2)

SELECT cte.ONLINE_OR_IN_PERSON,
CAST(REPLACE(T.QUARTER, 'Q') AS INTEGER) AS QUARTER,
VALUE,
QUARTERLY_TARGET,
VALUE - QUARTERLY_TARGET AS VARIANCE_TO_TARGET
FROM PD2023_WK03_TARGETS
UNPIVOT(QUARTERLY_TARGET FOR QUARTER IN (Q1, Q2, Q3, Q4)) AS T
INNER JOIN CTE ON CTE.ONLINE_OR_IN_PERSON = T.ONLINE_OR_IN_PERSON AND 
CTE.QUARTER = CAST(REPLACE(T.QUARTER, 'Q') AS INTEGER)