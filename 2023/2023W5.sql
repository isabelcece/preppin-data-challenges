--Requirements:
--Input data
--Create the bank code by splitting out off the letters from the Transaction code, call this field 'Bank'
--Change transaction date to the just be the month of the transaction
--Total up the transaction values so you have one row for each bank and month combination
--Rank each bank for their value of transactions each month against the other banks. 1st is the highest value of transactions, 3rd the lowest. 
--Without losing all of the other data fields, find:
--The average rank a bank has across all of the months, call this field 'Avg Rank per Bank'
--The average transaction value per rank, call this field 'Avg Transaction Value per Rank'
--Output the data

WITH cte AS (
SELECT 
MONTHNAME(TO_DATE(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) AS transaction_month,
SPLIT_PART(transaction_code,'-',1) AS bank,
SUM(value) AS total_value,
RANK() OVER (PARTITION BY transaction_month ORDER BY SUM(VALUE) DESC) AS ranked
FROM PD2023_WK01
GROUP BY bank, transaction_month
ORDER BY transaction_month, ranked
),
AVG_RANK AS (
SELECT AVG(ranked) AS avg_rank_per_bank,
bank
FROM cte 
GROUP BY bank
),
AVG_VALUE AS (
SELECT AVG(total_value) AS avg_value_per_rank,
ranked 
FROM cte
GROUP BY ranked
)
SELECT cte.*,
avg_rank_per_bank,
avg_value_per_rank
FROM cte
INNER JOIN AVG_RANK AS rnk ON rnk.bank = cte.bank
INNER JOIN AVG_VALUE AS val ON val.ranked = cte.ranked;