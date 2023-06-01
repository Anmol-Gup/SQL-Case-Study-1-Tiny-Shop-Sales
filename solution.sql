-- Case Study Questions
--1) Which product has the highest price? Only return a single row.
SELECT 
	product_name 
FROM 
	products 
WHERE price=(SELECT MAX(price) FROM products);

--2) Which customer has made the most orders?
SELECT 
  	c.*,COUNT(*)
FROM 
	customers c JOIN orders o
ON 
  c.customer_id=o.customer_id
GROUP BY c.customer_id
HAVING COUNT(*)=(
  SELECT 
  	MAX(temp.Total_Orders) 
  FROM 
  (
  	SELECT 
  		COUNT(*) AS Total_Orders
	FROM 
    	customers c JOIN orders o
	ON 
  		c.customer_id=o.customer_id
	GROUP BY c.customer_id
  ) temp
 )
 ORDER BY c.customer_id;
 
--3) What’s the total revenue per product?
SELECT 
  p.product_name,SUM(price*quantity) AS revenue
FROM
	products p JOIN order_items o
ON
	p.product_id=o.product_id
GROUP BY p.product_name
ORDER BY revenue DESC

--4) Find the day with the highest revenue.
SELECT order_date,SUM(price*quantity) AS revenue
FROM 
  order_items oi JOIN products p
ON 
  p.product_id=oi.product_id
JOIN 
  orders o 
ON 
  o.order_id=oi.order_id
GROUP BY order_date
ORDER BY revenue DESC
LIMIT 1

--5) Find the first order (by date) for each customer.
WITH first_order_cte
AS
(
  SELECT 
    customer_id, 
    MIN(order_date) AS first_order_date
  FROM orders
  GROUP BY customer_id
)
SELECT first_name,last_name,first_order_date FROM customers c
JOIN first_order_cte o 
ON o.customer_id=c.customer_id

--6) WITH distinct_products_cte
AS
(
  SELECT customer_id,COUNT(DISTINCT product_id) AS total_distinct_products 
  FROM orders o JOIN order_items oi
  ON
      oi.order_id=o.order_id
  GROUP BY customer_id
  ORDER BY total_distinct_products DESC
  LIMIT 3
)
SELECT first_name,last_name
FROM customers c JOIN distinct_products_cte t
ON
	t.customer_id=c.customer_id
WITH distinct_products_cte
AS
(
  SELECT customer_id,COUNT(DISTINCT product_id) AS total_distinct_products 
  FROM orders o JOIN order_items oi
  ON
      oi.order_id=o.order_id
  GROUP BY customer_id
  ORDER BY total_distinct_products DESC
  LIMIT 3
)
SELECT first_name,last_name,total_distinct_products
FROM customers c JOIN distinct_products_cte t
ON
	t.customer_id=c.customer_id
  
--7) Which product has been bought the least in terms of quantity?
SELECT 
	product_name,SUM(quantity) AS Qty_Sold
FROM 
	order_items oi JOIN products p
ON
	oi.product_id=p.product_id
GROUP BY product_name
ORDER BY Qty_Sold
LIMIT 3

--8) What is the median order total?
WITH cte1
AS
(
  SELECT *,ROW_NUMBER() over(ORDER BY revenue DESC) AS revenue_desc,
  ROW_NUMBER() OVER(ORDER BY revenue) AS revenue_asc
  FROM
  (
  SELECT order_id,SUM(price*quantity) AS revenue
  FROM products p JOIN order_items oi
  ON oi.product_id=p.product_id
  GROUP BY order_id
  ) temp
)
SELECT ROUND(AVG(revenue),2) FROM cte1
WHERE revenue_asc IN (revenue_desc-1,revenue_desc,revenue_desc+1);

--9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.
WITH price_bracket_cte
AS
(
  SELECT order_id,SUM(price*quantity) AS revenue
  FROM 
      order_items oi JOIN products p
  ON 
      oi.product_id=p.product_id
  GROUP BY order_id
)
SELECT 
	order_id,revenue,
	CASE 
    	WHEN Revenue>300 THEN 'Expensive'
    	WHEN Revenue>100 THEN 'Affordable' 
        ELSE 'Cheap'
    END AS Revenue_Status
FROM price_bracket_cte

--10) Find customers who have ordered the product with the highest price.
SELECT c.customer_id,first_name,last_name 
FROM orders o JOIN customers c
ON
	c.customer_id=o.customer_id
WHERE order_id in (
  SELECT order_id 
  FROM order_items 
  WHERE product_id=(
    SELECT product_id 
    FROM products
    ORDER BY price DESC
    LIMIT 1
  )
);
