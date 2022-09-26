-- Airbnb Toronto Listings Data analysis

-- Data exploration
SELECT * FROM [Portfolio Project].dbo.listings

-- Seeing how many Airbnb hosts are in Toronto currently?
SELECT count(distinct host_id) as no_of_hosts
FROM [Portfolio Project].dbo.listings

-- Seeing number of listings
SELECT count(distinct id) as no_of_listings
FROM [Portfolio Project].dbo.listings

-- Checking hosts with multiple listings
SELECT no_listings_per_host, 
	count(host_id) as host_count,
	count(host_id)/sum(count(host_id)) over ()
FROM 
	(select host_id, count(distinct id) as no_listings_per_host
FROM [Portfolio Project].dbo.listings
group by host_id) as a
group by 
	no_listings_per_host
order by
	no_listings_per_host
-- About 8,322 hosts have only 1 listings in the Toronto area


-- Checking no. of listings and avg price by neighbourhood
SELECT neighbourhood,
	count(id) as no_of_listings,
	AVG(price) as avg_price
FROM [Portfolio Project].dbo.listings
group by neighbourhood
order by avg_price desc
-- The area nearby the distillery district and studio district looks like has the avg higher price 

-- Number of listings and average price by Room Type
select
  room_type,
  count(id) as no_listings,
  avg(price) as avg_price
from
  [Portfolio Project].dbo.listings
group by
  room_type
order by
  avg(price) desc
 -- So the entire home/apartment have higher avg prices which implies hence the higher prices in specific areas due to the nature of customer traffic in that area

 -- Looking at the number of beds by the neighbourhood
 SELECT 
  a.neighbourhood,
  sum(a.price)/sum(b.beds) as price_per_bed
FROM
  [Portfolio Project].dbo.listings a INNER JOIN [Portfolio Project].dbo.listings_detail b 
  ON a.id = b.id  
group by
  a.neighbourhood
order by
  price_per_bed desc
-- Based on this the top 3 charge the higher price per bed in high traffic and busy areas due to main amenities and attractions nearby

-- Looking at the number of Airbnbs per neighbourhood
SELECT TOP 10 neighbourhood, COUNT (id) AS number_of_airbnb
  FROM [Portfolio Project].dbo.listings
  GROUP BY neighbourhood, neighbourhood_group
  HAVING COUNT (id) >= 160
  ORDER BY number_of_airbnb desc;
-- The Waterfront area have the highest number of Airbnbs probably because of the attractions and amenities while also its facing the lake

-- Looking at neighbourhoods with highest revenue potential
-- I will be measuring potential with availability 30, the assumption here is that more than 30 days (before 2022-01-01) is too far away for people to book Airbnb
-- Availability being 0 also means that the host simply blocked the calendar (selecting the ones that have been reviewed in the past 6 months)

SELECT
  a.neighbourhood,
  sum(a.price * (30 - b.availability_30)) as potential_30
FROM 
  [Portfolio Project].dbo.listings a
  INNER JOIN
  [Portfolio Project].dbo.listings_detail b
  on 
  a.id = b.id
where 
  a.last_review >= 2022-01-01
group by
  a.neighbourhood
order by
  potential_30 desc

--I would like to take a closer look at this table here - what about potential by neighbourhood and room type?
-- so basically, I would like to pivot the table, and turn the rows into room types, with the values being "potential"
-- looking at the different room types, there is apparently a flaw in the data, but it's too small to be relevant

SELECT
  listings.neighbourhood,
  sum(listings.price * (30 - listings_detail.availability_30)) as potential_30,
  listings.room_type
FROM
  [Portfolio Project].dbo.listings [listings]
  INNER JOIN
  [Portfolio Project].dbo.listings_detail [listings_detail]
  ON 
  listings.id = listings_detail.id
WHERE 
  listings.last_review >= 2022-01-01
GROUP BY
  listings.neighbourhood,
  listings.room_type
order by
  potential_30 desc
-- Looks like the Waterfront and Niagara area have the highest revenue potential and interestingly people book the entire apartments/homes and there are very few bookings for a private room

-- Number of superhosts/non-superhosts in Toronto
SELECT DISTINCT(host_is_superhost) FROM [Portfolio Project].dbo.listings_detail; 

SELECT 
  count(case when host_is_superhost = 't' then id end) as Superhost,
  count(case when host_is_superhost = 'f' then id end) as Regular
FROM
  [Portfolio Project].dbo.listings_detail
-- 3,519 Superhosts and 12,515 Regular hosts

-- Looking at no. of superhosts/hosts by neighbourhood
SELECT 
  listings.neighbourhood,
  count(case when listings_detail.host_is_superhost = 't' then listings_detail.id end) as Superhost,
  count(case when listings_detail.host_is_superhost = 'f' then listings_detail.id end) as Regular
from
  [Portfolio Project].dbo.listings_detail [listings_detail]
  inner join
  [Portfolio Project].dbo.listings [listings]
  on listings_detail.id = listings.id
where
  listings.last_review >= 2022-01-01
group by
  listings.neighbourhood
order by 
	Superhost desc
