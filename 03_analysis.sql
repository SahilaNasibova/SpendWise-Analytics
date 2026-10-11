-- 1. Monthly inflows, outflows and cashflow.
WITH monthly AS (
 SELECT customer_id, TRUNC(transaction_date,'MM') mon,
 SUM(CASE WHEN direction='IN' THEN amount ELSE 0 END) income,
 SUM(CASE WHEN direction='OUT' THEN amount ELSE 0 END) spending
 FROM im_transactions GROUP BY customer_id,TRUNC(transaction_date,'MM')
)
SELECT customer_id,mon,income,spending,income-spending net_cashflow,
 ROUND(100*spending/NULLIF(income,0),1) spend_income_pct
FROM monthly ORDER BY customer_id,mon;

-- 2. Customers spending over 80% of monthly income.
WITH monthly AS (
 SELECT customer_id,TRUNC(transaction_date,'MM') mon,
 SUM(CASE WHEN direction='IN' THEN amount ELSE 0 END) income,
 SUM(CASE WHEN direction='OUT' THEN amount ELSE 0 END) spending
 FROM im_transactions GROUP BY customer_id,TRUNC(transaction_date,'MM')
)
SELECT * FROM monthly WHERE income>0 AND spending/income>=0.8
ORDER BY customer_id,mon;

-- 3. Month-over-month spending changes using LAG.
WITH monthly AS (
 SELECT customer_id,TRUNC(transaction_date,'MM') mon,SUM(amount) spending
 FROM im_transactions WHERE direction='OUT'
 GROUP BY customer_id,TRUNC(transaction_date,'MM')
), changes AS (
 SELECT customer_id,mon,spending,
 LAG(spending) OVER (PARTITION BY customer_id ORDER BY mon) prev_spending
 FROM monthly
)
SELECT customer_id,mon,spending,prev_spending,
 ROUND(100*(spending-prev_spending)/NULLIF(prev_spending,0),1) mom_change_pct
FROM changes ORDER BY customer_id,mon;

-- 4. Recurring subscription spend and share of outgoing payments.
SELECT customer_id,
 SUM(CASE WHEN category='SUBSCRIPTION' AND direction='OUT' THEN amount ELSE 0 END) subscription_total,
 SUM(CASE WHEN direction='OUT' THEN amount ELSE 0 END) outgoing_total,
 ROUND(100*SUM(CASE WHEN category='SUBSCRIPTION' AND direction='OUT' THEN amount ELSE 0 END)/
 NULLIF(SUM(CASE WHEN direction='OUT' THEN amount ELSE 0 END),0),1) subscription_share_pct
FROM im_transactions GROUP BY customer_id ORDER BY subscription_share_pct DESC;

-- 5. Rule-based behavior flags (not a validated churn or fraud prediction).
WITH monthly AS (
 SELECT customer_id,TRUNC(transaction_date,'MM') mon,
 SUM(CASE WHEN direction='IN' THEN amount ELSE 0 END) income,
 SUM(CASE WHEN direction='OUT' THEN amount ELSE 0 END) spending
 FROM im_transactions GROUP BY customer_id,TRUNC(transaction_date,'MM')
)
SELECT customer_id, mon, income, spending,
 CASE WHEN spending>income THEN 'NEGATIVE_CASHFLOW'
 WHEN spending>=income*0.8 THEN 'HIGH_SPEND_RATIO'
 ELSE 'NORMAL' END behavior_flag
FROM monthly ORDER BY customer_id,mon;
