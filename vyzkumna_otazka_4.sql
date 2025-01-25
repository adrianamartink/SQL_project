-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

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

-- getting overall average prices of products between years

CREATE OR REPLACE VIEW v_avg_price_all_products_per_year AS
SELECT
	year(date_from) AS year_sth,
	ROUND(avg(value),2) AS avg_price_of_all_products_per_year
FROM czechia_price as cp 
GROUP BY year(date_from);

-- calculating percentage change in average prices
CREATE OR REPLACE VIEW v_percentage_change_avg_prices_all_goods AS 
SELECT 
	year_sth,
	avg_price_of_all_products_per_year,
	LAG(avg_price_of_all_products_per_year) OVER (ORDER BY year_sth) AS previous_avg_price,
	ROUND(((avg_price_of_all_products_per_year/LAG(avg_price_of_all_products_per_year) OVER (ORDER BY year_sth)) - 1)*100,2) AS percentage_change_prices
FROM v_avg_price_all_products_per_year as vapappy;

-- combining view tables and evaluating if prices increase or decrease
SELECT 
    vpcp.payroll_year,
    vpcp.payroll_percentage_change,
    vpcapag.percentage_change_prices,
    CASE 
        WHEN vpcapag.percentage_change_prices - vpcp.payroll_percentage_change >= 10 THEN 'high increase'
        WHEN vpcapag.percentage_change_prices - vpcp.payroll_percentage_change > 0 THEN 'increase'
        ELSE 'decrease or no change'
    END AS rate_relative_goods_prices
FROM 
    v_percentage_change_payroll AS vpcp
JOIN 
    v_percentage_change_avg_prices_all_goods AS vpcapag 
ON 
    vpcapag.year_sth = vpcp.payroll_year;