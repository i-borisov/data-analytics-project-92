--количество уникальных покупателей в таблице customers:
select COUNT(customer_id) as customers_count
from customers;

--топ-10 продавцов по сумме выручки:
select
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    COUNT(s.sales_id) as operations,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
left join products as p on s.product_id = p.product_id
inner join employees as e on s.sales_person_id = e.employee_id
group by seller
order by income desc
limit 10;

-- список продавцов выручка которых ниже средней выручки всех продавцов:
with tab as (
    select
        CONCAT(e.first_name, ' ', e.last_name) as seller,
        FLOOR(AVG(s.quantity * p.price)) as average_income,
        (select FLOOR(AVG(s.quantity * p.price))
        from sales as s
        left join products as p on s.product_id = p.product_id)
        as average_income_all
    from sales as s
    left join products as p on s.product_id = p.product_id
    inner join employees as e on s.sales_person_id = e.employee_id
    group by seller
    )

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
        TO_CHAR(s.sale_date, 'day') as day_of_week,
        EXTRACT(isodow from s.sale_date) as day_number,
        FLOOR(SUM(s.quantity * p.price)) as income
    from sales as s
    inner join employees as e on s.sales_person_id = e.employee_id
    left join products as p on s.product_id = p.product_id
    group by seller, day_of_week, day_number
    order by day_number, seller
)

select
    seller,
    day_of_week,
    income
from tab;

--количество покупателей по возрастным группам:
select
    case
        when c.age between 16 and 25 then '16-25'
        when c.age between 26 and 40 then '26-40'
        when c.age > 40 then '40+'
    end as age_category,
    COUNT(c.age) as age_count
from customers as c
group by age_category
order by age_category;

--количество покупателей и выручка по месяцам:
select
    TO_CHAR(sale_date, 'YYYY-MM') as selling_month,
    COUNT(distinct customer_id) as total_customers,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
left join products as p on s.product_id = p.product_id
group by selling_month
order by selling_month asc;

--покупатели, первая покупка которых пришлась на время специальных акций:
with tab as (
    select distinct s.customer_id,
p.price,
first_value(s.sales_id) OVER(partition by s.customer_id order by s.sale_date asc, p.price asc) as sales_id
from sales as s
left join products p on s.product_id = p.product_id
where price = 0
)

select
    CONCAT(c.first_name, ' ', c.last_name) as customer,
    s.sale_date,
    CONCAT(e.first_name, ' ', e.last_name) as seller
from sales as s
left join customers as c ON s.customer_id = c.customer_id
left join employees as e on s.sales_person_id = e.employee_id
where s.sales_id in (select tab.sales_id from tab)
order by s.customer_id;
