-- Where should we focus care programs?
--Targets populations performing below average

WITH overall_avg AS (
    SELECT avg(rate) AS avg_rate
    FROM Healthdisparities
    WHERE measurement_year = 2024
        AND rate IS NOT NULL
)
SELECT 
    payer,
    category
    characteristics,
    AVG(rate) AS avg_rate
FROM Healthdisparities
CROSS JOIN overall_avg o
WHERE measurement_year = 2024
    AND rate IS NOT NULL
GROUP BY 
    payer,
    category,
    characteristics,
    avg_rate
HAVING AVG(rate) < avg_rate
ORDER BY avg_rate ASC;


--Which payer needs equity intervention?
--Focus on payer with largest inequality

WITH disparity AS (
    SELECT 
        payer,
        MAX(rate) AS max_rate,
        MIN(rate) AS min_rate
    FROM Healthdisparities
    WHERE measurement_year = 2024
        AND rate IS NOT NULL
    GROUP BY payer
)
SELECT 
    payer,
    max_rate,
    min_rate,
    max_rate - min_rate AS disparity_gap
FROM disparity
ORDER BY disparity_gap DESC;



--Who should we model best practices after?
--Identify benchmark payer

SELECT TOP 1
    payer,
    AVG(rate) AS avg_rate
FROM Healthdisparities
WHERE measurement_year = 2024
    AND rate IS NOT NULL
GROUP BY payer
ORDER BY avg_rate DESC;


--Where should we allocate resources?
--categories with lowest performance = priority areas


SELECT 
    category,
    payer,
    AVG(rate) AS avg_rate
FROM Healthdisparities
WHERE measurement_year = 2024
    AND rate IS NOT NULL
GROUP BY category , payer
ORDER BY avg_rate ASC;


--Which payer is most reliable?

SELECT 
    payer,
    STDEV(rate) AS variability
FROM Healthdisparities
WHERE measurement_year = 2024
    AND rate IS NOT NULL
GROUP BY payer
ORDER BY variability DESC;

