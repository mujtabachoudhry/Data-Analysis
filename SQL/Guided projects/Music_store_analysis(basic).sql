-- This project is basic and I am analyzing data of a music store. I am missing one table which makes it difficult to join tables. I have wrote some basic queries to get insights from the data. Since there are a lot of tables so most of the queries include joining of tables.

-- Tables include artist, customer, employee, genre, invoice, invoice_line, media_type, playlist, playlist_track, track (, album (missing))


-- Exploratory data analysis
SELECT *
FROM customer;
DESCRIBE customer;

SELECT *
FROM artist;
DESCRIBE artist;

SELECT *
FROM invoice;
DESCRIBE invoice;

SELECT *
FROM employee;
DESCRIBE employee;

SELECT *
FROM genre;
DESCRIBE genre;

SELECT *
FROM invoice_line;
DESCRIBE invoice_line;

SELECT *
FROM media_type;
DESCRIBE media_type;

SELECT *
FROM playlist;
DESCRIBE playlist;

SELECT *
FROM playlist_track;
DESCRIBE playlist_track;

SELECT *
FROM track;
DESCRIBE track;


-- Senior most employee based on job title
SELECT *
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Countries having the most invoices
SELECT count(*), billing_country
FROM invoice
GROUP BY billing_country
ORDER BY count(*) DESC;

-- Top 3 values of total invoices
SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Three cities having the best customers (city with highest sum of invoices)
SELECT billing_city, sum(total) AS Sum_Total
FROM invoice
GROUP BY billing_city
ORDER BY Sum_total DESC
LIMIT 3;

-- The best customer (Person who spent the most money)
SELECT customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as Sum_Total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY Sum_Total DESC
LIMIT 1;

-- All Rock Music listeners. List is ordered alphabetically by email starting with A
SELECT customer.email, customer.first_name, customer.last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
    JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE "Rock"
)
ORDER BY email;

-- Track names that have a song length longer than the average song length. Name and Milliseconds are returned for each track. List is order by song length with the longest songs listed first
SELECT Name, Milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS average_length
    FROM track)
ORDER BY milliseconds DESC;

-- A lot more can be explored in this data set but I am missing one table so I am leaving it here.