/* 01 "LIMIT + #"

Limit the number of lines displayed after running our statement*/
SELECT occurred_at, account_id, channel
FROM web_events
LIMIT 15;

/* 02 ORDER BY

The ORDER BY statement allows us to sort our results using the data in any
column. If you are familiar with Excel or Google Sheets, using ORDER BY is
similar to sorting a sheet using a column. A key difference, however, is that
using ORDER BY in a SQL query only has temporary effects, for the results of
that query, unlike sorting a sheet by column in Excel or Sheets.

The ORDER BY statement always comes in a query after the SELECT and FROM
statements, but before the LIMIT statement. If you are using the LIMIT statement
, it will always appear last. As you learn additional commands, the order of
these statements will matter more.

Tip
Remember DESC can be added after the column in your ORDER BY statement to sort
in descending order, as the default is to sort in ascending order.

we can ORDER BY more than one column at a time. When you provide a list of
columns in an ORDER BY command, the sorting occurs using the leftmost column in
your list first, then the next column from the left, and so on. We still have
the ability to flip the way we order using DESC.*/

SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY occurred_at
LIMIT 10;

SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5;

SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY total_amt_usd
LIMIT 20;

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC
LIMIT 10;

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC
LIMIT 10;

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id
LIMIT 10;

/* 03 Using the WHERE statement, we can display subsets of tables based on
conditions that must be met. You can also think of the WHERE command as
filtering the data.The WHERE statement can also be used with non-numeric data.
We can use the = and != operators here.

You need to be sure to use single quotes (just be careful if you have quotes
in the original text) with the text data,
 not double quotes.

 Commonly when we are using WHERE with non-numeric data fields, we use the LIKE,
 NOT, or IN operators. We will see those before the end of this lesson!*/

Common symbols used in WHERE statements include:

> (greater than)
< (less than)
>= (greater than or equal to)
<= (less than or equal to)
= (equal to)
!= (not equal to)

SELECT *
FROM orders
WHERE gloss_amt_usd >= 1000
LIMIT 5;

SELECT *
FROM orders
WHERE total_amt_usd <= 500
LIMIT 10;

SELECT name, website, primary_poc
FROM accounts
WHERE name = 'Exxon Mobil';


/* 04 Derived column
Derived Columns
Creating a new column that is a combination of existing columns is known as a
derived column (or "calculated" or "computed" column). Usually you want to give
a name, or "alias," to your new column using the */ AS /*keyword.

This derived column, and its alias, are generally only temporary, existing just
for the duration of your query. The next time you run a query and access this
table, the new column will not be there.

If you are deriving the new column from existing columns using a mathematical
expression, then these familiar mathematical operators will be useful:*/

* (Multiplication)
+ (Addition)
- (Subtraction)
/ (Division)

SELECT id, account_id,(standard_amt_usd/standard_qty) AS unit_price
FROM orders
LIMIT 10;

SELECT id, account_id, poster_amt_usd/(standard_amt_usd + gloss_amt_usd + poster_amt_usd)*100 AS percent_rev_poster
FROM orders
LIMIT 10;

/* 05 Logical Operators include:

LIKE
This allows you to perform operations similar to using WHERE and =, but for
cases when you might not know exactly what you are looking for.The LIKE operator
is frequently used with %. The % tells us that we might want any number of
characters leading up to a particular set of characters or following a certain
set of characters, as we saw with the google syntax above.

Remember you will need to use single quotes for the text you pass to the LIKE
operator, because of this lower and uppercase letters are not the same within
the string. Searching for 'T' is not the same as searching for 't'. In other
SQL environments (outside the classroom), you can use either single or double quotes.*/

e.g. All the companies whose names START with 'C'.
SELECT name
FROM accounts
WHERE name LIKE 'C%';

e.g.All companies whose names contain the string 'one' somewhere in the name.
SELECT name
FROM accounts
WHERE name LIKE '%one%';

e.g. All companies whose names end with 's'.
SELECT name
FROM accounts
WHERE name LIKE '%s';

