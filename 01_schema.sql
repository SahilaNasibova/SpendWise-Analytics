CREATE TABLE im_customers (
 customer_id NUMBER PRIMARY KEY,
 segment VARCHAR2(20) NOT NULL,
 join_date DATE NOT NULL
);
CREATE TABLE im_transactions (
 transaction_id NUMBER PRIMARY KEY,
 customer_id NUMBER NOT NULL REFERENCES im_customers(customer_id),
 transaction_date DATE NOT NULL,
 amount NUMBER(12,2) NOT NULL CHECK (amount > 0),
 direction VARCHAR2(6) NOT NULL CHECK (direction IN ('IN','OUT')),
 category VARCHAR2(30) NOT NULL,
 merchant VARCHAR2(60)
);
CREATE INDEX ix_im_tx_customer_date ON im_transactions(customer_id,transaction_date);
