количество уникальных покупателей в таблице customers:
select
COUNT(customer_id) as customers_count
from customers;

--топ-10 продавцов по сумме выручки:
select
CONCAT(e.first_name, ' ', e.last_name) as seller,
COUNT(s.sales_id),
FLOOR(SUM(s.quantity * p.price)) as income
from sales s
left join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id 
group by seller
order by income desc
limit 10;

-- список продавцов выручка которых ниже средней выручки всех продавцов:
with tab as (
select
CONCAT(e.first_name, ' ', e.last_name) as seller,
FLOOR(AVG(s.quantity * p.price)) as average_income,
(select FLOOR(AVG(s.quantity * p.price)) from sales s left join products p on s.product_id = p.product_id) as average_income_all
from sales s 
left join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id
group by seller)

select
seller,
average_income
from tab
where average_income < average_income_all
order by average_income asc;

--выручка продавцов по дням недели:
with tab as (
select
CONCAT(e.first_name, ' ', e.last_name) as seller,
to_char(s.sale_date, 'day') as day_of_week,
EXTRACT(isodow from s.sale_date) as day_number,
FLOOR(SUM(s.quantity * p.price)) as income
from sales s
inner join employees e on s.sales_person_id = e.employee_id
left join products p on s.product_id = p.product_id
group by seller, day_of_week, day_number
order by day_number, seller
)

select
seller,
day_of_week,
income
from tab;
