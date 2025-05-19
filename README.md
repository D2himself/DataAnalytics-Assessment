# Cowrywise Data Analytics Assessment

This repository contains SQL solutions to business analytics questions as part of the Cowrywise Data Analyst assessment.

---

## ✅ Q1: High-Value Customers with Multiple Products

### Objective
Identify customers whow have at least:
- One funded **regular savings plan**
- One funded **investment plan**
- At least some **confirmed deposits**

Return their 'owner_id', full name, number of each plan typw, and total deposits - sorted by total deposit amount (descending).

### Approach

- I used **three CTEs** to break the logic cleanly:
  - `UserSavings`: users with regular savings plans (`is_regular_savings = 1`)
  - `UserInvestments`: users with investment plans (`is_a_fund = 1`)
  - `UserTotalDeposits`: users with deposits, summing `confirmed_amount` (converted from kobo to naira)

- I joined all 3 CTEs to the `users_customuser` table to ensure the user:
  - Has both plan types
  - Has non-zero deposits
 
-  I used **scalar subqueries** in the `SELECT` to count how many of each plan type the user owns.

- The query was grouped and filtered ahead of time using CTEs to prevent row explosion from multiple joins.

### Challenges
- Initially, joining both `plans_plan` tables for different filters caused overcounting (row explosion).
- Solved this by using filtered **CTEs** instead of multiple joins, and `COUNT()` via **scalar subqueries** per user.
- I confirmed from the data and documentation that `confirmed_amount` is in **kobo**, and converted by dividing by `100`.

---

## ✅ Q2: Transaction Frequency Analysis

### Objective
Classify customers based on how often they perform savings transactions, and determine how many users fall into each category.

### Approach
- I used `savings_savingsaccount` to count how many times each customer transacts **per month**.
- In the first CTE (`MonthlyUserTransactions`), I grouped transactions by `owner_id`, `year`, and `month`.
- In the second CTE, I calculated the **average monthly transaction count** per customer.
- In the third CTE, I categorized each customer based on their frequency:
  - `≥10` → **High Frequency**
  - `3–9` → **Medium Frequency**
  - `≤2` → **Low Frequency**
- Finally, I grouped by category to count how many users fall into each group, and calculated the average monthly transaction frequency for each.

### Challenges
- I had to make sure I was grouping by both year and month to avoid inflating average values across years.
- The `FIELD()` function in `ORDER BY` helped maintain the required output order (High → Medium → Low).

---

## ✅ Q3: Account Inactivity Alert

### Objective
Identify active plans (savings or investments) that have not received any inflow transactions in over a year (365 days), so the ops team can flag them.

### Approach

- I created a CTE called `PlanLastTransaction` to get the **most recent transaction date per plan** using `MAX(created_at)` from `savings_savingsaccount`.
- I joined that CTE with the `plans_plan` table to get plan metadata like `owner_id` and plan type.
- I used `DATEDIFF()` to compute the number of days since the last transaction.
- I filtered for plans where `inactivity_days > 365`.
- I used a `CASE` statement to label each plan as either "Savings" or "Investment" based on the flags `is_regular_savings` and `is_a_fund`.

### Challenges

- Some plans might have no inflow at all (i.e., not in `savings_savingsaccount`). To include those, a `LEFT JOIN` and `IS NULL` check could be added.
- But for now, I only considered plans that had **at least one inflow** in the past and are now inactive.
- The logic was a bit challenging.
---

## ✅ Q4: Customer Lifetime Value (CLV) Estimation

### Objective
Estimate customer lifetime value using tenure and transaction volume, based on the formula:

\[
\text{CLV} = \left( \frac{\text{total_transactions}}{\text{tenure}} \right) \times 12 \times \text{avg_profit_per_transaction}
\]

Where:
- Tenure is the number of months since the customer signed up
- Profit per transaction is 0.1% of transaction value

### Approach

- I used a CTE (`UserTransactionSummary`) to compute:
  - Total number of transactions per customer
  - Total value and total profit from those transactions
- I joined with `users_customuser` to get the `date_joined` field.
- I calculated tenure using `TIMESTAMPDIFF(MONTH, date_joined, CURDATE())`.
- I rewrote the formula as:  
  \[
  \text{CLV} = \left(\frac{12}{\text{tenure}}\right) \times \text{total_profit}
  \]
- I sorted the result by `estimated_clv` to prioritize highest-value users.

### Challenges

- I had to prevent division-by-zero errors by filtering out users with zero-month tenure.
- I confirmed that `confirmed_amount` is in kobo and converted to naira for monetary calculations.
- The logic was challenging.
