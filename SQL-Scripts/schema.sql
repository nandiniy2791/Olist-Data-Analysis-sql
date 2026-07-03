create table customer(
customer_id varchar(32) primary key,
customer_unique_id varchar(32) not null,
customer_zip_code_prefix text,
customer_city varchar(100),
customer_state varchar(20),
check (length(customer_id) = 32)
);
select * from customer;


create table orders(
order_id varchar(32) primary key,
customer_id varchar(32) references customer(customer_id),
order_status varchar(30),
order_purchase_timestamp timestamp,
order_approved_at timestamp,
order_delivered_carrier_date timestamp,
order_delivered_customer_date timestamp,
order_estimated_delivery_date timestamp
);
select * from orders;


create table order_reviews(
review_id varchar(32),
order_id varchar(32) references orders(order_id),
review_score int,
review_comment_title text,
review_comment_message text,
review_creation_date timestamp,
review_answer_timestamp timestamp,
primary key (review_id,order_id)
);
select * from order_reviews limit 5;


create table order_payments(
order_id varchar(32) references orders(order_id),
payment_sequential int ,
payment_type varchar(20),
payment_installments int,
payment_value numeric(10,2),
primary key (order_id,payment_sequential)
)
select * from order_payments limit 5;


create table product_category_name_translation(
product_category_name text primary key,
product_category_name_english text
)
select count(distinct product_category_name ) from product_category_name_translation;
insert into product_category_name_translation(
product_category_name 
)
values('portateis_cozinha_e_preparadores_de_alimentos'),('pc_gamer');


create table products(
product_id  varchar(32) primary key,
product_category_name text /*references product_category_name_translation(product_category_name)*/,
product_name_lenght int,
product_description_lenght int,
product_photos_qty int,
product_weight_g int,
product_length_cm int,
product_height_cm int,
product_width_cm int 
)
alter table products
add constraint product_category_name_fk 
foreign  key (product_category_name) references product_category_name_translation(product_category_name);

SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN product_category_name_translation t
ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL
AND p.product_category_name IS NOT NULL;

create table seller(
seller_id varchar(32) primary key,
seller_zip_code_prefix text,
seller_city varchar(100),
seller_state varchar(20)
)
create table 
order_items (
order_id varchar(32) references orders(order_id),
order_item_id varchar(32),
product_id varchar(32) references products(product_id),
seller_id varchar(32) references seller(seller_id),
shipping_limit_date timestamp,
price numeric(10,2),
freight_value real,
primary key (order_id,order_item_id)
)

create table geolocation(
geolocation_zip_code_prefix text,
geolocation_lat double precision,
geolocation_lng double precision,
geolocation_city varchar(100),
geolocation_state varchar(10)
)
select * from geolocation;

/* Disconnect all users from the source db because postgre wont let you copy a database that is actively being used*/
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = 'olist' AND pid <> pg_backend_pid();
/* copy of the db is created */
create database olist_org
with template olist;