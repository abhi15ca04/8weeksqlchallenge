/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Example Query:

--1.What is the total amount each customer spent at the restaurant?

select s.customer_id,sum(m.price) as TotalAmountspent
FROM dannys_diner.sales as s
inner join dannys_diner.menu as m
on s.product_id=m.product_id
group by customer_id
order by customer_id asc;

--2.How many days has each customer visited the restaurant?
select customer_id,count(distinct order_date) as NumberOfVist
from dannys_diner.sales
group by customer_id;



--3. What was the first item from the menu purchased by each customer?

select customer_id,order_date,product_name as FirstOrder
from(select s.customer_id,s.order_date,m.product_name,
dense_rank() over(partition by s.customer_id order by s.order_date) as rnk
from dannys_diner.sales as s
inner join dannys_diner.menu as m
on s.product_id=m.product_id) as t
where t.rnk=1;



 --4. What is the most purchased item on the menu and how many times was it p
 
 select m.product_name,count(*) as MostSaleItem
 from dannys_diner.sales as s
 inner join dannys_diner.menu as m
 on s.product_id=m.product_id
 group by m.product_name
 order by MostSaleItem desc
 limit 1;
 
 -- 5. Which item was the most popular for each customer?

with cte_max as
(select customer_id,product_id,count(product_id) as cnt,
dense_rank() over(partition by customer_id order by count(product_id) desc) as rnk
from dannys_diner.sales
group by customer_id,product_id)


select c.customer_id,m.product_name,cnt
from cte_max as c
inner join dannys_diner.menu as m 
on c.product_id=m.product_id
where rnk=1
order by c.customer_id;

-- 6. Which item was purchased first by the customer after they became a member?

with cte_first as 
(select s.customer_id ,s.product_id,(s.order_date-m.join_date) as days,
dense_rank() over(partition by s.customer_id order by (s.order_date-m.join_date)) as rnk
from dannys_diner.sales as s
inner join dannys_diner.members as m
on s.customer_id=m.customer_id and s.order_date>=m.join_date) 
 
 
 select c.customer_id,p.product_name
 from cte_first as c
 inner join dannys_diner.menu as p
 on c.product_id=p.product_id
 where rnk=1;
 
 
 --7. Which item was purchased just before the customer became a member?

with cte_before as                   
(select s.customer_id,s.product_id,(m.join_date-s.order_date) as days,
dense_rank() over(partition by s.customer_id order by (m.join_date-s.order_date)) as rnk
from dannys_diner.sales as s
inner join dannys_diner.members as m
on s.customer_id=m.customer_id and m.join_date>s.order_date)
                  
select c.customer_id,m.product_name
from cte_before as c
inner join dannys_diner.menu as m
on c.product_id=m.product_id
where rnk=1;
                  
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
                  
  
select s.customer_id,
          sum( case
                  when s.product_id=1 then price*20
                  else price*10
                  end ) as totalpoint
    from dannys_diner.sales as s
    inner join dannys_diner.menu as m
    on s.product_id=m.product_id
    group by s.customer_id;
                  
                  
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
                  
select s.customer_id,--s.order_date,p.join_date,m.product_id,m.price,  
                   sum(case
                     	when  s.order_date>=p.join_date and (s.order_date-p.join_date)<=7 then price*20
                        else price *10
                        end) as totalpoint
from dannys_diner.sales as s
 inner join dannys_diner.menu as m
 on s.product_id=m.product_id
 inner join dannys_diner.members as p
 on s.customer_id=p.customer_id
 where s.order_date<='2021-01-31'
 group by s.customer_id;
                  
                  
                  
                  											--Bonus Questions
                  
                  
 select s.customer_id,s.order_date,m.product_name,m.price,
                  case
                  		when (e.customer_id=s.customer_id) AND (s.order_date>=e.join_date) then 'Y'
                  		else 'N'
                  end as member
                  
 from dannys_diner.sales as s
 inner join dannys_diner.menu as m
 on s.product_id = m.product_id
 left join dannys_diner.members as e
 on e.customer_id=s.customer_id
 order by s.customer_id,s.order_date;
                      
                                                      
  
 