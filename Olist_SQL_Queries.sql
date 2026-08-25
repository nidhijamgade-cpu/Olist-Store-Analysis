CREATE DATABASE OLIST;
USE OLIST;
show columns from `customer dataset`;

show columns from `geolocation dataset`;

show columns from `order dataset`;

show columns from `order items dataset`;

show columns from `order payment dataset`;

show columns from `order review dataset`;

show columns from `product category name translation`;

show columns from `seller dataset`;

show columns from `product dataset`;

ALTER TABLE `order dataset`
CHANGE COLUMN `ï»¿order_id` `order_id` TEXT;

ALTER TABLE `customer dataset`
CHANGE COLUMN `ï»¿customer_id` `customer_id` TEXT;

ALTER TABLE `order items dataset`
CHANGE COLUMN `ï»¿order_id` `order_id` TEXT;

ALTER TABLE `order payment dataset`
CHANGE COLUMN `ï»¿order_id` `order_id` TEXT;

ALTER TABLE `order review dataset`
CHANGE COLUMN `ï»¿review_id` `review_id` TEXT;

ALTER TABLE `seller dataset`
CHANGE COLUMN `ï»¿seller_id` `seller_id` TEXT;

ALTER TABLE `geolocation dataset`
CHANGE COLUMN `ï»¿geolocation_zip_code_prefix` `geolocation_zip_code_prefix` INT;

ALTER TABLE `product category name translation`
CHANGE COLUMN `ï»¿product_category_name` `product_category_name` TEXT;

ALTER TABLE `product dataset`
CHANGE COLUMN `ï»¿product_id` `product_id` TEXT;

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

/* KPI 1 Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
   KPI 2 Number of Orders with review score 5 and payment type as credit card.
   KPI 3Average number of days taken for order_delivered_customer_date for pet_shop
   KPI 4 Average price and payment values from customers of sao paulo city
   KPI 5 Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.*/
 

   # KPI 1 Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
   
SELECT
    CASE
        WHEN DAYOFWEEK(STR_TO_DATE(ord.order_purchase_timestamp,'%d-%m-%Y %H:%i')) IN (1,7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    COUNT(DISTINCT ord.order_id) AS Total_Orders,
    ROUND(SUM(pay.payment_value),2) AS Total_Payment
FROM `order dataset` ord
JOIN `order payment dataset` pay
ON ord.order_id = pay.order_id
GROUP BY Day_Type
ORDER BY Day_Type;


#  KPI 2 Number of Orders with review score 5 and payment type as credit card.

SELECT COUNT(DISTINCT od.order_id) AS total_orders
FROM `order dataset` od
JOIN `orders reviews dataset` ord
ON od.order_id = ord.order_id
JOIN `order payment dataset` opd
ON od.order_id = opd.order_id
WHERE ord.review_score = 5
AND opd.payment_type = 'credit_card';

# KPI 3 Average number of days taken for order_delivered_customer_date for pet_shop
  

SELECT
ROUND(
AVG(
DATEDIFF(
STR_TO_DATE(od.order_delivered_customer_date,'%d-%m-%Y %H:%i'),
STR_TO_DATE(od.order_purchase_timestamp,'%d-%m-%Y %H:%i')
)
),2) AS avg_delivery_days
FROM `order dataset` od
JOIN `order items dataset` oid
ON od.order_id = oid.order_id
JOIN `product dataset` pd
ON oid.product_id = pd.product_id
JOIN `product category name translation` pct
ON pd.product_category_name = pct.product_category_name
WHERE pct.product_category_name_english='pet_shop'
AND od.order_delivered_customer_date IS NOT NULL;

 # KPI 4 Average price and payment values from customers of sao paulo city

SELECT
    ROUND(AVG(oi.price),2) AS avg_price,
    ROUND(AVG(op.payment_value),2) AS avg_payment_value
FROM `customer dataset` c
JOIN `order dataset` o
ON c.customer_id = o.customer_id
JOIN `order items dataset` oi
ON o.order_id = oi.order_id
JOIN `order payment dataset` op
ON o.order_id = op.order_id
WHERE LOWER(c.customer_city) = 'sao paulo';

# KPI 5 Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

SELECT
    orv.review_score,
    FLOOR(
        AVG(
            DATEDIFF(
                STR_TO_DATE(od.order_delivered_customer_date,'%d-%m-%Y %H:%i'),
                STR_TO_DATE(od.order_purchase_timestamp,'%d-%m-%Y %H:%i')
            )
        )
    ) AS avg_shipping_days
FROM `order dataset` od
JOIN `orders reviews dataset` orv
ON od.order_id = orv.order_id
WHERE od.order_delivered_customer_date IS NOT NULL
GROUP BY orv.review_score
ORDER BY orv.review_score DESC;
