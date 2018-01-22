-- Homework Assignment
-- •1a. Display the first and last names of all actors from the table actor. 
USE sakila;
SELECT first_name, last_name 
FROM actor;

-- •1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name. 
SELECT CONCAT (UPPER (first_name), " " , UPPER(last_name) ) as Full_Name
FROM actor;

-- •2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name 
FROM actor_info
WHERE first_name = "Joe";

-- •2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name 
FROM actor_info 
WHERE last_name LIKE ('%GEN%');

-- •2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name 
FROM actor_info 
WHERE last_name LIKE ('%LI%')
ORDER BY last_name, first_name;

-- •2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

--  •3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
-- wtf, why won't this case statement run?  mysql doesn't handle flow control unless it's stored prc??
-- CASE 
--     WHEN EXISTS(SELECT * 
--           FROM information_schema.COLUMNS 
--           WHERE 
--           TABLE_SCHEMA = 'sakila' 
--           AND TABLE_NAME = 'actor' 
--           AND COLUMN_NAME = 'middle_name')
--     THEN
--         BEGIN
--             ALTER TABLE actor DROP COLUMN middle_name
--         END
-- END CASE;

ALTER TABLE actor DROP COLUMN middle_name; 

ALTER TABLE actor 
ADD COLUMN middle_name varchar(45) AFTER first_name;

-- •3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor 
MODIFY COLUMN middle_name blob;

-- •3c. Now delete the middle_name column.
ALTER TABLE actor DROP COLUMN middle_name; 

-- •4a. List the last names of actors, as well as how many actors have that last name.
-- christ, it makes a difference if there's a space between the COUNT function and its parentheses.  
SELECT last_name, COUNT(*) 
FROM actor
GROUP BY last_name;

-- •4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) 
FROM actor
GROUP BY last_name
HAVING count(*) >1;

-- •4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
SELECT * FROM actor WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

UPDATE actor 
SET first_name =  'HARPO' WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

SELECT * from actor WHERE actor_id = 172; 

-- •4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
SELECT * FROM actor WHERE first_name = 'HARPO'; -- AND last_name = 'WILLIAMS';

UPDATE actor 
SET first_name = 
    CASE 
        WHEN first_name = 'HARPO' AND last_name = 'WILLIAMS' THEN 'GROUCHO'
        WHEN first_name <> 'HARPO' AND last_name = 'WILLIAMS' THEN 'MUCHO'
        ELSE first_name = first_name
	END
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS'  -- or WHERE actor_id = 172;
;

SELECT * FROM actor WHERE last_name = 'WILLIAMS'; -- AND last_name = 'WILLIAMS';

