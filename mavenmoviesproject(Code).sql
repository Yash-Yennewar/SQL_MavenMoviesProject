-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.

USE MAVENMOVIES;

-- EXPLORATORY DATA ANALYSIS --

-- UNDERSTANDING THE SCHEMA --

SELECT * FROM RENTAL;
SELECT CUSTOMER_ID, RENTAL_DATE FROM RENTAL;
SELECT * FROM INVENTORY;
SELECT * FROM FILM;
SELECT * FROM CUSTOMER;

-- --------------------------------------------------------------------------------

-- You need to provide customer firstname, lastname and email id to the marketing team --

select first_name,last_name,email from customer;

-- --------------------------------------------------------------------------------

-- How many movies are with rental rate of $0.99? --

select count(*) from film where rental_rate = '0.99';

-- --------------------------------------------------------------------------------

-- We want to see rental rate and how many movies are in each rental category --

select rental_rate, count(*) AS no_of_movies from film group by rental_rate;

-- -------------------------------------------------------------------------------

-- Which rating has the most films? --

select rating,count(*) AS rating_films from film group by rating order by rating_films desc;

-- -------------------------------------------------------------------------------

-- Which rating is most prevalant in each store? --

select I.store_id,F.rating,count(F.rating) AS  most_prevalant_rating from film AS F
inner join inventory AS I ON F.film_id = I.film_id
group by I.store_id,F.rating
order by most_prevalant_rating desc;

-- -------------------------------------------------------------------------------

-- List of films by Film Name, Category, Language --

select F.title AS Film_Name,C.name AS Category_Name,L.name AS Language_Name from film_category AS FC
left join category AS C ON FC.category_id = C.category_id
left join film AS F ON FC.film_id = F.film_id
left join language AS L ON F.language_id = L.language_id;

-- -------------------------------------------------------------------------------

-- How many times each movie has been rented out?

SELECT F.film_id,F.title,count(*) AS rented_out FROM rental AS R
left join inventory AS I ON R.inventory_id = I.inventory_id
left join film AS F ON I.film_id = F.film_id
group by F.film_id,F.title
order by rented_out desc;

-- -------------------------------------------------------------------------------

-- REVENUE PER FILM (TOP 10 GROSSERS)

select F.title,SUM(P.amount) AS total_amt from payment AS P
left join rental AS R ON P.rental_id = R.rental_id
left join inventory AS I ON R.inventory_id = I.inventory_id
left join film AS F ON I.film_id = F.film_id
group by F.title
order by total_amt desc
limit 10;

-- -------------------------------------------------------------------------------

-- Most Spending Customer so that we can send him/her rewards or debate points

select C.customer_id,C.first_name,C.last_name,C.email, SUM(P.amount) AS amt from payment AS P
left join customer AS C ON P.customer_id = C.customer_id
group by C.customer_id
order by amt desc
limit 10;

-- -------------------------------------------------------------------------------

-- Which Store has historically brought the most revenue?

select S.store_id,SUM(P.amount) AS revenue from payment AS P
left join staff AS S ON P.staff_id = S.staff_id
group by S.store_id
order by revenue desc
limit 1;

-- -------------------------------------------------------------------------------

-- How many rentals we have for each month

select
extract(month from rental_date) AS month_no,
extract(year from rental_date) AS year_no,
count(*) AS no_of_rentals
from rental
group by extract(year from rental_date),extract(month from rental_date);

-- -------------------------------------------------------------------------------

-- Reward users who have rented at least 30 times (with details of customers)

select C.customer_id,C.first_name,C.last_name,C.email,count(*) AS no_of_rows from rental AS R
left join customer AS C ON R.customer_id = C.customer_id
group by C.customer_id
having no_of_rows >=30;

-- -------------------------------------------------------------------------------

-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?

select title,special_features from film where special_features like "%Behind the Scenes%";

-- -------------------------------------------------------------------------------

-- unique movie ratings and number of movies

SELECT rating,count(*) AS count_of_movies FROM film group by rating order by count_of_movies desc;

-- -------------------------------------------------------------------------------

-- Could you please pull a count of titles sliced by rental duration?

select rental_duration,count(film_id) as no_of_films from film group by rental_duration;

-- -------------------------------------------------------------------------------

-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION

SELECT rating,count(*) AS count_of_movies,
min(length),round(avg(length)) AS avg_length,
max(length),round(avg(rental_duration)) AS avg_rental_duration
FROM film group by rating order by count_of_movies desc;

-- -------------------------------------------------------------------------------

-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate, grouped by replacement cost?

select count(film_id) AS count_of_films,replacement_cost,
round(avg(rental_rate),2) AS avg_rental_rate,
round(min(rental_rate),2) AS min_rental_rate,
round(max(rental_rate),2) AS max_rental_rate
from film group by replacement_cost order by replacement_cost;

-- -------------------------------------------------------------------------------

-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”

select C.customer_id,C.first_name,C.last_name,C.email,count(*) AS no_of_rows from rental AS R
left join customer AS C ON R.customer_id = C.customer_id
group by C.customer_id
having no_of_rows <= 15;

-- -------------------------------------------------------------------------------

-- CATEGORIZE MOVIES AS PER LENGTH

select *,
case
when length < 60 then "short movie"
when length between 60 and 90 then "medium movie"
when length > 90 then "long movie"
else "error"
end as movie_length_catagory
from film;

-- -------------------------------------------------------------------------------

-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC

select distinct title,
case
	when rental_duration <= 4 then 'Rental Too Short'
    when rental_rate >= 3.99 then 'Too Expensive'
    when rating in ('NC-17','R') then 'Adult Movie'
    when length not between 60 and 90 then 'Too Short OR Too Long Length'
    when description like '%Shark%' then 'No It has Sharks'
    else 'GREAT_RECOMMENDATION_FOR_CHILDREN'
end as fit_for_recommendation
from film;

-- -------------------------------------------------------------------------------

-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”

select customer_id,first_name,last_name,
case
	when store_id = 1 and active = 1 then "store 1 active"
    when store_id = 1 and active = 0 then "store 1 inactive"
    when store_id = 2 and active = 1 then "store 2 active"
    when store_id = 2 and active = 0 then "store 2 inactive"
	else "error"
end as store_status
from customer;

-- -------------------------------------------------------------------------------

-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value associated with each item, and its inventory_id. Thanks!”

select I.inventory_id,I.store_id,F.title,F.description from film AS F
inner join inventory AS I ON F.film_id = I.film_id;

-- -------------------------------------------------------------------------------

-- Actor first_name, last_name and number of movies

select A.actor_id,A.first_name,A.last_name,count(*) AS no_of_movies from actor AS A
left join film_actor AS FA on A.actor_id = FA.actor_id
group by  A.actor_id
order by no_of_movies;

-- -------------------------------------------------------------------------------

-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are associated with each title?”

select F.film_id,F.title,count(*) AS actors_count from film AS F
inner join film_actor AS FA on F.film_id = FA.film_id
group by F.film_id;

-- -------------------------------------------------------------------------------

-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”

select A.actor_id,A.first_name,A.last_name,F.title from actor As A
left join film_actor As FA on A.actor_id = FA.actor_id
left join film AS F on FA.film_id = F.film_id;

-- -------------------------------------------------------------------------------

-- “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”

select distinct F.title, F.description from film As F
inner join inventory AS I on F.film_id = I.film_id
where I.store_id = 2;

-- -------------------------------------------------------------------------------

-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”

(select first_name,last_name,"Staff_Member" AS Designation from staff
union
select first_name,last_name,"Advisor_Member" AS Designation from advisor);

-- -------------------------------------------------------------------------------