-- Vytváření další tabulky pro ostatní země nedává smysl, protože se dají použít již přímo data z tabulky economies
-- Jediné záznamny, které můžeme reálně využít jsou ty pro Czech republic, protože pro ostatní země nemáme žádná data pro payroll nebo prices

CREATE TABLE t_adriana_martinkova_project_SQL_secondary_final
SELECT * FROM engeto.economies
WHERE country = 'Czech republic'