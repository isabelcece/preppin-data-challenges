--Requirements:
--Reshape the data so we have 5 rows for each customer, with responses for the Mobile App and Online Interface being in separate fields on the same row
--Clean the question categories so they don't have the platform in from of them
--e.g. Mobile App - Ease of Use should be simply Ease of Use
--Exclude the Overall Ratings, these were incorrectly calculated by the system
--Calculate the Average Ratings for each platform for each customer 
--Calculate the difference in Average Rating between Mobile App and Online Interface for each customer
--Catergorise customers as being:
--Mobile App Superfans if the difference is greater than or equal to 2 in the Mobile App's favour
--Mobile App Fans if difference >= 1
--Online Interface Fan
--Online Interface Superfan
--Neutral if difference is between 0 and 1
--Calculate the Percent of Total customers in each category, rounded to 1 decimal place

WITH mobile AS (
SELECT customer_id,
REPLACE(survey_questions, 'MOBILE_APP___') AS survey_questions,
mobile_app_responses
FROM PD2023_WK06_DSB_CUSTOMER_SURVEY
UNPIVOT (mobile_app_responses
            FOR survey_questions IN (mobile_app___ease_of_access, mobile_app___ease_of_use, mobile_app___likelihood_to_recommend, mobile_app___navigation))
),
online AS (
SELECT customer_id,
online_responses,
REPLACE(survey_questions, 'ONLINE_INTERFACE___') AS survey_questions
FROM pd2023_wk06_dsb_customer_survey
UNPIVOT (online_responses
            FOR survey_questions IN ( online_interface___ease_of_access, online_interface___ease_of_use, online_interface___likelihood_to_recommend, online_interface___navigation))
),
preferences AS (
SELECT m.customer_id,
AVG(mobile_app_responses) AS mobile_average,
AVG(online_responses) AS online_average,
mobile_average - online_average AS avg_difference,
CASE
WHEN avg_difference >= 2 THEN 'Mobile App Superfan'
WHEN avg_difference >=1 THEN 'Mobile App Fan'
WHEN avg_difference <= -2 THEN 'Online Superfan'
WHEN avg_difference <=-1 THEN 'Online Fan'
ELSE 'Neutral'
END AS preference
FROM mobile AS m
JOIN online AS o ON m.customer_id = o.customer_id AND m.survey_questions = o.survey_questions
GROUP BY m.customer_id
)
SELECT preference,
ROUND(COUNT(DISTINCT customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM PD2023_WK06_DSB_CUSTOMER_SURVEY)*100,1) AS pct_of_total
FROM preferences
GROUP BY preference;
