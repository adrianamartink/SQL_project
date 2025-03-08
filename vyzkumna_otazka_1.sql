-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- Creating view to display avg payroll values per industry branch per year
CREATE OR REPLACE VIEW v_avg_industry_payroll_per_year AS 
SELECT name, payroll_year, AVG(value) AS avg_pay
FROM czechia_payroll as cp
LEFT JOIN czechia_payroll_industry_branch as cpib ON 
cpib.code = cp.industry_branch_code 
WHERE industry_branch_code IS NOT NULL AND value IS NOT NULL
GROUP BY industry_branch_code, payroll_year; 

-- Creating view to display if value for given year increased or decreased compared to the previous year
CREATE OR REPLACE VIEW v_payroll_trend AS 
SELECT 
    name,
    payroll_year,
    avg_pay,
    LAG(avg_pay) OVER (PARTITION BY name ORDER BY payroll_year) AS previous_value,
    CASE
    	WHEN avg_pay > LAG(avg_pay) OVER (PARTITION BY name ORDER BY payroll_year) THEN 'Increasing'
    	WHEN avg_pay < LAG(avg_pay) OVER (PARTITION BY name ORDER BY payroll_year) THEN 'Decreasing'
    	ELSE 'no change'
    END AS trend
FROM v_avg_industry_payroll_per_year as vaippy
ORDER BY name, payroll_year;

-- Final select that will provide counts how many years the payroll increased or decreased for given industry branch 
SELECT 
    name AS payroll_industry, 
    COUNT(CASE WHEN trend = 'Decreasing' THEN 1 END) AS decreasing_count,
    COUNT(CASE WHEN trend = 'Increasing' THEN 1 END) AS increasing_count
FROM 
    v_payroll_trend
GROUP BY 
    name
HAVING COUNT(CASE WHEN trend = 'Decreasing' THEN 1 END) > 0;

-- Optional - Display which industries are always increasing their payrolls
-- SELECT 
--     name, 
--     CASE
--     	WHEN COUNT(CASE WHEN trend = 'Decreasing' THEN 1 END) > 0 THEN 'False'
--     	ELSE 'True'
--     END always_increasing
-- FROM 
--     v_payroll_trend
-- GROUP BY 
--     name
-- HAVING COUNT(CASE WHEN trend = 'Decreasing' THEN 1 END) > 0;
