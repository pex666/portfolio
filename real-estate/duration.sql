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
    )
SELECT CASE 
			WHEN city = 'Санкт-Петербург'
			THEN 'Санкт-Петербург'
			ELSE 'ЛенОбл'
		END AS region,
		CASE
			WHEN days_exposition BETWEEN 1 AND 30
			THEN 'Месяц'
			WHEN days_exposition BETWEEN 31 AND 90
			THEN 'Квартал'
			WHEN days_exposition BETWEEN 91 AND 180
			THEN 'Полгода'
			WHEN days_exposition >= 181
			THEN 'Больше полугода'
			ELSE 'Непроданные'
		END AS activity,
		COUNT(id) AS advertisements,
		ROUND(COUNT(id)::NUMERIC / SUM(COUNT(id)) OVER(), 2)  AS share_total,
		ROUND(AVG(total_area)::NUMERIC,2) AS avg_area,
		ROUND(AVG(last_price / total_area)::NUMERIC,2) AS avg_cost_per_sqm,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rooms) AS median_of_rooms,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balcony) AS median_of_balcony,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY floor) AS median_of_floor
FROM real_estate.flats
INNER JOIN filtered_id USING(id)
LEFT JOIN real_estate.city USING(city_id)
INNER JOIN real_estate.advertisement USING(id)
LEFT JOIN real_estate."type" t USING(type_id)
WHERE t.type = 'город'
GROUP BY region, activity
ORDER BY region, activity;
