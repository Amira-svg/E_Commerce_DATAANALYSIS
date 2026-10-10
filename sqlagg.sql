--Total customer
select
count(customer_id)as total_customers
from Customers
--Total orders per customer



--total items sold
--Avg product price
select avg(price) as Avg_product_price
from Order_Items
--avg order value
select avg(payment_value) as avg_order_value
from Orders_Payment





--total seller
select 
count(seller_id) as total_seller
from Seller
--total seller sales
SELECT count(t1.seller_id) as total_seller_sales
FROM Seller t1
INNER JOIN Order_Items t2 ON t1.seller_id = t2.seller_id 
INNER JOIN Orders t3 ON t2.order_id = t3.order_id                    
WHERE order_status = 'Delivered';  
--avg dilvary days
select
avg(DAY(order_estimated_delivery_date)) as avg_dilvary_days
from Orders
--total payment
select  
sum(payment_value)AS total_payment
from Orders_Payment








--Total prodct sales
select
count(product_id) As Total_prodct_sales
from Products

--total orders
select 
count(order_id)As total_orders
from orders
--averge review score
select 
avg(review_score)as review_score
from Review
--avg freight cost
select 
avg(freight_value)as freight_cost
from Order_Items




--total sales
select
count(product_id) As Total_sales
from Products
--avg item pric
select 
avg(price) as item_price
from Order_Items
--total items sold
select 
COUNT(order_item_id) as total_orders_sold
from Order_Items








--total sales by state
select count(product_id) as total_sales_by_state
from Order_Items t1 
inner join Orders t2 on t1.order_id=t2.order_id
inner join Customers t3 on t3.customer_id=t2.customer_id
group by t3.customer_state



--total customer by state
select count(customer_id) as total_customer
from Customers 
group by customer_state


--total customer per month
select count(t1.customer_id) as total_customer_per_month
from customers t1
inner join Orders t2 on t1.customer_id=t2.customer_id
group by month(order_delivered_customer_date)









--sales by order
select count(product_id) as sales
from Order_Items
group by order_id


--sales by seller state
select count(t1.product_id) as sales
from Order_Items t1
inner join seller t2 on t1.seller_id=t2.seller_id
group by seller_state


--avg freight cost per seller
select avg(freight_value) avg_freight_cost
from Order_Items
group by seller_id

--payment  by method
select sum(payment_value) as total_payment
from Orders_Payment
group by payment_type
--review score by cate
select sum(t1.review_score) as review_score_by_cate
from Review t1
inner join Order_Items t2 on t1.order_id=t2.order_id
inner join Products t3 on t2.product_id=t3.product_id
group by product_category_name


--top  seller by sales
select top 10 count(seller_id)
from Order_Items 
group by product_id


--avg order value by saller
select avg(t1.payment_value) as avg_order_value_by_saller
from Orders_Payment t1 
inner join Orders t2 on t1.order_id=t2.order_id
inner join Order_Items t3 on t2.order_id=t3.order_id
group by t3.seller_id




--total sales per month
select count(t1.product_id) as total_sales_per_month
from Products t1
inner join Order_Items t2 on t1.product_id=t2.product_id
inner join Orders t3 on t3.order_id=t3.order_id
group by month(t3.order_estimated_delivery_date)


--total order per month
select count (order_id) as total_order_per_month
from Orders
group by month(order_estimated_delivery_date)

--sales by product cat
select count(product_id) as sales_by_product_cat
from Products
group by product_category_name

--sales by day of week
select count(t1.product_id) as sales_by_day_of_week
from Products t1
inner join Order_Items t2 on t1.product_id=t2.product_id
inner join Orders t3 on t2.order_id=t3.order_id
group by day(order_estimated_delivery_date)
--top  product cat by sales
select top 5 count(product_id) as top5_sales_by_product_sales
from Products
group by product_category_name







--total quantites by product cat
select count(t1.order_item_id) as total_quantites
from Order_Items t1
INNER JOIN products t2 ON t1.product_id = t2.product_id
group by t2.product_category_name


--avg product price by cate
select avg(t1.price) as avg_price
from Order_Items t1
INNER JOIN products t2 ON t1.product_id = t2.product_id
group by t2.product_category_name

--avg freight cost by categ
select avg(t1.freight_value) as avg_freight_cost
from Order_Items t1
INNER JOIN products t2 ON t1.product_id = t2.product_id
group by t2.product_category_name