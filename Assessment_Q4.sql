-- Q4: Customer Lifetime Value (CLV) Estimation
-- This query estimates CLV using transaction frequency, tenure, and average profit.

USE adashi_staging;

-- CTE: Calculate user-level transaction summary
WITH UserTransactionSummary AS (
    SELECT
        sa.owner_id,
        COUNT(*) AS total_transactions,
        ROUND(SUM(confirmed_amount) / 100, 2) AS total_value_naira,
        ROUND(0.001 * SUM(confirmed_amount) / 100, 2) AS total_profit_naira
    FROM savings_savingsaccount sa
    WHERE confirmed_amount IS NOT NULL
    GROUP BY sa.owner_id
)
-- Final result: Join with user info and compute tenure & CLV
SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    -- Tenure in months since account creation
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    uts.total_transactions,
    -- CLV = (total_transactions / tenure) * 12 * (total_profit / total_transactions)
    -- Simplifies to: CLV = (12 / tenure) * total_profit
    ROUND((12 / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * uts.total_profit_naira, 2) AS estimated_clv
FROM users_customuser u
JOIN UserTransactionSummary uts ON u.id = uts.owner_id
-- Exclude users with zero tenure to avoid division by zero
WHERE TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) > 0
ORDER BY estimated_clv DESC;
