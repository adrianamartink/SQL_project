-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

-- Creating view to see only values of milk and bread
CREATE 
OR REPLACE VIEW v_milk_bread AS 
SELECT 
  name, 
  value, 
  price_value, 
  price_unit, 
  YEAR(date_from) AS year_of_price 
FROM 
  czechia_price as cp 
  LEFT JOIN czechia_price_category as cpc ON cpc.code = cp.category_code 
WHERE 
  code IN (114201, 111301);

-- Creating view thatwith average prices of selected products per year
CREATE 
OR REPLACE VIEW v_avg_price_of_milk_bread AS 
SELECT 
  name, 
  ROUND(
    avg(value), 
    2
  ) AS avg_price, 
  year_of_price 
FROM 
  v_milk_bread as vmb 
GROUP BY 
  name, 
  year_of_price;

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

-- Joining prices and payroll together and calculating number of units we can buy for average payroll
SELECT 
  payroll_year, 
  name AS product_name, 
  avg_price, 
  avg_payroll, 
  ROUND(
    (avg_payroll / avg_price), 
    2
  ) AS units_of_products_for_avg_payroll 
FROM 
  v_avg_payroll as vap 
  JOIN v_avg_price_of_milk_bread as vapomb ON vapomb.year_of_price = vap.payroll_year 
ORDER BY 
  name, 
  payroll_year;
