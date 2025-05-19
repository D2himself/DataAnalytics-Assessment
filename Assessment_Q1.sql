-- Q1: High-value Customers with Both Savings and Investment Plans
-- This query identifies customers who have both a savings and an investment plan
-- and shows how much they have deposited in total.

USE adashi_staging;

-- CTE 1: Identify users who have at least one regular savings plan
WITH UserSavings AS (
    SELECT DISTINCT owner_id
    FROM plans_plan
    WHERE is_regular_savings = 1 -- Corrected column name here
),
-- CTE 2: Identify users who have at least one investment plan
UserInvestments AS (
    SELECT DISTINCT owner_id
    FROM plans_plan
    WHERE is_a_fund = 1
),
-- CTE 3: Calculate total confirmed deposits for each user
-- This sums deposits independently of plans
UserTotalDeposits AS (
    SELECT
        owner_id,
        -- Sum of all confirmed deposits (converted from kobo to Naira)
        ROUND(SUM(confirmed_amount)/ 100, 2) AS total_deposits
    FROM savings_savingsaccount
    WHERE confirmed_amount IS NOT NULL -- Ensure we only sum valid amounts
    GROUP BY owner_id
    HAVING SUM(confirmed_amount) > 0 -- Optionally only include users with deposits
)
-- Final SELECT: Join users with the results from the CTEs
-- We join UserSavings and UserInvestments to ensure the user has BOTH plan types
-- We then join UserTotalDeposits to get their deposit amount
SELECT
    u.id AS owner_id,
    -- Combine first and last name into one column
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    -- Now calculate the counts by joining back to plans *after* filtering the users
    (SELECT COUNT(id) FROM plans_plan WHERE owner_id = u.id AND is_regular_savings = 1) AS savings_count,
    (SELECT COUNT(id) FROM plans_plan WHERE owner_id = u.id AND is_a_fund = 1) AS investment_count,
    utd.total_deposits -- Get the total deposits from the pre-calculated CTE
FROM
    users_customuser u
-- Join with UserSavings CTE to ensure the user has savings
JOIN UserSavings us ON u.id = us.owner_id
-- Join with UserInvestments CTE to ensure the user has investments
JOIN UserInvestments ui ON u.id = ui.owner_id
-- Join with UserTotalDeposits CTE to get the total deposit amount
JOIN UserTotalDeposits utd ON u.id = utd.owner_id
-- Order by total deposits (from highest to lowest)
ORDER BY
    utd.total_deposits DESC;