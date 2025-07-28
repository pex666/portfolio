WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),
filtered_id AS(
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
    ),
published AS (
	SELECT EXTRACT(MONTH FROM first_day_exposition) AS month,
			COUNT(*) AS published
	FROM real_estate.advertisement a 
	INNER JOIN filtered_id USING(id)
	INNER JOIN real_estate.flats f USING(id)
	LEFT JOIN real_estate."type" t USING(type_id)
	WHERE days_exposition IS NOT NULL AND first_day_exposition BETWEEN DATE '2014-01-01' AND DATE '2018-12-31' AND t.type = 'город'
	GROUP BY month
),
removed AS (
	SELECT EXTRACT(MONTH FROM (first_day_exposition + days_exposition * INTERVAL '1 day')) AS month,
			COUNT(*) AS removed
	FROM real_estate.advertisement a 
	INNER JOIN filtered_id USING(id)
	INNER JOIN real_estate.flats f USING(id)
	LEFT JOIN real_estate."type" t USING(type_id)
	WHERE days_exposition IS NOT NULL AND first_day_exposition BETWEEN DATE '2014-01-01' AND DATE '2018-12-31' AND t.type = 'город'
	GROUP BY month
)
SELECT month,
		published, removed,
		ROUND(((removed - published)::NUMERIC/published)*100,2) AS difference
FROM published
INNER JOIN removed USING(month)
ORDER BY month;
-- Анализ опубликованных объявлений
WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),
-- Найдём id объявлений, которые не содержат выбросы:
filtered_id AS(
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
    ),
published AS (
	SELECT TO_CHAR(first_day_exposition, 'TMMONTH') AS month,
			COUNT(*) AS published,
			ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER(),2) AS share_published,
			ROUND(AVG(total_area)::NUMERIC, 2) AS avg_area_published,
        	ROUND(AVG(last_price / total_area)::NUMERIC, 2) AS avg_cost_per_sqm_published
	FROM real_estate.advertisement a 
	INNER JOIN filtered_id USING(id)
	INNER JOIN real_estate.flats f USING(id)
	LEFT JOIN real_estate."type" t USING(type_id)
	WHERE first_day_exposition BETWEEN DATE '2014-01-01' AND DATE '2018-12-31' AND t.type = 'город'
	GROUP BY month
),
ranked_published AS (
	SELECT *, RANK() OVER(ORDER BY published DESC) AS rank
	FROM published
),
-- Анализ снятых объявлений
removed AS (
	SELECT TO_CHAR((first_day_exposition + days_exposition * INTERVAL '1 day'), 'TMMONTH') AS month,
			COUNT(*) AS removed,
			ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER(),2) AS share_removed,
			ROUND(AVG(total_area)::NUMERIC, 2) AS avg_area_removed,
        	ROUND(AVG(last_price / total_area)::NUMERIC, 2) AS avg_cost_per_sqm_removed
	FROM real_estate.advertisement a 
	INNER JOIN filtered_id USING(id)
	INNER JOIN real_estate.flats f USING(id)
	LEFT JOIN real_estate."type" t USING(type_id)
	WHERE days_exposition IS NOT NULL AND first_day_exposition BETWEEN DATE '2014-01-01' AND DATE '2018-12-31' AND t.type = 'город'
	GROUP BY month
)
SELECT rank,
		month,
		published,
		share_published,
		removed,
		share_removed,
		avg_area_published,
		avg_area_removed,
		avg_cost_per_sqm_published,
		avg_cost_per_sqm_removed
FROM ranked_published
FULL JOIN removed USING(month);
