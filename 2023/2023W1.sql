--Output 1: Total values of Transactions by each bank

SELECT 
SPLIT_PART(TRANSACTION_CODE, '-', 1) AS bank,
SUM(VALUE) AS value
FROM pd2023_wk01
GROUP BY bank;

--Output 2: Total Values by Bank, Day of the week, and Type of Transaction

SELECT 
SPLIT_PART(TRANSACTION_CODE, '-', 1) AS bank, 
CASE online_or_in_person
WHEN 1 THEN 'Online'
WHEN 2 THEN 'In-Person' END AS online_or_in_Person,
DAYNAME(TO_DATE(TRANSACTION_DATE, 'DD/MM/YYYY HH24:MI:SS')) AS transaction_day,
SUM(VALUE) AS value
FROM PD2023_WK01
GROUP BY bank, online_or_in_person, transaction_day;

--Output 3: Total Values by Bank and Customer Code

SELECT 
SPLIT_PART(TRANSACTION_CODE, '-', 1) AS bank,
CUSTOMER_CODE, 
SUM(VALUE) AS value
FROM PD2023_WK01
GROUP BY bank, customer_code;