/* FULL OUTER JOIN
A common application of this is when joining two tables on a timestamp. Let’s
say you’ve got one table containing the number of item 1 sold each day, and
another containing the number of item 2 sold. If a certain date, like January 1, 2018,
exists in the left table but not the right, while another date, like January 2, 2018,
exists in the right table but not the left:

A left join would drop the row with January 2, 2018 from the result set

A right join would drop January 1, 2018 from the result set

The only way to make sure both January 1, 2018 and January 2, 2018 make it into
the results is to do a full outer join. A full outer join returns unmatched records
in each table with null values for the columns that came from the opposite table.*/

/* FULL JOIN is commonly used in conjunction with aggregations to understand
the amount of overlap between two tables.*/

e.g.
SELECT column_name(s)
FROM Table_A
FULL OUTER JOIN Table_B ON Table_A.column_name = Table_B.column_name;


Note: If you wanted to return unmatched rows only, which is useful for some cases
of data assessment, you can isolate them by adding the following line to the end
of the query:

WHERE Table_A.column_name IS NULL OR Table_B.column_name IS NULL



/* JOINs with Comparison Operators */
/* (1) Inequality JOINs

 the join clause is evaluated before the where clause -- filtering in the join
 \clause will eliminate rows before they are joined, while filtering in the WHERE clause will leave those rows in and produce some nulls.*/

e.g. What are the web traffic like before the first purchase occurred?

SELECT orders.id
       orders.occurred_at AS order_date
       events.*
  FROM orders orders
  LEFT JOIN web_events events
  ON  events.account_id = orders.account_id
 AND  events.occurred_at < orders.occurred_at
WHERE DATE_TRUNC ('month', orders.occurred_at) =
   (SELECT DATE_TRUNC('month'),MIN(order.occurred_at)) FROM orders)
ORDER BY orders.account_id, orders.occurred_at

e.g.1. In the following SQL Explorer, write a query that left joins the accounts
table and the sales_reps tables on each sale rep ID number and joins it using
the < comparison operator on accounts.primary_poc and sales_reps.name, like so:

accounts.primary_poc < sales_reps.name

The query results should be a table with three columns: the account name (e.g.
Johnson Controls), the primary contact name (e.g. Cammy Sosnowski), and the
sales representative name (e.g. Samuel Racine).

SELECT accounts.name as account_name,
       accounts.primary_poc as poc_name,
       sales_reps.name as sales_rep_name
  FROM accounts
  LEFT JOIN sales_reps
    ON accounts.sales_rep_id = sales_reps.id
   AND accounts.primary_poc < sales_reps.name

Note: the operator here for string means that: the primary point of contact full
name comes BEFORE the sales represnetaive name alphabetically

/* SELF JOIN

This comes very commonly in job interviews.

That's right. Self JOIN is optimal when you want to show both parent and child
relationships within a family tree.

For example, we might wanna do this When two events both occurred one after another.*/

e.g. Which accounts made multiple orders within 30 days

STEP 1 Make sure we are JOINing the same accounts (label o1 to compare accounts.id)
STEP 2 We want the orders in o2 to be in 28 days after the records in o1, so we set up
       two conditional statements in the JOIN clauses, both with inequality
STEP 3 Use alias to label the two tables since it can be confusing to only have o (e.g. o1, o2)

SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at
  FROM orders o1
 LEFT JOIN orders o2
   ON o1.account_id = o2.account_id
  AND o2.occurred_at > o1.occurred_at
  AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at

e.g. What about web channels?

SELECT we1.id AS we_id,
       we1.account_id AS we1_account_id,
       we1.occurred_at AS we1_occurred_at,
       we1.channel AS we1_channel,
       we2.id AS we2_id,
       we2.account_id AS we2_account_id,
       we2.occurred_at AS we2_occurred_at,
       we2.channel AS we2_channel
  FROM web_events we1
 LEFT JOIN web_events we2
   ON we1.account_id = we2.account_id
  AND we1.occurred_at > we2.occurred_at
  AND we1.occurred_at <= we2.occurred_at + INTERVAL '1 day'
ORDER BY we1.account_id, we2.occurred_at




/* UNION

The UNION operator is used to combine the result sets of 2 or more SELECT statements.
It removes duplicate rows between the various SELECT statements.

Each SELECT statement within the UNION must have the same number of fields in
the result sets with similar data types.

Typically, the use case for leveraging the UNION command in SQL is when a user
wants to pull together distinct values of specified columns that are spread across
multiple tables. For example, a chef wants to pull together the ingredients and
respective aisle across three separate meals that are maintained in different tables.

Requirements:
- There must be the same number of expressions in both SELECT statements.
- The corresponding expressions must have the same data type in the SELECT statements.

For example: expression1 must be the same data type in both the first and second
SELECT statement.


Expert Tip:

- UNION removes duplicate rows.
- UNION ALL does not remove duplicate rows.

Appending Data via UNION Demonstration:
SQL's two strict rules for appending data:
- Both tables must have the same number of columns.
- Those columns must have the same data types in the same order as the first table.

A common misconception is that column names have to be the same. Column names,
in fact, don't need to be the same to append two tables but you will find that
they typically are. */

e.g.1 (Appending Data) Write a query that uses UNION ALL on two instances (and selecting all
  columns) of the accounts table.
SELECT *
FROM accounts a1

UNION ALL

SELECT *
FROM accounts a2

(This returns 702 results, while "UNION" only returns 351 results)
>> UNION only appends distinct values. More specifically, when you use UNION,
the dataset is appended, and any rows in the appended table that are exactly
identical to rows in the first table are dropped. If you’d like to append all the
values from the second table, use UNION ALL. You’ll likely use UNION ALL far more
often than UNION.

e.g.2 (Pretreating Tables before ding a UNION)  Add a WHERE clause to each of
\the tables that you unioned in the query above, filtering the first table where
name equals Walmart and filtering the second table where name equals Disney.

SELECT *
FROM accounts a1
WHERE name == "Walmart"

UNION ALL

SELECT *
FROM accounts a2
WHERE name = "Disney"



/* Performance Tuning */

Question: what can slow down the query runtime?
- Table Size
- Joins
- Aggregation (e.g. COUNT (DISTINCT, ...) )
- Other users running queries concurrently on the database
- Database software and optimization (e.g. Postgres is optimized differently than Redshift)

/* Performance Tuning: Tips & Practices */
Note:
- LIMIT is not really helping, because it is the last step of the Performance
- The aggregations are the most expensive part of the performance, and they are
  the first steps to be performed and results set will be limited.
- We can also do a subquery first to speed up the overall calculations.
- If we have time series data, limiting to a small time window can also make
  queries run more quickly
- In generally, when working with subquery, limiting the amount of data that will
  be processed first, in order to have maximum reduction of query runtime. This means
  putting limit in the subquery, instead of OUTER query.
- Making our JOIN less complicated can reduce the number of rows evaluated during the JOIN
- We can do a pre-aggreagation to reduce the size of the (sub)table
- We can also add "EXPLAIN" in front of our query to get some appropriate info
  and our query plan. We can do a pre-post to see if our query improves the runtime

/* Performance Tuning III*/



/* */



/* */



/* */



/* */



/* */



/* */



/* */



/* */



/* */



/* */