-- Waterfront and Trinity Bellwoods have the highest number of superhosts


-- Looking into correlation between superhost status and price
SELECT
  avg(case when listings_detail.host_is_superhost = 't' then listings.price end) as superhost_avg_price,
  avg(case when listings_detail.host_is_superhost = 'f' then listings.price end) as regular_avg_price
FROM
  [Portfolio Project].dbo.listings [listings]
  inner join
  [Portfolio Project].dbo.listings_detail [listings_detail]
  on
  listings.id = listings_detail.id
WHERE
  listings.last_review >= 2022-01-01

-- Not much of a difference between the superhost and regular host avg price (187.81 vs 187.19)

-- Looking at superhosts pricing by neighbourhood
SELECT
listings.neighbourhood,
  avg(case when listings_detail.host_is_superhost = 't' then listings.price end) as superhost_avg_price,
  avg(case when listings_detail.host_is_superhost = 'f' then listings.price end) as regular_avg_price
FROM
  [Portfolio Project].dbo.listings [listings]
  INNER JOIN
  [Portfolio Project].dbo.listings_detail [listings_detail]
  on
  listings.id = listings_detail.id
WHERE
  listings.last_review >= 2022-01-01
GROUP BY 
	listings.neighbourhood
ORDER BY
	superhost_avg_price desc

-- Looking at the price per bed charged by superhosts
SELECT
listings.neighbourhood,
  avg(case when listings_detail.host_is_superhost = 't' then listings.price/listings_detail.beds end) as superhost_avg_price_per_bed,
  avg(case when listings_detail.host_is_superhost = 'f' then listings.price/listings_detail.beds end) as regular_avg_price_per_bed
FROM
  [Portfolio Project].dbo.listings [listings]
  INNER JOIN
  [Portfolio Project].dbo.listings_detail [listings_detail]
  on
  listings.id = listings_detail.id
WHERE
  listings.last_review >= 2022-01-01
GROUP BY
	listings.neighbourhood
ORDER BY
	superhost_avg_price_per_bed desc
-- Looks like the top areas charging higher price and price per bed are the Waterfront, Niagara and Casa Loma area which makes sense

--Next, let's look at ratings for superhosts vs regular hosts - what are superhosts doing right?
SELECT 
  case when host_is_superhost = 't' then 'Superhost' end as Superhost,
  case when host_is_superhost = 'f' then 'Regular' end as Regular,
  avg(review_scores_rating) as avg_rating,
  avg(review_scores_accuracy) as avg_rating_accuracy,
  avg(review_scores_cleanliness) as avg_rating_cleanliness,
  avg(review_scores_checkin) as avg_rating_checkin,
  avg(review_scores_communication) as avg_rating_comm,
  avg(review_scores_location) as avg_rating_location
FROM
  [Portfolio Project].dbo.listings_detail [listings_detail]
  INNER JOIN
  [Portfolio Project].dbo.listings [listings]
  ON
  listings_detail.id = listings.id
WHERE
  listings.last_review >= 2022-01-01
GROUP BY
  host_is_superhost

-- looking at the relationship between instant book and revenue potential

SELECT DISTINCT(instant_bookable) FROM [Portfolio Project].dbo.listings_detail;

SELECT
  avg(case when listings_detail.instant_bookable = 't' then listings.price * (30 - listings_detail.availability_30) end) as instantbook_potential,
  avg(case when listings_detail.instant_bookable = 'f' then listings.price * (30 - listings_detail.availability_30) end) as regular_potential
FROM
  [Portfolio Project].dbo.listings_detail [listings_detail]
  INNER JOIN
  [Portfolio Project].dbo.listings [listings]
  ON
  listings_detail.id = listings.id
WHERE
  listings.last_review >= 2022-01-01
-- Interesting to see as per Airbnb's claim that instant bookings increased revenue earnings but in actuality the regular bookings have higher revenue potential earnings


-- let's look at price and availability_30 separately

SELECT
  avg(case when listings_detail.instant_bookable = 't' then listings.price end) as instantbook_avg_price,
  avg(case when listings_detail.instant_bookable = 'f' then listings.price end) as regular_avg_price
FROM
  [Portfolio Project].dbo.listings_detail [listings_detail]
  INNER JOIN
  [Portfolio Project].dbo.listings [listings]
  ON
  listings_detail.id = listings.id
WHERE
  listings.last_review >= 2022-01-01
-- Avg price for instant booking is actually lower compared to regular avg price

-- checking to see if instant bookings are available more compared to regular bookings
SELECT
  avg(case when instant_bookable = 't' then availability_30 end) as instantbook_avail,
  avg(case when instant_bookable = 'f' then availability_30 end) as regular_avail
FROM
  [Portfolio Project].dbo.listings_detail [listings_detail]
  INNER JOIN
  [Portfolio Project].dbo.listings [listings]
  ON
  listings_detail.id = listings.id
WHERE
  listings.last_review >= 2022-01-01
-- Interesting to see that instant bookings are more available, which means they could be getting less reservations
-- Hosts which offer instant bookings charge a lower price on avg and perhaps if they charge an extra for that convenience that can increase their revenue potential
