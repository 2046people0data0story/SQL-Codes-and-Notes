/* Database Normalization
When creating a database, it is really important to think about how data will
be stored. This is known as normalization, and it is a huge part of most SQL
classes. If you are in charge of setting up a new database, it is important to
have a thorough understanding of database normalization.

There are essentially three ideas that are aimed at database normalization:

Are the tables storing logical groupings of the data?
Can I make changes in a single location, rather than in many tables for the same information?
Can I access and manipulate data quickly and efficiently?
*/



/*JOIN ON */

e.g.Try pulling standard_qty, gloss_qty, and poster_qty from the orders table,
and the website and the primary_poc from the accounts table.
SELECT orders.standard_qty, orders.gloss_qty,
       orders.poster_qty,  accounts.website,
       accounts.primary_poc
FROM orders
JOIN accounts
ON orders.account_id = accounts.id


/* PK - primary key
You will notice some of the columns in the tables have PK or FK next to the
column name, while other columns don't have a label at all.

If you look a little closer, you might notice that the PK is associated with
the first column in every table. The PK here stands for primary key. A primary
key exists in every table, and it is a column that has a unique value for every row.*/


/* FK - Foreign key
A foreign key is a column in one table that is a primary key in a different table.
We can see in the Parch & Posey ERD that the foreign keys are:

region_id
account_id
sales_rep_id

Each of these is linked to the primary key of another table.*/

/* PK & FK
Primary - Foreign Key Link
In the above image you can see that:

The region_id is the foreign key.
The region_id is linked to id - this is the primary-foreign key link that connects these two tables.
The crow's foot shows that the FK can actually appear in many rows in the sales_reps table.
While the single line is telling us that the PK shows that id appears only once per row in this table.

Notice our SQL query has the two tables we would like to join - one in the FROM
and the other in the JOIN. Then in the ON, we will ALWAYs have the PK equal to the FK:

The way we join any two tables is in this way: linking the PK and FK (generally in an ON statement).

Below example shows that this logic works even for joining MORE THAN ONE table*/

SELECT *
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN orders
ON accounts.id = orders.account_id

/*alias
When we JOIN tables together, it is nice to give each table an alias.
Frequently an alias is just the first letter of the table name. */

e.g. past example
FROM tablename AS t1
JOIN tablename2 AS t2

e.g. now we can just use a space
FROM tablename t1
JOIN tablename2 t2

e.g. While aliasing tables is the most common use case. It can also be used to
alias the columns selected to have the resulting table reflect a more readable name.

Select t1.column1 aliasname, t2.column2 aliasname2
FROM tablename AS t1
JOIN tablename2 AS t2


/*JOIN Practice I*/
e.g.1 Provide a table for all web_events associated with account name of Walmart.
There should be three columns. Be sure to include the primary_poc, time of the event,
and the channel for each event. Additionally, you might choose to add a fourth column
to assure only Walmart events were chosen.

SELECT a.primary_poc, w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE a.name = 'Walmart';


e.g.2 Provide a table that provides the region for each sales_rep along with
their associated accounts. Your final table should include three columns: the
region name, the sales rep name, and the account name. Sort the accounts
alphabetically (A-Z) according to account name.

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY a.name;

e.g.3 /HARD/ Provide the name for each region for every order, as well as the
account name and the unit price they paid (total_amt_usd/total) for the order.
Your final table should have 3 columns: region name, account name, and unit price.
A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.

SELECT r.name region, a.name account,
       o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id;

/*LEFT JOIN / LEFT OUTER JOIN */

/*RIGHT JOIN / RIGHT OUTER JOIN */

/*Filtering
A simple rule to remember this is that, when the database executes this query,
it executes the join and everything in the ON clause first. Think of this as
building the new result set. That result set is then filtered using the WHERE clause.

The fact that this example is a left join is important. Because inner joins only
return the rows for which the two tables match, moving this filter to the ON
clause of an inner join will produce the same result as keeping it in the WHERE clause.*/


/*CHAPTER PRACTICES:

If you have two or more columns in your SELECT that have the same name after the
table name such as accounts.name and sales_reps.name you will need to alias them.
Otherwise it will only show one of the columns. You can alias them like
accounts.name AS AcountName, sales_rep.name AS SalesRepName*/


/*01 Provide a table that provides the region for each sales_rep along with
their associated accounts. This time only for the Midwest region. Your final
table should include three columns: the region name, the sales rep name, and
the account name. Sort the accounts alphabetically (A-Z) according to account name.*/

SELECT r.name AS Region, s.name AS SalesRepName, a.name AS AccountName
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
WHERE r.name = 'Midwest'
ORDER BY a.name;


/*02 Provide a table that provides the region for each sales_rep along with
their associated accounts. This time only for accounts where the sales rep has
a first name starting with S and in the Midwest region. Your final table should
include three columns: the region name, the sales rep name, and the account name.
Sort the accounts alphabetically (A-Z) according to account name. */
SELECT r.name AS Region, s.name AS SalesRepName, a.name AS AccountName
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
WHERE s.name LIKE 'S%' AND r.name = 'Midwest'
ORDER BY a.name;

/*03 Provide a table that provides the region for each sales_rep along with their
associated accounts. This time only for accounts where the sales rep has a last
name starting with K and in the Midwest region. Your final table should include
three columns: the region name, the sales rep name, and the account name. Sort
the accounts alphabetically (A-Z) according to account name.*/
SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE '% K%'
ORDER BY a.name;

/*04 Provide the name for each region for every order, as well as the account
 name and the unit price they paid (total_amt_usd/total) for the order. However,
  you should only provide the results if the standard order quantity exceeds 100.
   Your final table should have 3 columns: region name, account name, and unit price.
   In order to avoid a division by zero error, adding .01 to the denominator here
is helpful total_amt_usd/(total+0.01).

Tip: when the tables are far away, we might need to JOIN multiple times before the success*/

SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100;

/*05 Provide the name for each region for every order, as well as the account
name and the unit price they paid (total_amt_usd/total) for the order. However,
you should only provide the results if the standard order quantity exceeds 100
and the poster order quantity exceeds 50. Your final table should have 3 columns:
region name, account name, and unit price. Sort for the smallest unit price first.
In order to avoid a division by zero error, adding .01 to the denominator here is
helpful (total_amt_usd/(total+0.01).*/

SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price;


/*06 Provide the name for each region for every order, as well as the account
name and the unit price they paid (total_amt_usd/total) for the order. However,
you should only provide the results if the standard order quantity exceeds 100
and the poster order quantity exceeds 50. Your final table should have 3 columns:
region name, account name, and unit price. Sort for the largest unit price first.
 In order to avoid a division by zero error, adding .01 to the denominator here
 is helpful (total_amt_usd/(total+0.01).*/

 SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
 FROM region r
 JOIN sales_reps s
 ON s.region_id = r.id
 JOIN accounts a
 ON a.sales_rep_id = s.id
 JOIN orders o
 ON o.account_id = a.id
 WHERE o.standard_qty > 100 AND o.poster_qty > 50
 ORDER BY unit_price DESC;


/*07 What are the different channels used by account id 1001? Your final table
should have only 2 columns: account name and the different channels. You can try
 SELECT DISTINCT to narrow down the results to only the unique values.*/

SELECT DISTINCE a.name account, w.channel channels
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = '1001';

/*08 Find all the orders that occurred in 2015. Your final table should have 4
columns: occurred_at, account name, order total, and order total_amt_usd.*/

SELECT o.occurred_at OrderDate, a.name account, o.total total, o.total_amt_usd total_usd
FROM accounts a
JOIN orders o
ON a.id = o.account_id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016';
