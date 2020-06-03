/*  Both subqueries and table expressions are methods for being able to write a
query that creates a table, and then write a query that interacts with this newly
created table. Sometimes the question you are trying to answer doesn't have an
answer when working directly with existing tables in database.

However, if we were able to create new tables from the existing tables, we know
we could query these new tables to answer our question. This is where the queries
of this lesson come to the rescue.

If you can't yet think of a question that might require such a query, don't worry
because you are about to see a whole bunch of them!*/

e.g.
STEP 1 Find the num of events that occur for each day for each channel
STEP 2 Create a subquery that just provides all data from the first query
STEP 3 Find the average number of events for each channel (avg per day)

SELECT channel, AVG(event_count) AS avg_event_count
FROM
(SELECT DATE_TRUNC('day',occurred_at) AS day, channel, count(*) AS event_count
FROM web_events
GROUP BY 1,2
ORDER BY 1) sub
GROUP BY 1
ORDER BY 2 DESC

OR BETTER FORMATTED VERSION

SELECT channel, AVG(events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
             channel, COUNT(*) as events
      FROM web_events
      GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;

/* Subquery Formatting
Additionally, if we have a GROUP BY, ORDER BY, WHERE, HAVING, or any other
statement following our subquery, we would then indent it at the same level as
our outer query.
  */
  SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
                channel, COUNT(*) as events
      FROM web_events
      GROUP BY 1,2
      ORDER BY 3 DESC) sub;

SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
                channel, COUNT(*) as events
      FROM web_events
      GROUP BY 1,2
      ORDER BY 3 DESC) sub
GROUP BY day, channel, events
ORDER BY 2 DESC;

/* Expert Tip - Subquery
Note that you should not include an alias when you write a subquery in a
conditional statement. This is because the subquery is treated as an individual
value (or set of values in the IN case) rather than as a table.

Also, notice the query here compared a single value. If we returned an entire
column IN would need to be used to perform a logical argument. If we are returning
an entire table, then we must use an ALIAS for the table, and perform additional
logic on the entire table. */


/* PRACTICES: WITH (same examples as the subquery ones)*/

e.g.1 Provide the name of the sales_rep in each region with the largest amount
of total_amt_usd sales.

# STEP 1 First, I wanted to find the total_amt_usd totals associated with each
sales rep, and I also wanted the region in which they were located. The query
below provided this information.


SELECT s.name rep_name, r.name region_name, SUM(total_amt_usd) total_amt
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1,2
ORDER BY 3 DESC

# STEP 2 Next, I pulled the max for each region, and then we can use this to
pull those rows in our final result.

SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1;

# STEP 3 Essentially, this is a JOIN of these two tables, where the region and amount match.

SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;

---------------------------------------------------------------------
e.g.2 For the region with the largest (sum) of sales total_amt_usd, how many total
(count) orders were placed?

STEP 1 PULL total_amt_usd for each region
SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name;

STEP 2 Find the region with the max amount from the above table.

SELECT MAX(total_amt)
FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY r.name) sub;

STEP 3 Pull the total orders for the region with this amount

SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);

----------------------------------------------------------------------
e.g.3 How many accounts had more total purchases than the account name which has
bought the most standard_qty paper throughout their lifetime as a customer?

STEP 1 Find the account that ad the most standard_qty paper

SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

STEP 2 Pull all the accounts with more total sales

SELECT a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) sub);

STEP 3 Get the count for how many

SELECT COUNT(*)
FROM (SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)
             ) counter_tab;


----------------------------------------------------------------------
e.g.4 For the customer that spent the most (in total over their lifetime as a
  customer) total_amt_usd, how many web_events did they have for each channel?

STEP 1 Pull the customer with the most spent in lifetime value.

SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 1;


STEP 2 Now, we want to look at the number of events on each channel this company
had, which we can match with just the id.

SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;

----------------------------------------------------------------------
e.g.5 What is the lifetime average amount spent in terms of total_amt_usd for
the top 10 total spending accounts?