/*
IN
This allows you to perform operations similar to using WHERE and =,
but for more than one condition.

The IN operator is useful for working with both numeric and text columns.
This operator allows you to use an =, but for more than one item of that
particular column. We can check one, two or many column values for which we
want to pull data, but all within the same query. In the upcoming concepts,
you will see the OR operator that would also allow us to perform these tasks,
but the IN operator is a cleaner way to write these queries.

Expert Tip
In most SQL environments, although not in our Udacity's classroom, you can use
single or double quotation marks - and you may NEED to use double quotation
marks if you have an apostrophe within the text you are attempting to pull.

*/
e.g.Use the accounts table to find the account name, primary_poc,
and sales_rep_id for Walmart, Target, and Nordstrom.

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart','Target','Nordstrom')
LIMIT 10;


/*
NOT
This is used with IN and LIKE to select all of the rows NOT LIKE or NOT IN a
certain condition.The NOT operator is an extremely useful operator for working
with the previous two operators we introduced: IN and LIKE. By specifying NOT
LIKE or NOT IN, we can grab all of the rows that do not meet a particular criteria.
*/
e.g.excluding these three stores

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom');

e.g.excluding company names that start with C
SELECT name
FROM accounts
WHERE name NOT LIKE 'C%';


/*
AND & BETWEEN
These allow you to combine operations where all combined conditions must be true.

Instead of writing :

WHERE column >= 6 AND column <= 10
we can instead write, equivalently:

WHERE column BETWEEN 6 AND 10 */

e.g.Write a query that returns all the orders where the standard_qty is over 1000,
the poster_qty is 0, and the gloss_qty is 0.

SELECT *
FROM orders
WHERE standard_qty >1000 AND poster_qty = 0 AND gloss_qty =0
LIMIT 10;

e.g.Using the accounts table, find all the companies whose names do not start with 'C' and end with 's'.

SELECT *
FROM accounts
WHERE name NOT IN ('C%','%s');

e.g.Write a query that displays the order date and gloss_qty data for all
orders where gloss_qty is between 24 and 29. Then look at your output to see if
the BETWEEN operator included the begin and end values or not. >> YES, INCLUDE

SELECT occurred_at, gloss_qty
FROM orders
WHERE gloss_qty BETWEEN 24 AND 29;

e.g.Use the web_events table to find all information regarding individuals who
 were contacted via the organic or adwords channels, and started their account at
 any point in 2016, sorted from newest to oldest.While BETWEEN is generally
 inclusive of endpoints, it assumes the time is at 00:00:00 (i.e. midnight) for
 dates. This is the reason why we set the right-side endpoint of the period at '2017-01-01'.

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;


*/OR/*
This allow you to combine operations where at least one of the combined
conditions must be true.
Similar to the AND operator, the OR operator can combine multiple statements.
Each time you link a new statement with an OR, you will need to specify the
column you are interested in looking at. You may link as many statements as you
would like to consider at the same time. This operator works with all of the
operations we have seen so far including arithmetic operators (+, *, -, /),
LIKE, IN, NOT, AND, and BETWEEN logic can all be linked together using the OR operator.

When combining multiple of these operations, we frequently might need to use
parentheses to assure that logic we want to perform is being executed correctly.
The video below shows an example of one of these situations.*/

e.g.Find list of orders ids where either gloss_qty or poster_qty is greater than 4000.
Only include the id field in the resulting table.

SELECT id
FROM orders
WHERE (gloss_qty > 4000 OR poster_qty >4000);

e.g.Write a query that returns a list of orders where the standard_qty is zero and
either the gloss_qty or poster_qty is over 1000.

SELECT standard_qty,
	   gloss_qty,
       poster_qty,
FROM orders
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);

e.g.Find all the company names that start with a 'C' or 'W', and the primary contact
contains ana' or Ana, but it doesnt contain eana'.*/

SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
           AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
           AND primary_poc NOT LIKE '%eana%');

/* */
/* */
/* */
/* */
/* */
/* */
