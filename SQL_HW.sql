use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
 FROM actor;
 
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(concat(first_name, ' ', last_name)) as 'Actor_Name'
	from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
	-- What is one query would you use to obtain this information?
select actor_id, first_name, last_name
	from actor
	where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name
	from actor
	where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id, first_name, last_name
	from actor
	where last_name like '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
    FROM country
    where country in ('Afghanistan', 'Bangladesh', 'China');
    
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
	-- so create a column in the table actor named description and use the data type BLOB
alter table actor
	add column description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
	drop description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as 'Total Actors'
	from actor group by last_name; 

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) as 'Total Actors'
	from actor group by last_name having count(last_name) >= 2; 

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor
	set first_name = 'HARPO'
    where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
	-- It turns out that GROUCHO was the correct name after all! In a single query, 
    -- if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor
	set first_name = 'GROUCHO' where first_name = 'HARPO';
    
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
create schema sakila;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name, address 
	from staff
    join address using (address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select payment.staff_id, staff.first_name, staff.last_name, payment.amount, payment.payment_date
	from staff 
    join payment 
    on staff.staff_id = payment.staff_id and payment_date like '2005-08%';

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select film.title, count(actor_id) as 'Number of Actors'
	from film
    join film_actor using (film_id)
    group by title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select film.title, count(film_id) as 'Total'
	from film
    join inventory using (film_id)
    where film.title = 'Hunchback Impossible'
    group by title;
	
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
	-- List the customers alphabetically by last name:
select customer.first_name, customer.last_name, sum(payment.amount) as 'Total Paid'
	from customer
    join payment using (customer_id)
    group by first_name, last_name
    order by last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
	-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
    -- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title
	from film
    where (title like 'K%' or title like 'Q%')
    and language_id = (
		select language_id 
			from language 
            where name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name
	from actor
    where actor_id
		in (select actor_id from film_actor where film_id
			in (select film_id from film where title = 'Alone Trip')); 

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
	-- Use joins to retrieve this information.
select first_name, last_name, email
	from customer
    join address using(address_id)
    join city using(city_id)
    join country using(country_id)
		where country = 'Canada';
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
	-- Identify all movies categorized as family films.
select title
	from film
    join film_category using(film_id)
    join category using(category_id)
		where name = 'Family';
    
-- 7e. Display the most frequently rented movies in descending order.
select title, sum(rental_rate) as 'Total Rentals'
	from film
    join inventory using(film_id)
    join rental using (inventory_id)
    group by title
    order by 'Total Rentals' desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, sum(amount) as 'Total Business'
from payment
join staff using (staff_id)
join store using (store_id)
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country
	from store
    join address using (address_id)
    join city using (city_id)
    join country using (country_id);
    
-- 7h. List the top five genres in gross revenue in descending order. 
	-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select name as 'Genre', sum(payment.amount) as 'Gross Revenue'
	from category
    join film_category using(category_id)
    join inventory using(film_id)
    join rental using(inventory_id)
    join payment using(rental_id)
    group by name
	order by 'Gross Revenue' limit 5;
    
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
	-- Use the solution from the problem above to create a view. 
    -- If you haven't solved 7h, you can substitute another query to create a view.
create view Top_Five_Genres as
	select name as 'Genre', sum(payment.amount) as 'Gross Revenue'
	from category
    join film_category using(category_id)
    join inventory using(film_id)
    join rental using(inventory_id)
    join payment using(rental_id)
    group by name
	order by 'Gross Revenue' limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from Top_Five_Genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view Top_Five_Genres;
 
