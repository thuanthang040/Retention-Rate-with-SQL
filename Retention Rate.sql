-- RETENTION RATE

-- First transaction time of each customer
with 
first_month_order as (
					select customer_id,
						   format(min(sales_date),'yyyy-MM-dd') as first_date,
						   format(min(sales_date), 'yyyy-MM') as first_month
					from Transactions
					group by customer_id
					),
-- New customers by month
new_customer_by_month as (
						select first_month,
							   count(customer_id) as qty_new_customer
						from first_month_order
						group by first_month
						 ),
-- Month_diff after first transcation time of each customer
month_diff as (
				select t.customer_id, 
					   format(t.sales_date,'yyyy-MM-dd') as sales_date,
					   f.first_date,
					   f.first_month,
					   datediff(MONTH, f.first_date, format(t.sales_date,'yyyy-MM-dd')) month_diff
				from Transactions as t
				left join first_month_order as f on t.customer_id = f.customer_id
			)
-- Calculate retention rate
select m.first_month, 
	   m.month_diff,
	   concat('After ', m.month_diff, ' months') month_diff_label,
	   n.qty_new_customer,
	   count(distinct m.customer_id) qty_comeback_customer,
	   1.0*count(distinct m.customer_id)/n.qty_new_customer as retention_rate
from month_diff m
left join new_customer_by_month n on m.first_month = n.first_month	
group by m.first_month, m.month_diff, n.qty_new_customer
