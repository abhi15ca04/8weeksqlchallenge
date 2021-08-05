					--A. Pizza Metrics
--How many pizzas were ordered?
--How many unique customer orders were made?
--How many successful orders were delivered by each runner?
--How many of each type of pizza was delivered?
--How many Vegetarian and Meatlovers were ordered by each customer?
--What was the maximum number of pizzas delivered in a single order?
--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
--How many pizzas were delivered that had both exclusions and extras?
--What was the total volume of pizzas ordered for each hour of the day?
--What was the volume of orders for each day of the week?

update pizza_runner.customer_orders
set exclusions='null'
where exclusions in (NULL,'');

update pizza_runner.customer_orders
set extras='null'
where extras IN (NULL,'');

update pizza_runner.runner_orders
set cancellation='null'
where cancellation IN (NULL,'');

-- 1.How many pizzas were ordered?

select count(order_id) as totalPizzaOrdered
from pizza_runner.customer_orders;

--2.How many unique customer orders were made?

select count(distinct customer_id) as "Unique customers"
from pizza_runner.customer_orders;

--3.How many successful orders were delivered by each runner?

select count(order_id) as total_delivered
from pizza_runner.runner_orders
where duration NOT in ('null');

--4.How many of each type of pizza was delivered?

select c.pizza_id,p.pizza_name,count(*) as NumberOfPizzaOrdered
from pizza_runner.customer_orders as c
inner join pizza_runner.pizza_names as p
on c.pizza_id=p.pizza_id
group by c.pizza_id,p.pizza_name
order by NumberOfPizzaOrdered desc;

--5.How many Vegetarian and Meatlovers were ordered by each customer?

select c.customer_id,p.pizza_name,count(*) as NumberOfPizzaOrdered
from pizza_runner.customer_orders as c
inner join pizza_runner.pizza_names as p
on c.pizza_id=p.pizza_id
group by c.customer_id,p.pizza_name
order by c.customer_id;


--6.What was the maximum number of pizzas delivered in a single order?
select  max(t.maxOrder) as MaxPizzasDelivered_SingleOrder
from(
select c.order_id,row_number() over(partition by c.order_id order by c.order_id) as maxOrder
 FROM pizza_runner.customer_orders AS c
 inner join pizza_runner.runner_orders as r
 on c.order_id=r.order_id and r.pickup_time NOT LIKE '%null%'
) as t;

--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select c.customer_id,count(*) as totalPizza,
count(CASE
      		when c.exclusions NOT IN ('null') or c.extras NOT IN ('null') THEN 1
      		
     		end 
       ) as AtleastOneChnages,
 
 count(CASE
      		when c.exclusions IN ('null') and c.extras IN ('null') THEN 1
      		
     		end 
      ) as NoChnages
  from pizza_runner.customer_orders as c
  inner join pizza_runner.runner_orders as r
  on c.order_id=r.order_id AND r.pickup_time NOT IN ('null')
  group by c.customer_id
  order by c.customer_id asc;
  
  
--8.How many pizzas were delivered that had both exclusions and extras?
select count(pizza_id) as TotalPizzaWithBothChanges
from
(select c.order_id,customer_id,pizza_id,exclusions,extras
from pizza_runner.customer_orders as c
inner join pizza_runner.runner_orders as r
on c.order_id=r.order_id and r.pickup_time not in ('null')) as t
where exclusions not in ('null') and extras not in ('null');
                                                  
                                                   
--9.What was the total volume of pizzas ordered for each hour of the day?
  
select EXTRACT(hour from order_time) as hour_of_day,count(pizza_id)as PizzaSalesEachHour
from pizza_runner.customer_orders
group by hour_of_day
order by hour_of_day;

--10.What was the volume of orders for each day of the week?
                                                   
select to_char(order_time,'Day') as week_of_day,count(pizza_id)as PizzaSaleEachWeek
from pizza_runner.customer_orders
group by week_of_day
order by PizzaSaleEachWeek asc;                                                   
                                                   
                                                   
                                   
                            
                                                   
                                                   