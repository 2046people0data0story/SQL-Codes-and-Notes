
/* NULLs

Notice that NULLs are different than a zero - they are cells where data does not exist.

When identifying NULLs in a WHERE clause, we write IS NULL or IS NOT NULL.
We don't use =, because NULL isn't considered a value in SQL.
Rather, it is a property of the data.

NULLs - Expert Tip
There are two common ways in which you are likely to encounter NULLs:

NULLs frequently occur when performing a LEFT or RIGHT JOIN.
You saw in the last lesson - when some rows in the left table of a left join
are not matched with rows in the right table, those rows will contain some
NULL values in the result set.

NULLs can also occur from simply missing data in our database. */

/* COUNT */

SELECT COUNT(accounts.id)
FROM accounts;

/* SUM
Unlike COUNT, you can only use SUM on numeric columns. However, SUM will ignore
NULL values, as do the other aggregation functions you will see in the upcoming lessons.

An important thing to remember: aggregators only aggregate vertically - the values of a column.
If you want to perform a calculation across rows, you would do this with simple arithmetic.*/

SELECT SUM(poster_qty) poster, SUM(standard_qty)
FROM orders;

SELECT standard_amt_usd + gloss_amt_usd AS total_standard_gloss
FROM orders;

SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;

/* MIN & MAX & AVG & MEDIAN

Notice that MIN and MAX are aggregators that again ignore NULL values.

Expert Tip - MIN & MAX
Functionally, MIN and MAX are similar to COUNT in that they can be used on
non-numerical columns. Depending on the column type, MIN will return the lowest
number, earliest date, or non-numerical value as early in the alphabet as possible.
As you might suspect, MAX does the opposite—it returns the highest number, the
latest date, or the non-numerical value closest alphabetically to “Z.”

Similar to other software AVG returns the mean of the data - that is the sum
of all of the values in the column divided by the number of values in a column.
This aggregate function again ignores the NULL values in both the numerator and the denominator.

If you want to count NULLs as zero, you will need to use SUM and COUNT. However,
this is probably not a good idea if the NULL values truly just represent unknown values for a cell.

Expert Tip - MEDIAN
One quick note that a median might be a more appropriate measure of center for
this data, but finding the median happens to be a pretty difficult thing to get
using SQL alone — so difficult that finding a median is occasionally asked as an interview question.*/

SELECT MIN(occurred_at)
FROM orders;

SELECT occurred_at
FROM orders
ORDER BY occurred_at
LIMIT 1;

SELECT MAX(occurred_at)
FROM web_events;

SELECT occurred_at
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

e.g.Find the mean (AVERAGE) amount spent per order on each paper type, as well
as the mean amount of each paper type purchased per order. Your final answer
should have 6 values - one for each paper type for the average number of sales,
as well as the average amount.

SELECT AVG(standard_qty) mean_standard, AVG(gloss_qty) mean_gloss,
           AVG(poster_qty) mean_poster, AVG(standard_amt_usd) mean_standard_usd,
           AVG(gloss_amt_usd) mean_gloss_usd, AVG(poster_amt_usd) mean_poster_usd
FROM orders;

e.g.What is the MEDIAN total_usd spent on all orders? Note, this is more advanced
than the topics we have covered thus far to build a general solution, but we can
hard code a solution in the following way.

SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;

NOTES: Since there are 6912 orders - we want the average of the 3457 and 3456 order
amounts when ordered. This is the average of 2483.16 and 2482.55. This gives the
median of 2482.855. This obviously isn't an ideal way to compute. If we obtain
new orders, we would have to change the limit. SQL didn't even calculate the
median for us. The above used a SUBQUERY, but you could use any method to find
the two necessary values, and then you just need the average of them.

/* GROUP BY
GROUP BY can be used to aggregate data within subsets of the data. For example,
grouping for different accounts, different regions, or different sales representatives.

Any column in the SELECT statement that is not within an aggregator must be in
the GROUP BY clause.

The GROUP BY always goes between WHERE and ORDER BY.

ORDER BY works like SORT in spreadsheet software.


SQL evaluates the aggregations before the LIMIT clause.
If you don’t group by any columns, you’ll get a 1-row result—no problem there.
If you group by a column with enough unique values that it exceeds the LIMIT
number, the aggregates will be calculated, and then some rows will simply be
omitted from the results.*/

e.g.1 Which account (by name) placed the earliest order? Your solution should
have the account name and the date of the order.

SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY o.occurred_at
LIMIT 1;

e.g.2Find the total sales in usd for each account. You should include two columns
- the total sales for each company orders in usd and the company name.

