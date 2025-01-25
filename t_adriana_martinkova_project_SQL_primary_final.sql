-- Skript vytváří tabulku, která kombinuje data o cenách a platech pomocí UNION ALL.
-- Sloupce, které mezi tabulkami nesedí, jsou vyplněné jako NULL.

-- UPOZORNĚNÍ: Spojovat tyto dvě tabulky (czechia_price a czechia_payroll) moc nedává smysl, 
-- protože jde o úplně jiný typ dat – ceny a platy spolu na této úrovni nesouvisí.

-- Výsledná tabulka je tak jen "na oko" pro splnění zadání (jak bylo schváleno lektorem na Discordu)
-- Výzkumné otázky jdou bez problémů zodpovědět na datech z původních tabulek.

CREATE OR REPLACE TABLE t_adriana_martinkova_project_SQL_primary_final AS
SELECT 
    YEAR(date_from) AS year,
    AVG(value) AS avg_value,
    category_code AS category_code,
    NULL AS industry_branch_code
FROM czechia_price
WHERE category_code IS NOT NULL AND value IS NOT NULL
GROUP BY YEAR(date_from), category_code

UNION ALL

SELECT 
    payroll_year AS year,
    AVG(value) AS avg_value,
    NULL AS category_code,
    industry_branch_code AS industry_branch_code
FROM czechia_payroll
WHERE value_type_code = '5958' AND industry_branch_code IS NOT NULL AND value IS NOT NULL
GROUP BY payroll_year, industry_branch_code;
