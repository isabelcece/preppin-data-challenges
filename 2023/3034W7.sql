--For the Transaction Path table:
--Make sure field naming convention matches the other tables
--i.e. instead of Account_From it should be Account From
--For the Account Information table:
--Make sure there are no null values in the Account Holder ID
--Ensure there is one row per Account Holder ID
--Joint accounts will have 2 Account Holders, we want a row for each of them
--For the Account Holders table:
--Make sure the phone numbers start with 07
--Bring the tables together
--Filter out cancelled transactions 
--Filter to transactions greater than £1,000 in value 
--Filter out Platinum accounts

WITH cte AS (
SELECT d.transaction_id,
d.value,
d.transaction_date,
p.account_to,
p.account_from
FROM pd2023_wk07_transaction_detail AS d
JOIN pd2023_wk07_transaction_path AS p ON d.transaction_id = p.transaction_id
WHERE cancelled_ = 'N' AND value > 1000
),
acc_info AS (
SELECT account_number,
account_type,
balance_date,
balance,
value AS account_holder_id_split
FROM pd2023_wk07_account_information, LATERAL SPLIT_TO_TABLE(account_holder_id, ', ')
WHERE account_holder_id IS NOT NULL AND account_type != 'Platinum'
),
contact AS (
SELECT account_holder_id,
name,
CONCAT('0',REPLACE(TO_VARCHAR(contact_number),',')) AS contact_number,
date_of_birth,
first_line_of_address
FROM pd2023_wk07_account_holders
)
SELECT
cte.transaction_id,
cte.account_to,
cte.transaction_date,
cte.value,
acc_info.account_number,
acc_info.account_type,
acc_info.balance_date,
acc_info.balance,
contact.name,
contact.date_of_birth,
contact.contact_number,
contact.first_line_of_address
FROM cte
JOIN acc_info 
ON cte.account_from = acc_info.account_number
JOIN contact 
ON contact.account_holder_id = acc_info.account_holder_id_split;