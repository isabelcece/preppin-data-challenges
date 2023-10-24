--Input each of the 12 monthly files
--Create a 'file date' using the month found in the file name
--The Null value should be replaced as 1
--Clean the Market Cap value to ensure it is the true value as 'Market Capitalisation'
--Remove any rows with 'n/a'
--Categorise the Purchase Price into groupings
--0 to 24,999.99 as 'Low'
--25,000 to 49,999.99 as 'Medium'
--50,000 to 74,999.99 as 'High'
--75,000 to 100,000 as 'Very High'
--Categorise the Market Cap into groupings
--Below $100M as 'Small'
--Between $100M and below $1B as 'Medium'
--Between $1B and below $100B as 'Large' 
--$100B and above as 'Huge'
--Rank the highest 5 purchases per combination of: file date, Purchase Price Categorisation and Market Capitalisation Categorisation.
--Output only records with a rank of 1 to 5

WITH unioned_files AS(
SELECT *, 1 AS file_name FROM pd2023_wk08_01
UNION ALL
SELECT *, 2 AS file_name FROM pd2023_wk08_02
UNION ALL
SELECT *, 3 AS file_name FROM pd2023_wk08_03
UNION ALL
SELECT *, 4 AS file_name FROM pd2023_wk08_04
UNION ALL
SELECT *, 5 AS file_name FROM pd2023_wk08_05
UNION ALL
SELECT *, 6 AS file_name FROM pd2023_wk08_06
UNION ALL
SELECT *, 7 AS file_name FROM pd2023_wk08_07
UNION ALL
SELECT *, 8 AS file_name FROM pd2023_wk08_08
UNION ALL
SELECT *, 9 AS file_name FROM pd2023_wk08_09
UNION ALL
SELECT *, 10 AS file_name FROM pd2023_wk08_10
UNION ALL
SELECT *, 11 AS file_name FROM pd2023_wk08_11
UNION ALL
SELECT *, 12 AS file_name FROM pd2023_wk08_12
),
prices_converted AS (
SELECT *,
MONTHNAME(DATE_FROM_PARTS(2000,file_name,1)) AS file_date,
CASE
WHEN CONTAINS(market_cap, 'M') THEN TO_DECIMAL(REPLACE(REPLACE(market_cap, '$'),'M'),38,2) * 1000000
WHEN CONTAINS(market_cap, 'B') THEN TO_DECIMAL(REPLACE(REPLACE(market_cap, '$'),'B'),38,2) * 1000000000
END AS market_cap_cleaned,
TO_DECIMAL(REPLACE(purchase_price,'$'),38,2) AS purchase_price_cleaned
FROM unioned_files
WHERE market_cap != 'n/a'
),
cte AS (
SELECT * ,
CASE
WHEN purchase_price_cleaned < 25000 THEN 'Low'
WHEN purchase_price_cleaned < 50000 THEN 'Medium'
WHEN purchase_price_cleaned < 75000 THEN 'High'
WHEN purchase_price_cleaned < 100000 THEN 'Very High' END AS purchase_price_category,
CASE
WHEN market_cap_cleaned < 100000000 THEN 'Small'
WHEN market_cap_cleaned < 1000000000 THEN 'Medium'
WHEN market_cap_cleaned < 100000000000 THEN 'Large'
WHEN market_cap_cleaned >= 100000000000 THEN 'Huge' END AS market_cap_category
FROM prices_converted
),
ranked AS (
SELECT 
file_date,
purchase_price_category,
market_cap_category,
ticker,
sector,
market,
stock_name,
market_cap,
purchase_price,
RANK() OVER (PARTITION BY file_date, purchase_price_category, market_cap_category ORDER BY purchase_price DESC) AS rank
FROM cte)
SELECT *
FROM ranked
WHERE rank <= 5;