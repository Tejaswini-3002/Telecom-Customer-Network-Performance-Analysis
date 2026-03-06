use Ptelecom

select * from Customer
select * from networkIssues
select * from networkUsage
select * from billings

--Create relational tables and primary/foreign keys
--primary keys
  alter table Customer
  add constraint pk_customers
  primary key(customer_id)

  alter table networkUsage
  add constraint pk_networkUsage 
  primary key(Usage_id)

  alter table networkIssues
  add constraint pk_networkIssues
  primary key(issue_id)

  ALTER TABLE billings
  ADD CONSTRAINT pk_billings
  PRIMARY KEY(bill_id)
  
--foreign keys
  alter table networkUsage 
  add constraint fk_customer_usage
  foreign key(customer_id) references Customer(customer_id)
  
  alter table networkIssues
  add constraint fk_customer_issues
  foreign key(customer_id) references Customer(customer_id)

  alter table billings
  add constraint fk_customer_billings
  foreign key(customer_id) references Customer(customer_id)

--Write joins across all datasets
select c.customer_id,c.age,i.issue_id,u.call_minutes,u.data_used_gb,b.bill_id,b.bill_amount
from customer c
left join networkUsage u on c.customer_id=u.customer_id
left join networkIssues i on c.customer_id=i.customer_id
left join billings b on c.customer_id=b.customer_id

--Calculate complaint rate per customer
select c.customer_id,count(i.issue_id) as total_complaints 
from customer c
left join networkIssues i
on c.customer_id=i.issue_id
group by c.customer_id

--Use window functions for monthly trend analysis
SELECT
    customer_id,
    YEAR(usage_date) AS year,
    MONTH(usage_date) AS month,
    SUM(data_used_gb) AS monthly_usage,
    SUM(SUM(data_used_gb)) OVER (
        PARTITION BY customer_id
        ORDER BY YEAR(usage_date), MONTH(usage_date)
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_usage
FROM networkUsage
GROUP BY
    customer_id,
    YEAR(usage_date),
    MONTH(usage_date)
ORDER BY customer_id, year, month
