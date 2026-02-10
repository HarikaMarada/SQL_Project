CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;
-- 1. country table
CREATE TABLE country (
CID VARCHAR(10) PRIMARY KEY,
Country VARCHAR(100) UNIQUE
);
SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE emission_3 (
country VARCHAR(100),
energy_type VARCHAR(50),
year INT,
emission INT,
per_capita_emission DOUBLE,
FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM EMISSION_3;

-- 3. population table
CREATE TABLE population (
countries VARCHAR(100),
year INT,
Value DOUBLE,
FOREIGN KEY (countries) REFERENCES country(Country)
);
SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
country VARCHAR(100),
energy VARCHAR(50),
year INT,
production INT,
FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
Country VARCHAR(100),
year INT,
Value DOUBLE,
FOREIGN KEY (Country) REFERENCES country(Country)
);
SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
country VARCHAR(100),
energy VARCHAR(50),
year INT,
consumption INT,
FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM consumption;

-- General & Comparative Analysis
-- What is the total emission per country for the most recent year available? 
select country,
sum(emission) as total_emission,year
from emission_3
where year=(select max(year) from emission_3)
group by country,year;

-- What are the top 5 countries by GDP in the most recent year?
select * from gdp_3
limit 5;

-- Compare energy production and consumption by country and year.
SELECT p.country,p.energy,p.year,p.production,c.consumption,
(p.production - c.consumption) AS difference
FROM production p
JOIN consumption c
ON p.country = c.country
AND p.energy = c.energy
AND p.year = c.year
ORDER BY p.country, p.year, p.energy;

-- Which energy types contribute most to emissions across all countries?
SELECT energy_type,
SUM(emission) AS total_emission
FROM emission_3
GROUP BY energy_type
ORDER BY total_emission DESC;

-- Trend Analysis Over Time
-- How have global emissions changed year over year?
SELECT year,
SUM(emission) AS total_global_emission
FROM emission_3
GROUP BY year
ORDER BY year;

-- What is the trend in GDP for each country over the given years?
select country,year,
value as GDP
from gdp_3
order by year,country;

-- How has population growth affected total emissions in each country?
SELECT p.countries AS country,p.year,p.Value AS population,e.total_emission,
(e.total_emission / p.Value) AS emission_per_person -- mean(avg)=sum/count
FROM population p
JOIN 
(
SELECT country,year,
SUM(emission) AS total_emission
FROM emission_3
GROUP BY country, year
) e
ON p.countries = e.country AND p.year = e.year 
ORDER BY country, year;

-- Has energy consumption increased or decreased over the years for major economies?
SELECT country,year,
SUM(consumption) AS total_consumption
FROM consumption
GROUP BY country, year
ORDER BY country, year;

-- What is the average yearly change in emissions per capita for each country?
WITH yearly_per_capita AS (
SELECT country,year,
SUM(per_capita_emission) AS total_per_capita
FROM emission_3
GROUP BY country, year
),
yearly_change AS (
SELECT country,year,total_per_capita,total_per_capita- LAG(total_per_capita) OVER (PARTITION BY country ORDER BY year) AS yoy_change
FROM yearly_per_capita
)
SELECt country,
ROUND(AVG(yoy_change), 4) AS avg_yearly_change_per_capita
FROM yearly_change
WHERE yoy_change IS NOT NULL
GROUP BY country
ORDER BY avg_yearly_change_per_capita DESC;

-- Ratio & Per Capita Analysis
-- What is the emission-to-GDP ratio for each country by year?
WITH total_emission AS (
SELECT
country,year,
SUM(emission) AS total_emission
FROM emission_3
GROUP BY country, year
)
SELECT e.country,e.year,e.total_emission,g.Value AS gdp,
(e.total_emission / g.Value) AS emission_to_gdp_ratio
FROM total_emission e
JOIN gdp_3 g
ON e.country = g.Country
AND e.year = g.year
ORDER BY e.country, e.year;

-- What is the energy consumption per capita for each country over the last decade?
WITH total_consumption AS (
SELECT country,year,
SUM(consumption) AS total_consumption
FROM consumption
GROUP BY country, year
),
last_decade AS (
SELECT MAX(year) - 10 AS start_year
FROM consumption
)
SELECT c.country,c.year,c.total_consumption,p.Value AS population,
(c.total_consumption / p.Value) AS consumption_per_capita
FROM total_consumption c
JOIN population p
ON c.country = p.countries
AND c.year = p.year
JOIN last_decade d
ON c.year >= d.start_year
ORDER BY c.country, c.year;

