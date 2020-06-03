
/* OVER and PARTITION BY

https://blog.sqlauthority.com/2015/11/04/sql-server-what-is-the-over-clause-notes-from-the-field-101/

These are key to window functions. Not every window
function uses PARTITION BY; we can also use ORDER BY or no statement at all
depending on the query we want to run. You will practice using these clauses in
the upcoming quizzes. If you want more details right now, this resource from
Pinal Dave is helpful:
https://blog.sqlauthority.com/2015/11/04/sql-server-what-is-the-over-clause-notes-from-the-field-101/ */

e.g.1 Running total of standard_qty, with date runcation of by month

SELECT standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       SUM(standard_qty) OVER (PARTITION BY DATE_TRUNC('month', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders

e.g 2. Create a running total of standard_amt_usd (in the orders table) over order
time with no date truncation. Your final table should have two columns: one with
the amount being added for each new row, and a second with the running total.

SELECT standard_amt_usd,
       SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
FROM orders

e.g.3  Still create a running total of standard_amt_usd (in the orders table)
over order time, but this time, date truncate occurred_at by year and partition
by that same year-truncated occurred_at variable. Your final table should have
three columns: One with the amount being added for each row, one for the truncated
date, and a final column with the running total within each year.

SELECT standard_amt_usd,
       DATE_TRUNC('year', occurred_at) AS yr,
       SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders


/* ROW_NUMBER() & RANK()
They just count, and they don't aggregate

ROW_NUMBER() displays the number of a given row within the window we define according
to the ORDER BY par of the window statement

RANK() will give the same number to rows having the same values, and skip those number (e.g. 1,2,2,2,2,6)
DENSE_RANK() will not skip those numbers (e.g.1,2,3,4,5,6)*/

e.g.
SELECT id,
       account_id,
       occurred_at,
       RANK() OVER (PARTITION BY account_id ORDER BY occurred_at) AS row_num
FROM orders

e.g.1 Select the id, account_id, and total variable from the orders table, then
create a column called total_rank that ranks this total amount of paper ordered
(from highest to lowest) for each account using a partition. Your final table
should have these four columns.

SELECT id,
	   account_id,
       total,
       RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders



/* AGGREGATE with Window function with or without ORDER BY */

e.g.
SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders

VS. (Now remove ORDER BY DATE_TRUNC('month',occurred_at) in each line of the
query that contains it in the SQL Explorer below.)

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id) AS max_std_qty
FROM orders

Results: Dense_rank is constant at 1 for all rows for all account_id values.
THIS IS NOT GOOD

>>The ORDER BY clause is one of two clauses integral to window functions. The
ORDER and PARTITION define what is referred to as the “window”—the ordered subset
of data over which calculations are made. Removing ORDER BY just leaves an
unordered partition; in our query's case, each column's value is simply an
aggregation (e.g., sum, count, average, minimum, or maximum) of all the standard_qty
values in its respective account_id.

>>The easiest way to think about this - leaving the ORDER BY out is equivalent
to "ordering" in a way that all rows in the partition are "equal" to each other.
Indeed, you can get the same effect by explicitly adding the ORDER BY clause like
this: ORDER BY 0 (or "order by" any constant expression), or even, more emphatically,
ORDER BY NULL.


/* Alias for Multiple Windows

For readability purpose, we can create alias for windows.

part 1: OVER + alias

part 2: WINDOW alias AS (PARTITION BY ... ORDER BY ...)
*/

e.g.
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))



/* LAG & LEAD */

LAG: return the value from a previous row to the current row in the table

e.g. LAG
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag
FROM   (
        SELECT   account_id,
                 SUM(standard_qty) AS standard_sum
        FROM     demo.orders
        GROUP BY 1
       ) sub

e.g. lag_difference
To compare the values between the rows, we need to use both columns
(standard_sum and lag). We add a new column named lag_difference, which subtracts
the lag value from the value in standard_sum for each row in the table:

SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference
FROM (
       SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders
       GROUP BY 1
      ) sub


e.g. LEAD

SELECT account_id,
       standard_sum,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders
       GROUP BY 1
     ) sub

/* Expert Tip: When to use LAG & LEAD functions:
You can use LAG and LEAD functions whenever you are trying to compare the values
in adjacent rows or rows that are offset by a certain number. */

Example 1
You have a sales dataset with the following data and need to compare how the market
segments fare against each other on profits earned.

Market Segment	| Profits earned by each market segment
A	$550
B	$500
C	$670
D	$730
E	$982

Example 2
You have an inventory dataset with the following data and need to compare the number
of days elapsed between each subsequent order placed for Item A.

Inventory	| Order_id | Dates when orders were placed
Item A	001	11/2/2017
Item A	002	11/5/2017
Item A	003	11/8/2017
Item A	004	11/15/2017
Item A	005	11/28/2017

e.g. magine you are an analyst at Parch & Posey and you want to determine how
the current order total revenue ("total" meaning from sales of all types of paper)
compares to the next order total revenue.

SELECT occurred_at,
      total_amt_usd,
      LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
      LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
      SUM(total_amt_usd) AS total_amt_usd
 FROM orders
GROUP BY 1
) sub


/* NTILE - percentile funciton

You can use window functions to identify what percentile (or quartile, or any
other subdivision) a given row falls into. The syntax is NTILE(*# of buckets*).
In this case, ORDER BY determines which column to use to determine the quartiles
(or whatever number of ‘tiles you specify).

Expert Tip
In cases with relatively few rows in a window, the NTILE function doesn’t
calculate exactly as you might expect. For example, If you only had two records
and you were measuring percentiles, you’d expect one record to define the 1st
percentile, and the other record to define the 100th percentile. Using the NTILE
function, what you’d actually see is one record in the 1st percentile, and one in the 2nd percentile.
 */

 e.g.
 SELECT id,
        account_id,
        occurred_at,
        standard_qty,
        NTILE(4) OVER (ORDER BY standard_qty) AS quartile,
        NTILE(5) OVER (ORDER BY standard_qty) AS quintile,
        NTILE(100) OVER (ORDER BY standard_qty) AS percentile,
  FROM orders,
ORDER BY standard_qty DESC;

Imagine you are an analyst at Parch & Posey and you want to determine the largest
orders (in terms of quantity) a specific customer has made to encourage them to
order more similarly sized large orders. You only want to consider the NTILE for
that customer account_id.

e.g.1 Use the NTILE functionality to divide the accounts into 4 levels in terms
of the amount of standard_qty for their orders. Your resulting table should have
the account_id, the occurred_at time for each order, the total amount of standard_qty
paper purchased, and one of four levels in a standard_quartile column.

SELECT
       account_id,
       occurred_at,
       standard_qty,
       NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
  FROM orders
 ORDER BY account_id DESC


e.g.2 Use the NTILE functionality to divide the accounts into two levels in terms
of the amount of gloss_qty for their orders. Your resulting table should have the
account_id, the occurred_at time for each order, the total amount of gloss_qty paper
purchased, and one of two levels in a gloss_half column.

SELECT
       account_id,
       occurred_at,
       gloss_qty,
       NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
  FROM orders
 ORDER BY account_id DESC

e.g.3 Use the NTILE functionality to divide the orders for each account into 100
levels in terms of the amount of total_amt_usd for their orders. Your resulting
table should have the account_id, the occurred_at time for each order, the total
amount of total_amt_usd paper purchased, and one of 100 levels in a total_percentile column.

SELECT
       account_id,
       occurred_at,
       total_amt_usd,
       NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
  FROM orders
 ORDER BY account_id DESC

/*  */



/*  */



/*  */



/*  */



/*  */



/*  */



/*  */



/*  */



/*  */



/*  */



/*  */



/*  */



/*  */



/*  */
