-- 1. What are the Top 5 rented categories?

SELECT f.title, c.name, COUNT(r.rental_id) retntal_count
FROM film f, category c, film_category fc, rental r, inventory i
WHERE f.film_id = fc.film_id AND fc.category_id = c.category_id AND r.inventory_id = i.inventory_id AND f.film_id = i.film_id AND c.name IN ('Action', 'Animation', 'Children', 'Classics', 'Comedy', 'Documentary', 'Drama', 'Foreign', 'Games', 'Horror', 'New', 'Sci-Fi', 'Sports', 'Travel', 'Family', 'Music')
GROUP BY 1, 2
ORDER BY 2, 3 DESC;



-- 2. What are the total sales for these top 5 categories or what categories bring in the most sales?

-- Rental count and total sales 

WITH
    t1
    AS
    (
        SELECT c.name categories, COUNT(r.rental_id) retntal_count
        FROM film f, category c, film_category fc, rental r, inventory i
        WHERE f.film_id = fc.film_id AND fc.category_id = c.category_id AND r.inventory_id = i.inventory_id AND f.film_id = i.film_id
        GROUP BY 1
        ORDER BY 2 DESC
    ),

    t2
    AS
    (
        SELECT c.name categories, SUM(p.amount) total_rev
        FROM category c, film_category fc, film f, inventory i, rental r, payment p
        WHERE f.film_id = fc.film_id AND fc.category_id = c.category_id AND r.inventory_id = i.inventory_id AND f.film_id = i.film_id AND p.rental_id = r.rental_id
        GROUP BY 1
        ORDER BY 2 DESC
    )

SELECT t1.categories, t1.retntal_count, t2.total_rev
FROM t1, t2
WHERE t1.categories = t2.categories
ORDER BY 3 DESC;




-- 3. How many films were returned early, late, and on time?

WITH
    t1
    AS
    (
        SELECT rental_duration - DATE_PART('day', return_date - rental_date) AS days_rented
        FROM rental r, inventory i, film f
        WHERE r.inventory_id = i.inventory_id AND f.film_id = i.film_id
    )
SELECT CASE WHEN days_rented > 0 THEN 'Early'
            WHEN days_rented = 0 THEN 'On Time'
            ELSE 'Late' END AS rental_status,
    count(*),
    (100*count(*))/sum(count(*)) OVER () AS percentage
FROM t1
GROUP BY 1
ORDER BY 3 DESC;


-- 4. Is there a difference in inventory based on top categories?

WITH
    t1
    AS
    (
        SELECT f.title, f.film_id film, fc.category_id fc_category_id, c.name categories
        FROM film f, film_category fc, inventory i, category c
        WHERE f.film_id = fc.film_id AND fc.category_id = c.category_id AND f.film_id = i.film_id
    )

SELECT categories, COUNT(*) num_copies
FROM t1
GROUP BY 1
ORDER BY 2 DESC;