-- How does energy production per capita vary across countries?
WITH total_production AS (
SELECT country,year,
SUM(production) AS total_production
FROM production
GROUP BY country, year
)
SELECT p.country,p.year,p.total_production,pop.Value AS population,
(p.total_production / pop.Value) AS production_per_capita
FROM total_production p
JOIN population pop
ON p.country = pop.countries
AND p.year = pop.year
ORDER BY p.country, p.year;

-- Which countries have the highest energy consumption relative to GDP?
WITH total_consumption AS (
SELECT country,year,
SUM(consumption) AS total_consumption
FROM consumption
GROUP BY country, year
)
SELECT c.country,c.year,c.total_consumption,g.Value AS gdp,
(c.total_consumption / g.Value) AS consumption_to_gdp_ratio
FROM total_consumption c
JOIN gdp_3 g
ON c.country = g.Country
AND c.year = g.year
ORDER BY consumption_to_gdp_ratio DESC;

-- What is the correlation between GDP growth and energy production growth?
WITH pop_latest AS (
SELECT countries AS country,year,Value AS population,
ROW_NUMBER() OVER (PARTITION BY countries ORDER BY year DESC) AS rn
FROM population
),

pop_top10 AS (
SELECT country, population
FROM pop_latest
WHERE rn = 1        -- latest population for each country
ORDER BY population DESC
LIMIT 10            -- top 10 populated countries
),

emissions_latest AS (
SELECT country,year,
SUM(emission) AS total_emission,
ROW_NUMBER() OVER (PARTITION BY country ORDER BY year DESC) AS rn
FROM emission_3
GROUP BY country, year
)

SELECT p.country,p.population,e.total_emission
FROM pop_top10 p
LEFT JOIN emissions_latest e
ON p.country = e.country
AND e.rn = 1             -- latest emission year
ORDER BY p.population DESC;

-- Global Comparisons
-- What are the top 10 countries by population and how do their emissions compare?
with cte_1 as (SELECT countries, max(`value`) as pop FROM energydb2.population
group by countries
order by pop desc
limit 10),
cte_2 as (select countries from cte_1)

select country, max(emission)
from emission_3 where country in (select * from cte_2)
group by country;

-- Which countries have improved (reduced) their per capita emissions the most over the last decade?
WITH percap_start AS (
SELECT country,per_capita_emission AS start_pce,year,
ROW_NUMBER() OVER (PARTITION BY country ORDER BY year) AS rn
FROM emission_3
),

percap_end AS (
SELECT country,per_capita_emission AS end_pce,year,
ROW_NUMBER() OVER (PARTITION BY country ORDER BY year DESC) AS rn
FROM emission_3
),

start_final AS (
SELECT country, start_pce
FROM percap_start
WHERE rn = 1
),

end_final AS (
SELECT country, end_pce
FROM percap_end
WHERE rn = 1
)

SELECT s.country,s.start_pce AS per_capita_start,e.end_pce   AS per_capita_end,
(s.start_pce - e.end_pce) AS reduction_in_per_capita
FROM start_final s
JOIN end_final e ON s.country = e.country
WHERE (s.start_pce - e.end_pce) > 0
ORDER BY reduction_in_per_capita DESC;

-- What is the global share (%) of emissions by country?
WITH total_emission_country AS (
SELECT country,
SUM(emission) AS country_total_emission
FROM emission_3
GROUP BY country
),

global_total AS (
SELECT 
SUM(emission) AS global_emission
FROM emission_3
)

SELECT c.country,c.country_total_emission,
ROUND((c.country_total_emission / g.global_emission) * 100, 2) AS emission_share_percent
FROM total_emission_country c
CROSS JOIN global_total g
ORDER BY emission_share_percent DESC;

-- What is the global average GDP, emission, and population by year?
-- 1. Average GDP per year
WITH gdp_yearly AS (
SELECT year,AVG(Value) AS avg_gdp
FROM gdp_3
GROUP BY year
),

-- 2. Total Emission per country per year → then average globally
emission_yearly AS (
SELECT year,
AVG(total_emission) AS avg_emission
FROM (
SELECT country,year,
SUM(emission) AS total_emission
FROM emission_3
GROUP BY country, year
    ) AS emissions_by_country
GROUP BY year
),

-- 3. Average Population per year
population_yearly AS (
SELECT year,AVG(Value) AS avg_population
FROM population
GROUP BY year
)

-- Final Combine
SELECT g.year,g.avg_gdp,e.avg_emission,p.avg_population
FROM gdp_yearly g
LEFT JOIN emission_yearly e ON g.year = e.year
LEFT JOIN population_yearly p ON g.year = p.year
ORDER BY g.year; 












