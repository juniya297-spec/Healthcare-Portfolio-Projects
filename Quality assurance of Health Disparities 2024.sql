SELECT *
FROM Portfolioproject..HealthDisparities


--Top 5 Health Disparity Gaps for 2024

SELECT TOP 5 
	measure_description,
	payer,
	category,
	characteristics,
	TRY_CAST (rate AS Float) AS rate,
	(MAX(TRY_CAST(rate AS Float)) OVER (PARTITION BY measure_description)-TRY_CAST(rate AS Float)) AS disparity_gap
FROM HealthDisparities
WHERE measurement_year='2024'
AND TRY_CAST(rate AS Float) IS NOT NULL
ORDER BY disparity_gap DESC;



--Identifies Best in Class benchmarks to see what is possible for other groups to acheive


WITH DomainAverages AS (
	-- Calculate average rate per characteristic within each domain
SELECT
	domain,
	characteristics,
	AVG(TRY_CAST(rate AS FLOAT)) AS avg_group_rate
	FROM HealthDisparities
	WHERE measurement_year ='2024'
	GROUP BY domain, characteristics
	),
	BestinDomain AS (
		-- Find the top performing average for each domain
SELECT
	domain,
	MAX(avg_group_rate) AS top_rate
FROM DomainAverages
Group BY domain
)
SELECT
	da.domain,
	da.characteristics AS top_performing_group,
	da.avg_group_rate
FROM DomainAverages da
JOIN BestinDomain bd ON da.domain= bd.domain AND da.avg_group_rate= bd.top_rate
ORDER BY da.avg_group_rate DESC;





--Total Patients impacted by "Low-Performing" rates (below 50%) across different payers
WITH aggregated_data AS (
    SELECT 
        measurement_year,
        measure,
        characteristics,
        AVG(rate) AS avg_rate
    FROM Healthdisparities
	 WHERE 
        rate IS NOT NULL
        AND measurement_year IS NOT NULL
        AND measure IS NOT NULL
        AND characteristics IS NOT NULL
    GROUP BY measurement_year, measure, characteristics
)
SELECT 
    measurement_year,
    measure,
    characteristics,
    avg_rate,
    LAG(avg_rate) OVER (
        PARTITION BY measure, characteristics 
        ORDER BY measurement_year
    ) AS prev_year_rate,
    avg_rate - LAG(avg_rate) OVER (
        PARTITION BY measure, characteristics 
        ORDER BY measurement_year
    ) AS rate_change
FROM aggregated_data;

--Identify where disparities originate
SELECT 
    domain,
    sub_domain,
    characteristics,
    AVG(rate) AS avg_rate
FROM HealthDisparities
GROUP BY domain, sub_domain, characteristics
ORDER BY avg_rate DESC;


-- measures that shows the biggest improvement opportunity

SELECT 
    measure,
    MAX(rate) - MIN(rate) AS variation_range
FROM HealthDisparities
GROUP BY measure
ORDER BY variation_range DESC;



--Shows which domains drive poor outcomes.

SELECT 
    domain,
    AVG(rate) AS avg_rate,
    SUM(numerator) AS total_cases
FROM HealthDisparities
GROUP BY domain
ORDER BY avg_rate DESC;