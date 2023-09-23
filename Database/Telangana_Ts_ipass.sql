SELECT * FROM telangana.fact_ts_ipass;

-- 1. List down the top 5 sectors that have witnessed the most significant investments in FY 2022.

select 
	sector, 
    round((sum(investment_in_cr) ),2) as total_investment_cr
from fact_ts_ipass
join dim_date 
using (month) 
join dim_districts
using (dist_code)
where fiscal_year = "2022"
group by sector
order by total_investment_cr desc
limit 5;

-- 2. List down the top 3 districts that have attracted the most significant sector investments during FY 2019 to 2022? 
--    What factors could have led to the substantial investments in these particular districts?
With top3_districts as (
	select 
		fiscal_year,
		district,
		sector,
		round((sum(investment_in_cr)),2) as total_investment_cr,
		dense_rank() over(partition by fiscal_year order by sum(investment_in_cr) desc) as DRank
	from fact_ts_ipass 
	join dim_date 
	using (month) 
	join dim_districts 
	using (dist_code) 
	where fiscal_year between '2019' and '2022'
	group by district,1,3
	order by fiscal_year, total_investment_cr desc
    )
   select * from top3_districts
   where DRank <=3; 
   
   
-- 3. Is there any relationship between district investments, vehicles
-- sales and stamps revenue within the same district between FY 2021
-- and 2022?   
SELECT 
    d.fiscal_year,
    dd.district,
    ROUND(SUM(f.investment_in_cr), 2) AS total_investment_cr,
    SUM(t.vehicleClass_Agriculture + t.vehicleClass_AutoRickshaw + t.vehicleClass_MotorCar + t.vehicleClass_MotorCycle + t.vehicleClass_others) AS total_vehicle_sale,
    SUM(s.documents_registered_rev+ s.estamps_challans_rev) AS total_stamp_rev
FROM fact_ts_ipass AS f
JOIN dim_date AS d USING (month)
JOIN dim_districts AS dd USING (dist_code)
JOIN fact_stamps AS s ON f.month = s.month AND f.dist_code = s.dist_code
JOIN fact_transport t ON t.month = f.month AND f.dist_code = t.dist_code
WHERE d.fiscal_year BETWEEN '2021' AND '2022'
GROUP BY d.fiscal_year, dd.district
ORDER BY d.fiscal_year, total_investment_cr DESC, total_vehicle_sale desc, total_stamp_rev desc;

-- 4. Are there any particular sectors that have shown substantial
-- investment in multiple districts between FY 2021 and 2022?

select * from maxSector_withDistricts_21_22 
where sector in (select sector from 
(
	select
		sector,
		count(sector) as sectorCount
	from maxSector_withDistricts_21_22
	group by sector
	having sectorCount <>1
)s);

-- 5. Can we identify any seasonal patterns or cyclicality in the
-- investment trends for specific sectors? Do certain sectors
-- experience higher investments during particular months?

select 
	fiscal_year,
    Mmm as month,
    sector,
    round((sum(investment_in_cr)),2) as total_investment
from fact_ts_ipass 
join dim_date 
using (month) 
group by fiscal_year,  month, sector
order by fiscal_year,  month, total_investment desc;


    
    














   