STEP 1 First, we just want to find the top 10 accounts in terms of highest total_amt_usd.


  SELECT a.id account_id, a.name account_name, MAX(o.total_amt_usd) total_spent
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1,2
  ORDER BY 3 DESC
  LIMIT 10

STEP 2 Now, we just want the average of these 10 amounts.

SELECT AVG(total_spent)
FROM(
  SELECT a.id account_id, a.name account_name, MAX(o.total_amt_usd) total_spent
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1,2
  ORDER BY 3 DESC
  LIMIT 10) temp;

----------------------------------------------------------------------
e.g.6 What is the lifetime average amount spent in terms of total_amt_usd,
including only the companies that spent more per order, on average, than the average of all orders.

STEP 1 First, we want to pull the average of all accounts in terms of total_amt_usd:

SELECT AVG(o.total_amt_usd) avg_all
FROM orders o

STEP 2 Then, we want to only pull the accounts with more than this average amount.

SELECT o.account_id, AVG(o.total_amt_usd)
FROM orders o
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                               FROM orders o);

STEP 3 Finally, we just want the average of these values.

SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;





/* WITH vs. Subquery

The WITH statement is often called a Common Table Expression or CTE. Though
these expressions serve the exact same purpose as subqueries, they are more
common in practice, as they tend to be cleaner for a future reader to follow the logic.




/* PRACTICES: Subquery */

e.g.
WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day,
                        channel, COUNT(*) as events
          FROM web_events
          GROUP BY 1,2)

SELECT channel, AVG(events) AS average_events
FROM events
GROUP BY channel
ORDER BY 2 DESC;


e.g.1 Provide the name of the sales_rep in each region with the largest amount
of total_amt_usd sales.

WITH t1 AS (
  SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY 1,2
   ORDER BY 3 DESC),
t2 AS (
   SELECT region_name, MAX(total_amt) total_amt
   FROM t1
   GROUP BY 1)
SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;


---------------------------------------------------------------------
e.g.2 For the region with the largest (sum) of sales total_amt_usd, how many total
(count) orders were placed?

WITH t1 AS (
   SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name),
t2 AS (
   SELECT MAX(total_amt)
   FROM t1)
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);

----------------------------------------------------------------------
e.g.3 How many accounts had more total purchases than the account name which has
bought the most standard_qty paper throughout their lifetime as a customer?

WITH t1 AS (
  SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1),
t2 AS (
  SELECT a.name
  FROM orders o
  JOIN accounts a
  ON a.id = o.account_id
  GROUP BY 1
  HAVING SUM(o.total) > (SELECT total FROM t1))
SELECT COUNT(*)
FROM t2;


----------------------------------------------------------------------
e.g.4 For the customer that spent the most (in total over their lifetime as a
  customer) total_amt_usd, how many web_events did they have for each channel?

STEP 1 Pull the customer with the most spent in lifetime value.
STEP 2 Now, we want to look at the number of events on each channel this company
had, which we can match with just the id.

WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

----------------------------------------------------------------------
e.g.5 What is the lifetime average amount spent in terms of total_amt_usd for
the top 10 total spending accounts?

STEP 1 First, we just want to find the top 10 accounts in terms of highest total_amt_usd.

STEP 2 Now, we just want the average of these 10 amounts.

WITH top_accounts AS(
  SELECT a.id account_id, a.name account_name, MAX(o.total_amt_usd) total_spent
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1,2
  ORDER BY 3 DESC
  LIMIT 10)
SELECT AVG(total_spent)
FROM top_accounts ;

----------------------------------------------------------------------
e.g.6 What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.

STEP 1 First, we want to pull the average of all accounts in terms of total_amt_usd:
STEP 2 Then, we want to only pull the accounts with more than this average amount.
STEP 3 Finally, we just want the average of these values.

WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;


/*  */


/*  */


/*  */



/*  */


/*  */