SELECT a.name, SUM(o.total_amt_usd) AS total_sales
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name;

e.g.3 Via what channel did the most recent (latest) web_event occur, which account
was associated with this web_event? Your query should return only three values -
the date, channel, and account name.

SELECT w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
ORDER BY w.occurred_at DESC
LIMIT 1;

e.g.4 Find the total number of times each type of channel from the web_events was
used. Your final table should have two columns - the channel and the number of
times the channel was used.

SELECT w.channel, COUNT(w.channel)
FROM web_events w
GROUP BY w.channel;

e.g.5 Who was the primary contact associated with the earliest web_event?

SELECT a.primary_poc, MIN(w.occurred_at)
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
GROUP BY a.primary_poc
ORDER BY MIN(w.occurred_at)
LIMIT 1;

OR

SELECT a.primary_poc
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;

e.g.6 What was the smallest order placed by each account in terms of total usd.
Provide only two columns - the account name and the total usd. Order from smallest
dollar amounts to largest.

SELECT a.name, MIN(total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;

e.g.7 Find the number of sales reps in each region. Your final table should have
two columns - the region and the number of sales_reps. Order from fewest reps to most reps.

SELECT r.name, COUNT(s.region_id) num_reps
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY num_reps;


/* GROUP BY II

You can GROUP BY multiple columns at once, as we showed here. This is often
useful to aggregate across a number of different segments.

The order of columns listed in the ORDER BY clause does make a difference.
You are ordering the columns from left to right.

The order of column names in your GROUP BY clause doesn’t matter—the results
will be the same regardless. If we run the same query and reverse the order in
the GROUP BY clause, you can see we get the same results.

As with ORDER BY, you can substitute numbers for column names in the GROUP BY clause.
It’s generally recommended to do this only when you’re grouping many columns, or
if something else is causing the text in the GROUP BY clause to be excessively long. */

e.g.1 For each account, determine the average amount of each type of paper they
purchased across their orders. Your result should have four columns - one for
the account name and one for the average quantity purchased for each of the paper
types for each account.

SELECT a.name AS account, AVG(o.standard_qty) standard_avg, AVG(o.gloss_qty) gloss_avg, AVG(o.poster_qty) poster_avg
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name;


e.g. 2 For each account, determine the average amount spent per order on each paper
type. Your result should have four columns - one for the account name and one for
the average amount spent on each paper type.

SELECT a.name AS account, AVG(o.standard_amt_usd) standard_avg_amt, AVG(o.gloss_amt_usd) gloss_avg_amt, AVG(o.poster_amt_usd) poster_avg_amt
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name;

e.g.3 Determine the number of times a particular channel was used in the web_events table
for each sales rep. Your final table should have three columns - the name of the
sales rep, the channel, and the number of occurrences. Order your table with the
highest number of occurrences first.

SELECT s.name sale_rep_name, w.channel channel_name, COUNT(w.channel) num_occur,
FROM accounts a
JOIN sales_reps
ON s.id = a.sales_rep_id
JOIN web_events w
ON a.id = w.account_id
GROUP BY sale_rep_name, channel_name
ORDER BY COUNT num_occur DESC;

SELECT s.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name, w.channel
ORDER BY num_events DESC;

e.g.4 Determine the number of times a particular channel was used in the web_events
table for each region. Your final table should have three columns - the region name,
the channel, and the number of occurrences. Order your table with the highest number
of occurrences first.

SELECT r.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY num_events DESC;

/* DISTINCT  */
While the above practices may seem confusing (e.g.COUNT(*) when we are using GROUP BY, we have DISTINCT

DISTINCT is always used in SELECT statements, and it provides the unique rows
for all columns written in the SELECT statement. Therefore, you only use DISTINCT
once in any particular SELECT statement.

SELECT DISTINCT column1, column2, column3
FROM table1;

But NOT write like
SELECT DISTINCT column1, DISTINCT column2, DISTINCT column3
FROM table1;

You can think of DISTINCT the same way you might think of the statement "unique".

e.g.1 Use DISTINCT to test if there are any accounts associated with more than one region.
The below two queries have the same number of resulting rows (351), so we know that every
account is associated with only one region. If each account was associated with more than
one region, the first query should have returned more rows than the second query.

SELECT DISTINCT r.name region, a.name account
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id;

SELECT DISTINCT id, name
FROM accounts;

e.g.2 Have any sales reps worked on more than one account?
Actually all of the sales reps have worked on more than one account. The fewest
number of accounts any sales rep works on is 3. There are 50 sales reps, and they
all have more than one account. Using DISTINCT in the second query assures that
all of the sales reps are accounted for in the first query.

SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts;

SELECT DISTINCT id, name
FROM sales_reps;

/* HAVING
Expert Tip: HAVING is the “clean” way to filter a query that has been aggregated, but this
is also commonly done using a subquery. Essentially, any time you want to perform
a WHERE on an element of your query that was created by an aggregate, you need to
use HAVING instead. */

e.g.1 How many of the sales reps have more than 5 accounts that they manage?

SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;

e.g.2 How many accounts have more than 20 orders?

SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20
ORDER BY num_orders;


e.g.3 Which account has the most orders?
SELECT a.name account, COUNT(o.id) num_order
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY account
ORDER BY num_order DESC;

OR

SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY num_orders DESC
LIMIT 1;

e.g.4 Which accounts spent more than 30,000 usd total across all orders?

SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent;

e.g.5 Which accounts spent less than 1,000 usd total across all orders?

SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent;

e.g.6 Which account has spent the most with us?

SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent DESC
LIMIT 1;

e.g.7 Which account has spent the least with us?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent
LIMIT 1;

e.g.8 Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6 AND w.channel = 'facebook'
ORDER BY use_of_channel;

e.g.9 Which account used facebook most as a channel?

SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 1;

e.g.10 Which channel was most frequently used by most accounts?

SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;

/* DATE functions

The first function you are introduced to in working with dates is DATE_TRUNC.

DATE_TRUNC allows you to truncate your date to a particular part of your
date-time column. Common trunctions are day, month, and year.

DATE_PART can be useful for pulling a specific portion of a date, but notice
pulling month or day of the week ('dow') means that you are no longer keeping the
years in order. Rather you are grouping for certain components regardless of which
year they belonged in. (check this post: https://blog.modeanalytics.com/date-trunc-sql-timestamp-function-count-on/)

For additional functions you can use with dates, check out the documentation
here (https://www.postgresql.org/docs/9.1/functions-datetime.html), but the DATE_TRUNC and DATE_PART functions definitely give you a great start!

You can reference the columns in your select statement in GROUP BY and ORDER BY
clauses with numbers that follow the order they appear in the select statement.

For example*/

SELECT standard_qty, COUNT(*)
FROM orders
GROUP BY 1 (this 1 refers to standard_qty since it is the first of the columns
included in the select statement)
ORDER BY 1 (this 1 refers to standard_qty since it is the first of the columns
included in the select statement)

e.g.1 Find the sales in terms of total dollars for all orders in each year,
ordered from greatest to least. Do you notice any trends in the yearly sales totals?

SELECT SUM(total_amt_usd), DATE_PART('year', occurred_at) AS year
FROM orders
GROUP BY year
ORDER BY SUM(total_amt_usd) DESC;

e.g.2 Which month did Parch & Posey have the greatest sales in terms of total
dollars? Are all months evenly represented by the dataset?

SELECT SUM(total_amt_usd) AS total_spent, DATE_PART('month', occurred_at) AS month
FROM orders
GROUP BY month
ORDER BY SUM(total_amt_usd) DESC;
(December)


e.g.3 Which year did Parch & Posey have the greatest sales in terms of total
number of orders? Are all years evenly represented by the dataset?

SELECT DATE_PART('year', occurred_at) ord_year,  COUNT(*) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

e.g.4 Which month did Parch & Posey have the greatest sales in terms of total
number of orders? Are all months evenly represented by the dataset?

SELECT DATE_PART('month', occurred_at) ord_month, COUNT(*) total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;


e.g.5 In which month of which year did Walmart spend the most on gloss paper in
terms of dollars?

SELECT SUM(o.gloss_amt_usd) num_order, DATE_PART('month', o.occurred_at) AS month, DATE_PART ('year', o.occurred_at) yr
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY month, yr
ORDER BY SUM(gloss_qty) DESC;

OR

SELECT DATE_TRUNC('month', o.occurred_at) ord_date, SUM(o.gloss_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;



/* CASE

- The CASE statement always goes in the SELECT clause.

- CASE must include the following components: WHEN, THEN, and END. ELSE is an
optional component to catch cases that didn’t meet any of the other previous CASE conditions.

- You can make any conditional statement using any conditional operator (like
WHERE) between WHEN and THEN. This includes stringing together multiple conditional
statements using AND and OR.

- You can include multiple WHEN statements, as well as an ELSE statement again,
to deal with any unaddressed conditions.  */

e.g. Create a column that divides the standard_amt_usd by the standard_qty to find
the unit price for standard paper for each order. Limit the results to the first 10
orders, and include the id and account_id fields. NOTE - you will be thrown an error
with the correct solution to this question. This is for a division by zero. You will
learn how to get a solution without an error to this query when you learn about CASE
statements in a later section.

SELECT id, account_id, standard_amt_usd/standard_qty AS unit_price
FROM orders
LIMIT 10;

USE CASE TO GET AROUND THIS error

SELECT account_id, CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
                        ELSE standard_amt_usd/standard_qty END AS unit_price
FROM orders
LIMIT 10;

e.g.1 Write a query to display for each order, the account ID, total amount of
the order, and the level of the order - ‘Large’ or ’Small’ - depending on if the
order is $3000 or more, or smaller than $3000.

SELECT o.id order_id,
       a.id account_id,
       o.total order_amount,
       CASE WHEN o.total_amt_usd >= 3000 THEN 'Large' ELSE 'small' END AS order_level
 FROM accounts a
 JOIN orders o
 ON a.id = o.account_id
 LIMIT 10

 OR

SELECT account_id, total_amt_usd,
CASE WHEN total_amt_usd > 3000 THEN 'Large'
ELSE 'Small' END AS order_level
FROM orders;


e.g.2 Write a query to display the number of orders in each of three categories,
based on the total number of items in each order. The three categories are:
'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.

SELECT CASE WHEN total >= 2000 THEN 'At Least 2000'
   WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
   ELSE 'Less than 1000' END AS order_category,
COUNT(*) AS order_count
FROM orders
GROUP BY 1;

e.g.3 We would like to understand 3 different levels of customers based on the
amount associated with their purchases. The top level includes anyone with a
Lifetime Value (total sales of all orders) greater than 200,000 usd. The second
level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000
usd. Provide a table that includes the level associated with each account.
You should provide the account name, the total sales of all orders for the customer,
and the level. Order with the top spending customers listed first.

SELECT a.name account, SUM(o.total_amt_usd) total_spent,
	   CASE WHEN SUM(o.total_amt_usd) >= 200000 THEN '1st'
       WHEN SUM(o.total_amt_usd) > 100000 AND SUM(o.total_amt_usd) <= 200000 THEN '2nd'
       WHEN SUM(o.total_amt_usd) <100000 THEN '3rd' END AS account_level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name
ORDER BY 2 DESC;


e.g.4 We would now like to perform a similar calculation to the first, but we
want to obtain the total amount spent by customers only in 2016 and 2017. Keep
the same levels as in the previous question. Order with the top spending customers
listed first.

SELECT a.name, SUM(total_amt_usd) total_spent,
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
     WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
     ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at > '2015-12-31'
GROUP BY 1
ORDER BY 2 DESC;


e.g.5 We would like to identify top performing sales reps, which are sales reps
associated with more than 200 orders. Create a table with the sales rep name,
the total number of orders, and a column with top or not depending on if they have
more than 200 orders. Place the top sales people first in your final table.

SELECT s.name,
	   COUNT(o.id) num_order,
       CASE WHEN COUNT(o.id) > 200 THEN 'yes' ELSE 'no' END AS is_top_performer
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN orders o
ON a.id = o.account_id
GROUP BY s.name
ORDER BY num_order DESC;

e.g.6 The previous didnt account for the middle, nor the dollar amount associated
with the sales. Management decides they want to see these characteristics represented
as well. We would like to identify top performing sales reps, which are sales reps
associated with more than 200 orders or more than 750000 in total sales. The middle
group has any rep with more than 150 orders or 500000 in sales. Create a table with
the sales rep name, the total number of orders, total sales across all orders, and
a column with top, middle, or low depending on this criteria. Place the top sales
people based on dollar amount of sales first in your final table. You might see a
few upset sales people by this criteria!

SELECT s.name,
	   COUNT(o.id) num_order,
       SUM(o.total_amt_usd) sales_usd,
       CASE WHEN COUNT(o.id) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
       WHEN (COUNT(o.id) <= 200 AND COUNT(o.id) > 150 )OR (SUM(o.total_amt_usd) > 500000 AND SUM(o.total_amt_usd) > 500000) THEN 'middle'
       WHEN COUNT(o.id) <=150 OR SUM(o.total_amt_usd) <= 500000 THEN 'low'
       ELSE 'NULL' END AS is_top_performer
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN orders o
ON a.id = o.account_id
GROUP BY s.name
ORDER BY sales_usd DESC, num_order DESC;

OR

SELECT s.name, COUNT(*), SUM(o.total_amt_usd) total_spent,
     CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
     WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
     ELSE 'low' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC;

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
