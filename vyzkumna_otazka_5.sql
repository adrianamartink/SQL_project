-- Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

-- Creating view for average payroll per year
CREATE 
OR REPLACE VIEW v_avg_payroll AS 
SELECT 
  payroll_year, 
  ROUND(
    avg(value), 
    2
  ) AS avg_payroll 
FROM 
  (
    SELECT 
      * 
    FROM 
      czechia_payroll as cp 
      LEFT JOIN czechia_payroll_value_type as cpvt ON cpvt.code = value_type_code 
    WHERE 
      cp.value IS NOT NULL 
      AND payroll_year IS NOT NULL 
      AND value_type_code = 5958
  ) as vp 
GROUP BY 
  payroll_year;

-- calculating payroll change between years
 
CREATE OR REPLACE VIEW v_percentage_change_payroll AS 
SELECT 
    payroll_year,
    avg_payroll,
    LAG(avg_payroll) OVER (ORDER BY payroll_year) AS previous_avg_payroll,
    ROUND(((avg_payroll/LAG(avg_payroll) OVER (ORDER BY payroll_year))-1)*100,2) AS payroll_percentage_change
FROM v_avg_payroll;

-- calculating percentage change in payroll

CREATE OR REPLACE VIEW v_percentage_change_payroll AS 
SELECT 
    payroll_year,
    avg_payroll,
    LAG(avg_payroll) OVER (ORDER BY payroll_year) AS previous_avg_payroll,
    ROUND(((avg_payroll/LAG(avg_payroll) OVER (ORDER BY payroll_year))-1)*100,2) AS payroll_percentage_change
FROM v_avg_payroll;

-- calculating average prices of products in a given year

CREATE OR REPLACE VIEW v_avg_price_all_products_per_year AS
SELECT
	year(date_from) AS year_sth,
	ROUND(avg(value),2) AS avg_price_of_all_products_per_year
FROM czechia_price as cp 
GROUP BY year(date_from);

-- calculation of percentage change of prices of products
CREATE OR REPLACE VIEW v_percentage_change_avg_prices_all_goods AS 
SELECT 
	year_sth,
	avg_price_of_all_products_per_year,
	LAG(avg_price_of_all_products_per_year) OVER (ORDER BY year_sth) AS previous_avg_price,
	ROUND(((avg_price_of_all_products_per_year/LAG(avg_price_of_all_products_per_year) OVER (ORDER BY year_sth)) - 1)*100,2) AS percentage_change_prices
FROM v_avg_price_all_products_per_year as vapappy;

-- creating final view combined with gdp, payroll and prices
CREATE OR REPLACE VIEW v_gdp_payroll_prices AS 
SELECT 
	YEAR, 
	ROUND(gdp/population,2) AS GDP_per_capita,
	LAG(ROUND(gdp/population,2)) OVER (ORDER BY YEAR) AS previous_gdp_per_capita,
	ROUND((ROUND(gdp/population,2)/LAG(ROUND(gdp/population,2)) OVER (ORDER BY YEAR)-1)*100,2) AS percentage_change_gdp_per_capita,
	vpcp.avg_payroll, vpcp.payroll_percentage_change,
	vapappy.avg_price_of_all_products_per_year,
	vapappy.percentage_change_prices 
FROM economies as e 
INNER JOIN v_percentage_change_payroll as vpcp ON
vpcp.payroll_year = e.`year` 
INNER JOIN v_percentage_change_avg_prices_all_goods as vapappy ON
vapappy.year_sth = e.`year` 
WHERE country = 'Czech Republic'
ORDER BY year;

-- final select statement with percentage change of GDP per capita, payroll and prices
SELECT 
	YEAR,
	percentage_change_gdp_per_capita,
	payroll_percentage_change,
	percentage_change_prices 
FROM v_gdp_payroll_prices as vgpp;