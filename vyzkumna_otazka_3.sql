-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

-- Get avg value for product category per year
CREATE 
OR REPLACE VIEW V_avg_price_of_goods_per_year AS 
SELECT 
  name AS product_category, 
  YEAR(date_from) AS year_of_price, 
  ROUND(
    avg(value), 
    2
  ) AS avg_value 
FROM 
  czechia_price as cp 
  LEFT JOIN czechia_price_category as cpc ON cpc.code = cp.category_code 
GROUP BY 
  name, 
  year(date_from);

-- Calculate percentage increase between years for given products
CREATE 
OR REPLACE VIEW v_percentage_change_of_price_of_goods AS 
SELECT 
  product_category, 
  year_of_price, 
  avg_value, 
  LAG(avg_value) OVER (
    PARTITION BY product_category 
    ORDER BY 
      year_of_price
  ) AS previous_value, 
  ROUND(
    (
      avg_value /(
        LAG(avg_value) OVER (
          PARTITION BY product_category 
          ORDER BY 
            year_of_price
        )
      ) -1
    ) * 100, 
    2
  ) AS price_change_percentage 
FROM 
  v_avg_price_of_goods_per_year as vapogpy;
  
-- Calculate avg percentage increase among all available years
SELECT 
  product_category, 
  ROUND(
    AVG(price_change_percentage), 
    2
  ) AS avg_percentage_change 
FROM 
  v_percentage_change_of_price_of_goods as vpcopog 
GROUP BY 
  product_category 
ORDER BY 
  ROUND(
    AVG(price_change_percentage), 
    2
  );
