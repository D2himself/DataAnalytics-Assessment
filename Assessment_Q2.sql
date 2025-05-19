-- Q2: Transaction Frequency Analysis
-- This query calculates how frequently customers transact and classifies them into categories.
USE adashi_staging;

-- CTE: Calculate the number of transactions per user per month
WITH MonthlyUserTransactions AS (
    SELECT
        owner_id,
        YEAR(created_on) AS yr,
        MONTH(created_on) AS mnth,
        COUNT(*) AS monthly_txn_count
    FROM savings_savingsaccount
    GROUP BY owner_id, YEAR(created_on), MONTH(created_on)
),
-- CTE: Compute average monthly transactions per customer
UserTxnFrequency AS (
    SELECT
        owner_id,
        ROUND(AVG(monthly_txn_count), 2) AS avg_txn_per_month
    FROM MonthlyUserTransactions
    GROUP BY owner_id
),
-- CTE: Categorize each user based on their average frequency
UserTxnCategory AS (
    SELECT
        owner_id,
        avg_txn_per_month,
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM UserTxnFrequency
)
-- Final result: Count of users per category and their average transaction frequency
SELECT
    frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 2) AS avg_transactions_per_month
FROM UserTxnCategory
GROUP BY frequency_category
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');



