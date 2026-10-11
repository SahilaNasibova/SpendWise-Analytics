INSERT INTO im_customers VALUES (1,'MASS',DATE '2024-02-01');
INSERT INTO im_customers VALUES (2,'MASS',DATE '2023-06-01');
INSERT INTO im_customers VALUES (3,'PREMIUM',DATE '2025-01-15');
INSERT INTO im_customers VALUES (4,'MASS',DATE '2022-11-20');
INSERT INTO im_customers VALUES (5,'PREMIUM',DATE '2024-08-04');
-- Synthetic monthly salary and spending data across 6 months.
INSERT INTO im_transactions
SELECT (c.customer_id*10000)+(m.month_id*100)+1, c.customer_id,
 ADD_MONTHS(DATE '2026-01-05',m.month_id-1),
 CASE WHEN c.customer_id=4 THEN 1200 ELSE 1500+c.customer_id*300 END,
 'IN','SALARY','Employer'
FROM im_customers c CROSS JOIN (SELECT LEVEL month_id FROM dual CONNECT BY LEVEL<=6) m;
INSERT INTO im_transactions
SELECT (c.customer_id*10000)+(m.month_id*100)+2, c.customer_id,
 ADD_MONTHS(DATE '2026-01-08',m.month_id-1),
 CASE WHEN c.customer_id=1 THEN 1600 WHEN c.customer_id=2 THEN 2700
 WHEN c.customer_id=3 THEN 800 + m.month_id*250 WHEN c.customer_id=4 THEN 1000
 ELSE 1200 END,
 'OUT','SHOPPING','Retail'
FROM im_customers c CROSS JOIN (SELECT LEVEL month_id FROM dual CONNECT BY LEVEL<=6) m;
INSERT INTO im_transactions
SELECT (c.customer_id*10000)+(m.month_id*100)+3, c.customer_id,
 ADD_MONTHS(DATE '2026-01-11',m.month_id-1),
 CASE WHEN c.customer_id=2 THEN 300 ELSE 80 END,
 'OUT','SUBSCRIPTION','Streaming'
FROM im_customers c CROSS JOIN (SELECT LEVEL month_id FROM dual CONNECT BY LEVEL<=6) m;
INSERT INTO im_transactions
SELECT (c.customer_id*10000)+(m.month_id*100)+4, c.customer_id,
 ADD_MONTHS(DATE '2026-01-18',m.month_id-1),
 CASE WHEN c.customer_id=4 THEN 500 ELSE 250 END,
 'OUT','BILLS','Utilities'
FROM im_customers c CROSS JOIN (SELECT LEVEL month_id FROM dual CONNECT BY LEVEL<=6) m;
COMMIT;
