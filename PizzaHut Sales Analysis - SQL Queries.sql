create database pizzahut ; 

use pizzahut ;

---------------------------------------------CREATE TABLE FOR IMPORT FILE--------------------------------------------------

create table orders ( 
order_id int primary key not null,
order_date date not null,
order_time time not null
);

create table order_details (
order_details_id int primary key not null,
order_id int not null,
pizza_id text not null,
quanity int not null );

-------------------------------------------------------------------- QUESTIONS -------------------------------------------------------------------

----------------------------------------------------------------- BASICS LEVEL -----------------------------------------------------------------------

----- QUS.1) RETRIVE THE TOTAL NUMBER OF ORDERS PLACED
SELECT 
    COUNT(order_id) total_orders
FROM
    orders


----- QUS.2) CALCULATE THE TOTAL REVENUE GENERATED FROM PIZZA SALES
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_sales
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id;


----- QUS.3) IDENTIFY THE HIGEST PRICED PIZZA
SELECT 
    pt.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1


----- QUS.4) IDENTIFY THE MOST COMMON PIZZA SIZE ORDERED 
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;


----- QUS.5) LIST THE TOP 5 MOST ORDERED PIZZA TYPES ALONG WITH THEIR QUANTITES.
SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5


----------------------------------------------------------------- INTERMEDIATE LEVEL -----------------------------------------------------------------------

----- QUS.1) JOIN THE NECESSARY TABLES TO FIND THE TOTAL QUANTITY OF EACH PIZZA CATEGORY ORDERED
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC


----- QUS.2) DETERMINE THE DISTRIBUTION OF ORDERS BY HOUR OF THE DAY.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour
ORDER BY hour


----- QUS.3) JOIN RELEVENT TABLES TO FIND THE CATEGORY-WISE DISTRIBUTION OF PIZZAS
SELECT 
    category, COUNT(name) AS pizza_name
FROM
    pizza_types
GROUP BY category


----- QUS.4) GROUP THE ORDERS BY DATE AND CALCULATE THE AVERAGE NUMBER OF PIZZAS ORDERED PER DAY
SELECT 
    ROUND(AVG(quantity), 2) as Average_pizza_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity


----- QUS.5) DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE
select pt.name, sum(od.quantity * p.price) as revenue from pizza_types as pt
join pizzas as p on pt.pizza_type_id = p.pizza_type_id
join order_details as od on p.pizza_id = od.pizza_id
group by pt.name order by revenue desc limit 3



----------------------------------------------------------------- ADVANCED LEVEL -----------------------------------------------------------------------

----- QUS.1) CALCULATE THE PERCENTAGE CONTRIBUTION OF EACH PIZZA TYPE TO TOTAL REVENUE
SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS total_sales
                FROM
                    order_details AS od
                        JOIN
                    pizzas AS p ON od.pizza_id = p.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category


----- QUS.2) ANALYZE THE CUMULATIVE REVENUE GENEREATED OVER TIME
select order_date,
sum(revenue) over(order by order_date) as cumulative_revenue
from 
(select o.order_date, round(sum(od.quantity * p.price),2) as revenue from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id 
join orders as o on od.order_id = o.order_id
group by o.order_date ) as sales 


----- QUS.3) DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE FOR EACH PIZZA CATEGORY
  select category, name, revenue from
  (select category, name, revenue,
  dense_rank() over(partition by category order by revenue desc) as rnk from
(select pt.category, pt.name, round(sum(od.quantity * p.price),2) as revenue from pizza_types as pt
  join pizzas as p on pt.pizza_type_id = p.pizza_type_id
  join order_details as od on p.pizza_id = od.pizza_id
  group by pt.category, pt.name) as a) as b 
  where rnk <= 3
