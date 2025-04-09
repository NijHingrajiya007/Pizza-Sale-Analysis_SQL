----'TABLES'
SELECT * FROM pizza_types
SELECT * FROM orders
SELECT * FROM order_details
SELECT * FROM pizzas


1. Retrieve the total number of orders placed.

SELECT COUNT(*) FROM orders


2. Calculate the total revenue generated from pizza sales.

SELECT SUM(p.price) as total FROM order_details as od
JOIN pizzas as p ON p.pizza_id=od.pizza_id


3.Identify the highest-priced pizza.

SELECT * FROM pizzas
ORDER BY price DESC
LIMIT 1


4.Identify the most common pizza size ordered.

SELECT p.size, COUNT(od.pizza_id) as c FROM order_details as od
JOIN pizzas as p ON p.pizza_id=od.pizza_id
GROUP BY p.size
order BY c DESC
LIMIT 1


5. List the top 5 most ordered pizza types along with their quantities.

SELECT COUNT(od.quantity) as count_, pt.pizza_types as types_, pt.name FROM order_details as od
JOIN pizzas as p ON p.pizza_id=od.pizza_id
JOIN pizza_types as pt ON pt.pizza_types=p.pizza_type_id
GROUP BY types_, pt.name
ORDER BY count_ DESC
LIMIT 5


6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category, COUNT(od.quantity) FROM order_details as od
JOIN pizzas as p ON p.pizza_id=od.pizza_id
JOIN pizza_types as pt ON pt.pizza_types=p.pizza_type_id
GROUP BY 1
ORDER BY 2 DESC


7.Determine the distribution of orders by hour of the day.

SELECT EXTRACT(MONTH FROM o.date::DATE) as month , EXTRACT(DAY FROM o.date::DATE) as day, EXTRACT(HOUR FROM o.time::TIME) as hour, COUNT(od.quantity) FROM orders as o 
JOIN order_details as od ON od.order_id=o.order_id
GROUP BY month, day, hour
ORDER BY 1,2,3 


8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, COUNT(name) FROM pizza_types
GROUP BY category


9. Group the orders by date and calculate the average number of pizzas ordered per day.
	
1)
WITH MDC AS(
SELECT EXTRACT(MONTH FROM o.date::DATE) as month, EXTRACT(DAY FROM o.date::DATE) as day, COUNT(od.quantity) FROM orders as o 
JOIN order_details as od ON od.order_id=o.order_id
GROUP BY 1, 2
ORDER BY 1,2
)
SELECT AVG(count) FROM MDC

2)
SELECT AVG(count) FROM
(
SELECT EXTRACT(MONTH FROM o.date::DATE) as month, EXTRACT(DAY FROM o.date::DATE) as day, COUNT(od.quantity) FROM orders as o 
JOIN order_details as od ON od.order_id=o.order_id
GROUP BY 1, 2
ORDER BY 1,2
)


10. Determine the top 3 most ordered pizza types based on revenue.

SELECT COUNT(od.quantity),pt.name FROM order_details as od
JOIN pizzas as p ON p.pizza_id=od.pizza_id
JOIN pizza_types as pt ON pt.pizza_types=p.pizza_type_id
GROUP BY 2
ORDER BY 1 DESC
LIMIT 3


11. Calculate the percentage contribution of each pizza type to total revenue.

1)
WITH damn AS(
SELECT pt.category, pt.pizza_types, SUM(p.price) as total FROM order_details as od
JOIN pizzas as p ON p.pizza_id=od.pizza_id
JOIN pizza_types as pt ON pt.pizza_types=p.pizza_type_id
GROUP BY 1,2), 
full_total AS(
SELECT SUM(total) as ft FROM damn
)			
SELECT category, pizza_types,total*100/801944.70 as percent FROM damn

2)
WITH damn AS(
SELECT pt.category, SUM(p.price) as total FROM order_details as od
JOIN pizzas as p ON p.pizza_id=od.pizza_id
JOIN pizza_types as pt ON pt.pizza_types=p.pizza_type_id
GROUP BY 1), 
full_total AS(
SELECT SUM(total) as ft FROM damn
)			
SELECT category,total*100/801944.70 as percent FROM damn
ORDER BY percent DESC


12. Analyze the cumulative revenue generated over time.

WITH damn AS(
SELECT EXTRACT(MONTH FROM o.date::DATE) as month, EXTRACT(DAY FROM o.date::DATE) as day, SUM(p.price)as total FROM orders as o 
JOIN order_details as od ON od.order_id=o.order_id
JOIN pizzas as p ON p.pizza_id=od.pizza_id
GROUP BY 1,2
ORDER BY 1,2)
SELECT month,day, SUM(total) OVER(ORDER BY month,day) FROM damn


13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH damn AS(
SELECT pt.category, pt.name, SUM(od.quantity::NUMERIC) as total FROM order_details as od
JOIN pizzas as p ON p.pizza_id=od.pizza_id
JOIN pizza_types as pt ON pt.pizza_types=p.pizza_type_id
GROUP BY 1,2),
damn1 AS(
SELECT category, name, total, ROW_NUMBER() OVER(PARTITION BY category ORDER BY total DESC) as num FROM damn
)
SELECT category, name, total, num FROM damn1
WHERE num BETWEEN '1' AND '3'