-- •5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Using MySQL copy to clip-board -> Create statement
CREATE TABLE IF NOT EXISTS `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;


-- •6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT sf.first_name, sf.last_name, ad.address 
FROM staff sf 
INNER JOIN address ad
ON sf.address_id = ad.address_id;

-- •6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 
SELECT sf.first_name, sf.last_name, sum(amount)
FROM staff sf 
JOIN payment p
ON sf.staff_id = p.staff_id
WHERE payment_date >= '2005-08-01' AND  payment_date < '2005-09-01' 
GROUP BY sf.first_name, sf.last_name
;

-- •6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
-- title appears in film and film_text.  Determine which to take.  
select count(*)
FROM film_text	;
select count(*) from film;
-- both appear to have the same count of films.  

SELECT fi.title as fi_title, ft.title as ft_title
FROM film fi JOIN film_text ft on fi.film_id = ft.film_id
WHERE fi.title <> ft.title; 
-- the columns appear to be synonymous.  

SELECT title, count(fa.actor_id) as count_of_actors
FROM film fi
INNER JOIN film_actor fa
ON fi.film_id = fa.film_id
GROUP BY title
;

-- •6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT count(inventory_id) as count_of_inventory	
FROM inventory i
WHERE film_id in 
    (
	SELECT film_id 
	FROM film fi 
	WHERE title = 'Hunchback Impossible'
    )
;

-- •6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
    cu.last_name, 
    cu.first_name, 
    SUM(p.amount) as total_paid
FROM payment p 
JOIN customer cu
ON p.customer_id = cu.customer_id
GROUP BY cu.last_name, cu.first_name
ORDER BY cu.last_name, cu.first_name
;


-- •7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles 
-- of movies starting with the letters K and Q whose language is English. 
SELECT film_id, title
FROM film fi
WHERE (fi.title LIKE ('K%') OR title LIKE ('Q%') ) AND fi.language_id IN 
    (
	SELECT language_id 
	FROM language l
	WHERE l.name = 'english'
    )
;

-- •7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT 	first_name, last_name 
FROM actor a WHERE actor_id IN 
    (
    SELECT actor_id
	FROM film_actor fa
	WHERE film_id IN 
		(
		SELECT film_id 
		FROM film fi 
		WHERE title = 'Alone Trip'
		)
	)
;

-- •7c. You want to run an email marketing campaign in Canada, for which you will need the 
-- names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT last_name, first_name, cu.email
FROM customer cu INNER JOIN address ad
ON cu.address_id = ad.address_id
INNER JOIN city ci 
ON ad.city_id = ci.city_id
INNER JOIN country co
ON ci.country_id = co.country_id
WHERE co.country = 'Canada'
;

-- •7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT title
FROM film fi 
INNER JOIN film_category fc 
ON fi.film_id = fc.film_id
INNER JOIN category ca
ON fc.category_id = ca.category_id
WHERE ca.name = 'Family'
ORDER BY title
;


-- •7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.inventory_id)
FROM inventory i
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN film f 
ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY COUNT(r.inventory_id) DESC, f.title ASC;

-- •7f. Write a query to display how much business, in dollars, each store brought in.

SELECT COUNT(*) FROM rental;
SELECT COUNT(*) FROM rental r INNER JOIN payment p ON r.rental_id = p.rental_id  ;
SELECT COUNT(*) FROM payment p INNER JOIN rental r ON p.rental_id  = r.rental_id; 
SELECT COUNT(*) FROM payment p INNER JOIN rental r ON p.rental_id  = r.rental_id INNER JOIN inventory i ON r.inventory_id = i.inventory_id INNER JOIN store s ON i.store_id = s.store_id INNER JOIN address a_s ON s.address_id = a_s.address_id INNER JOIN city ci_s ON a_s.city_id = ci_s.city_id; 
SELECT DISTINCT address_id FROM store ;

SELECT ci_s.city, a_s.address, sum(p.amount ) AS US$ -- , 
FROM payment p 
INNER JOIN rental r ON p.rental_id  = r.rental_id 
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN store s ON i.store_id = s.store_id
INNER JOIN address a_s ON s.address_id = a_s.address_id
INNER JOIN city ci_s ON a_s.city_id = ci_s.city_id
GROUP BY ci_s.city, a_s.address
;

-- •7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, ci_s.city, co.country
FROM store s 
INNER JOIN address a_s ON s.address_id = a_s.address_id
INNER JOIN city ci_s ON a_s.city_id = ci_s.city_id
INNER JOIN country co ON ci_s.country_id = co.country_id
;

-- •7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT ca.name, sum(p.amount ) AS Revenue_US$ -- count(*) -- reveals no duplication through the mapping tables.   
FROM payment p 
INNER JOIN rental r ON p.rental_id  = r.rental_id 
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film fi ON i.film_id  = fi.film_id
INNER JOIN film_category fc ON fi.film_id = fc.film_id
INNER JOIN category ca ON fc.category_id = ca.category_id
GROUP BY ca.name
ORDER BY sum(p.amount) DESC, ca.name ASC
;

-- •8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
DROP VIEW IF EXISTS top_5_genres_vw; 

CREATE VIEW top_5_genres_vw AS 
SELECT ca.name, sum(p.amount ) AS Revenue_US$ -- count(*) -- reveals no duplication through the mapping tables.   
FROM payment p 
INNER JOIN rental r ON p.rental_id  = r.rental_id 
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film fi ON i.film_id  = fi.film_id
INNER JOIN film_category fc ON fi.film_id = fc.film_id
INNER JOIN category ca ON fc.category_id = ca.category_id
GROUP BY ca.name
ORDER BY sum(p.amount) DESC, ca.name ASC
LIMIT 5
;

SELECT * FROM top_5_genres_vw;

-- •8b. How would you display the view that you created in 8a?
SELECT * FROM top_5_genres_vw;

-- •8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS top_5_genres_vw; 


