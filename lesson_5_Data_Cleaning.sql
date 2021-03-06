/* LEFT, RIGHT, LENGTH

LEFT pulls a specified number of characters for each row in a specified column
starting at the beginning (or from the left). As you saw here, you can pull the
first three digits of a phone number using LEFT(phone_number, 3).


RIGHT pulls a specified number of characters for each row in a specified column
starting at the end (or from the right). As you saw here, you can pull the last
eight digits of a phone number using RIGHT(phone_number, 8).


LENGTH provides the number of characters for each row of a specified column.
Here, you saw that we could use this to get the length of each phone number as
LENGTH(phone_number).*/

e.g.1 In the accounts table, there is a column holding the website for each company.
The last three digits specify what type of web address they are using. A list of
extensions (and pricing) is provided here. Pull these extensions and provide how
many of each website type exist in the accounts table.

SELECT RIGHT(website, 3) AS domain, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

e.g.2 There is much debate about how much the name (or even the first letter of
  a company name) matters. Use the accounts table to pull the first letter of each
company name to see the distribution of company names that begin with each letter (or number).

SELECT LEFT(UPPER(name), 1) AS first_letter, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

e.g.3 Use the accounts table and a CASE statement to create two groups: one group
of company names that start with a number and a second group of those company names that start with a letter.
What proportion of company names start with a letter?

SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                       THEN 1 ELSE 0 END AS num,
         CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                       THEN 0 ELSE 1 END AS letter
      FROM accounts) t1;

e.g.4 Consider vowels as a, e, i, o, and u. What proportion of company names start
with a vowel, and what percent start with anything else?

SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
                        THEN 1 ELSE 0 END AS vowels,
          CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
                       THEN 0 ELSE 1 END AS other
         FROM accounts) t1;


/* POSITION, STRPOS, LOWER, UPPER

POSITION takes a character and a column, and provides the index where that
character is for each row. The index of the first position is 1 in SQL. If you
 come from another programming language, many begin indexing at 0. Here, you saw
 that you can pull the index of a comma as POSITION(',' IN city_state).

STRPOS provides the same result as POSITION, but the syntax for achieving those
results is a bit different as shown here: STRPOS(city_state, ',').

Note, both POSITION and STRPOS are case sensitive, so looking for A is different
 than looking for a.

Therefore, if you want to pull an index regardless of the case of a letter, you
might want to use LOWER or UPPER to make all of the characters lower or uppercase.*/

e.g.1 Use the accounts table to create first and last name columns that hold the
first and last names for the primary_poc.

SELECT primary_poc,
       LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) AS first_name,
       RIGHT(primary_poc,LENGTH(primary_poc)-STRPOS(primary_poc, ' ')) AS last_name
FROM accounts;

e.g. 2 Now see if you can do the same thing for every rep name in the sales_reps
table. Again provide first and last name columns.

SELECT name,
       LEFT(name, STRPOS(name, ' ')-1) AS first_name,
       RIGHT(name,LENGTH(name)-STRPOS(name, ' ')) AS last_name
FROM sales_reps;


/*  CONCAT & Piping '||'
Each of these will allow you to combine columns together across rows. In this
video, you saw how first and last names stored in separate columns could be combined
together to create a full name: CONCAT(first_name, ' ', last_name) or with piping as
first_name || ' ' || last_name.*/

e.g.1 Each company in the accounts table wants to create an email address for
each primary_poc. The email address should be the first name of the
primary_poc . last name primary_poc @ company name .com.

WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com')
FROM t1;

OR

WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
FROM  t1;

e.g.2 We would also like to create an initial password, which they will change
after their first log in. The first password will be the first letter of the
primary_poc first name (lowercase), then the last letter of their first name (lowercase),
the first letter of their last name (lowercase), the last letter of their last name (lowercase),
the number of letters in their first name, the number of letters in their last name,
and then the name of the company they are working with, all capitalized with no spaces.

WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'), LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;

/* TO_DATE, CAST, and casting with '::'
DATE_PART('month', TO_DATE(month, 'month')) here changed a month name into the
number associated with that particular month.

Then you can change a string to a date using CAST. CAST is actually useful to
change lots of column types. Commonly you might be doing as you saw here, where
you change a string to a date using CAST(date_column AS DATE). However, you might
want to make other changes to your columns in terms of their data types. You can
see other examples here.

In this example below, you also saw that instead of CAST(date_column AS DATE), you can
use date_column::DATE.
*/
e.g.
SELECT *,
       DATE_PART('month', TO_DATE(month,'month')) AS clean_month,
       year || '-' || DATE_PART('month', TO_DATE(month,'month')) || '-' || day AS concatenated_date,
       CAST(year || '-' || DATE_PART('month', TO_DATE(month,'month')) || '-' || day AS date) AS formatted_date,
       (year || '-' || DATE_PART('month', TO_DATE(month,'month')) || '-' || day AS date)::date AS formatted_date_a
FROM ad_clicks

/* Expert Tip
LEFT, RIGHT, and TRIM are all used to select only certain elements of strings,
but using them to select elements of a number or date will treat them as strings
for the purpose of the function. Though we didn't cover TRIM in this lesson explicitly,
it can be used to remove characters from the beginning and end of a string. This can
remove unwanted spaces at the beginning or end of a row that often happen with data
being moved from Excel or other storage systems.*/

e.g. PRACTICES: the date formate is currently "mm-dd-yyyy". We want to transform
it to correct SQL formate "yyyy-mm-dd"

STEP 1
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2)) new_date
FROM sf_crime_data;

STEP 2
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2))::DATE new_date
FROM sf_crime_data;

/* COALESCE
How to use COALESCE to work with NULL values?
COALESCE returns the first non-NULL value passed for each row */

SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COALESCE(a.id, a.id) filled_id,
       a.name,
       a.website,
       a.lat,
       a.long,
       a.primary_poc,
       a.sales_rep_id,
       COALESCE(o.account_id, a.id) account_id,
       o.occurred_at,
       COALESCE(o.standard_qty, 0) standard_qty,
       COALESCE(o.gloss_qty,0) gloss_qty,
       COALESCE(o.poster_qty,0) poster_qty,
       COALESCE(o.total,0) total,
       COALESCE(o.standard_amt_usd,0) standard_amt_usd,
       COALESCE(o.gloss_amt_usd,0) gloss_amt_usd,
       COALESCE(o.poster_amt_usd,0) poster_amt_usd,
       COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;

/* Other resources

https://mode.com/sql-tutorial/sql-string-functions-for-cleaning/

https://mode.com/sql-tutorial/sql-string-functions-for-cleaning/ */


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
/*  */
/*  */
/*  */
/*  */
/*  */
