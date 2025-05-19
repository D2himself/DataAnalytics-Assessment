-- Q3: Account Inactivity Alert
-- This query finds plans (savings or investment) with no inflow transactions in the last 365 days.
USE adashi_staging;

-- CTE: Get latest transaction date for each plan
WITH PlanLastTransaction AS ( 
	SELECT
		plan_id,
		MAX(created_on) AS last_transaction_date
	FROM savings_savingsaccount
	GROUP BY plan_id
)
-- Final selection: Join with plans and calculate inactivity
SELECT 
	p.id AS plan_id,
	p.owner_id,
	-- Determine the type of plan
	CASE 
		WHEN p.is_regular_savings = 1 THEN 'savings'
		WHEN P.is_a_fund = 1 THEN 'Investment'
		ELSE 'other'
	END AS type,
	plt.last_transaction_date,
	-- Calculate days since last transaction
	DATEDIFF(CURDATE(), plt.last_transaction_date) AS inactivity_days
FROM plans_plan p
-- Join with last transaction per plan
JOIN PlanLastTransaction plt ON plt.plan_id = p.id
-- Filter: Only plans with no inflow in the last 365 days
WHERE DATEDIFF(CURDATE(), plt.last_transaction_date) > 365;
	