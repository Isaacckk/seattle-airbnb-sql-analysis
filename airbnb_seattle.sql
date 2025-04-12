-- Table creation and data exportation ==========================
-- Create listings table and upload csv file
CREATE TABLE listings (
    id INTEGER PRIMARY KEY,
    name TEXT,
    host_id INTEGER,
    host_name TEXT,
    neighbourhood_group TEXT,
    neighbourhood TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    room_type TEXT,
    price INTEGER,
    minimum_nights INTEGER,
    number_of_reviews INTEGER,
    last_review DATE,
    reviews_per_month DOUBLE PRECISION,
    calculated_host_listings_count INTEGER,
    availability_365 INTEGER
);

-- Create neighborhoods table and upload csv file
CREATE TABLE neighborhoods (
    neighborhood_id SERIAL PRIMARY KEY,
    neighbourhood TEXT,
    neighbourhood_group TEXT
);

-- Add foreign key column
ALTER TABLE listings
ADD COLUMN neighborhood_id INTEGER;

-- Update with matching neighborhood_id
UPDATE listings
SET neighborhood_id = n.neighborhood_id
FROM neighborhoods n
WHERE listings.neighbourhood = n.neighbourhood
  AND listings.neighbourhood_group = n.neighbourhood_group;

-- Optional: Add the foreign key constraint
ALTER TABLE listings
ADD CONSTRAINT fk_neighborhood
FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(neighborhood_id);

-- Sanity check
SELECT l.id, l.name, l.neighbourhood, l.neighbourhood_group, n.neighborhood_id
FROM listings l
JOIN neighborhoods n ON l.neighborhood_id = n.neighborhood_id
LIMIT 10;

-- Data Anaylysis Queries (Price-based) ==========================
-- Listings by neighborhood group
SELECT neighbourhood_group, COUNT(*) AS num_listings
FROM listings
GROUP BY neighbourhood_group
ORDER BY num_listings DESC;

-- Listings by neighborhood
SELECT neighbourhood, COUNT(*) AS num_listings
FROM listings
GROUP BY neighbourhood
ORDER BY num_listings DESC;

-- Ave Price by neighborhood group
SELECT neighbourhood_group, AVG(price) AS avg_price
FROM listings
GROUP BY neighbourhood_group
ORDER BY avg_price DESC;

-- Price statistics by neighborhood
SELECT neighbourhood,
       MIN(price) AS min_price,
       MAX(price) AS max_price,
       ROUND(AVG(price), 2) AS avg_price
FROM listings
GROUP BY neighbourhood
ORDER BY avg_price DESC;

-- Top 5 most expensive listings (Excluding null prices)
SELECT id, name, price, neighbourhood
FROM listings
WHERE price IS NOT NULL
ORDER BY price DESC
LIMIT 5;

-- Availability vs Price per neighborhood
SELECT neighbourhood,
       ROUND(AVG(price), 2) AS avg_price,
       ROUND(AVG(availability_365), 2) AS avg_availability
FROM listings
GROUP BY neighbourhood
ORDER BY avg_availability DESC;

-- Top 5 Neighborhoods with most listings
SELECT neighbourhood, COUNT(*) AS num_listings
FROM listings
WHERE neighbourhood IS NOT NULL AND neighbourhood <> ''
GROUP BY neighbourhood
ORDER BY num_listings DESC
LIMIT 5;

-- Ave price per room type
SELECT room_type, 
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price
FROM listings
WHERE price IS NOT NULL
GROUP BY room_type
ORDER BY avg_price DESC;

-- Ave price by minimum nights
SELECT minimum_nights,
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price,
       COUNT(*) AS num_listings
FROM listings
WHERE price IS NOT NULL AND minimum_nights BETWEEN 1 AND 30
GROUP BY minimum_nights
ORDER BY minimum_nights;

-- Pearson Correlation
SELECT CORR(minimum_nights::NUMERIC, price::NUMERIC) AS correlation
FROM listings
WHERE price IS NOT NULL AND minimum_nights BETWEEN 1 AND 30;

-- Data Anaylysis Queries (Review-based) ==========================
--Ave review per month by neighborhood
SELECT neighbourhood, 
       ROUND(AVG(reviews_per_month)::NUMERIC, 2) AS avg_reviews_per_month
FROM listings
WHERE reviews_per_month IS NOT NULL
GROUP BY neighbourhood
ORDER BY avg_reviews_per_month DESC
LIMIT 10;

-- Total reviews by neighborhood group
SELECT neighbourhood_group, 
       SUM(number_of_reviews) AS total_reviews
FROM listings
GROUP BY neighbourhood_group
ORDER BY total_reviews DESC;

-- Top 5 most reviewed listings
SELECT id, name, neighbourhood, number_of_reviews
FROM listings
WHERE number_of_reviews IS NOT NULL
ORDER BY number_of_reviews DESC
LIMIT 5;



SELECT number_of_reviews,
       ROUND(AVG(price)::NUMERIC, 2) AS avg_price
FROM listings
WHERE price IS NOT NULL AND number_of_reviews > 0
GROUP BY number_of_reviews
ORDER BY number_of_reviews DESC;







