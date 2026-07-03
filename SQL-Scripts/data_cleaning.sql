


/* SQL script to detect and remove duplicate customers while keeping the most recent record. */
/* foreign key constraint problem is coming here */
delete from customer where customer_id not in (
	with ranked as(
	select c.customer_id,
	row_number() over(partition by c.customer_unique_id order by o.order_purchase_timestamp desc) as rk
	from customer c join orders o on c.customer_id=o.customer_id 
	order by rk 
	)
	select customer_id from ranked where rk=1
)

/* so first updated the order tables customer_id by replacing all the customer_ids of a particular customer
with the recent customer_id of that customer and then removed the duplicates from the customer_id
of the customer table */
with ranked as(
	select c.customer_id,c.customer_unique_id,
	row_number() over(partition by c.customer_unique_id order by o.order_purchase_timestamp desc) as rk
	from customer c join orders o on c.customer_id=o.customer_id 
	order by rk 
),
keeper as (
select  customer_id,customer_unique_id
from ranked 
where rk=1
),
duplicates as(
select customer_id,customer_unique_id
from ranked 
where rk>1
)
update orders
set customer_id = k.customer_id
from keeper k join duplicates d on k.customer_unique_id = d.customer_unique_id
where orders.customer_id = d.customer_id 

