/*
1. Investigate whether there is any correlation between vehicle sales and specific months or seasons in different districts. 
Are there any months or seasons that consistently show higher or lower sales rate, and if yes, what could be the driving factors? 
(Consider Fuel-Type category only)
*/

select 
	fiscal_year,
	Mmm,
    district,
   sum(fuel_type_petrol + fuel_type_diesel + fuel_type_electric + fuel_type_others) as vehicle_sale
from fact_transport
join dim_date 
using (month) 
join dim_districts 
using (dist_code) 
group by 1,2,3
order by 1,2, vehicle_sale desc;

-- 2. How does the distribution of vehicles vary by vehicle class 
-- (MotorCycle, MotorCar, AutoRickshaw, Agriculture) across different districts? 
-- Are there any districts with a predominant preference for a specific vehicle class? 
-- Consider FY 2022 for analysis.
select 
	district,
    sum(vehicleClass_MotorCycle) as motorCycle,
    sum(vehicleClass_MotorCar) as motorCar,
    sum(vehicleClass_Agriculture) as Agriculture, 
	sum(vehicleClass_AutoRickshaw) as AutoRickshaw, 
    sum(vehicleClass_MotorCycle+vehicleClass_MotorCar+vehicleClass_AutoRickshaw+vehicleClass_Agriculture) as Total_vehicles
from fact_transport 
join dim_date 
using (month) 
join dim_districts 
using (dist_code)
where fiscal_year = "2022"
group by district
order by Total_vehicles desc, motorCycle desc,3 desc,4 desc,5 desc;

-- 3.  List down the top 3 and bottom 3 districts that have shown the highest and lowest vehicle sales growth 
-- during FY 2022 compared to FY 2021? 
-- (Consider and compare categories: Petrol, Diesel and Electric)
WITH GrowthPct_22_21 as (
WITH growthPct AS (
    SELECT 
        fiscal_year,
        district,
        petrol22 - petrol21 AS petrolChange,
        diesel22 - diesel21 AS dieselChange,
        electric22 - electric21 AS electricChange,
        total_vehiclesales22 - total_vehiclesales21 AS total_vehiclesalesChange
    FROM fuel_22_21
)
SELECT 
    gp.fiscal_year,
    gp.district,
    ROUND(((gp.petrolChange * 100) / (
        SELECT petrol21 
        FROM fuel_22_21 t 
        WHERE t.district = gp.district
    )), 2) AS petrolGrowthPct,
    ROUND(((gp.dieselChange * 100) / (
        SELECT diesel21 
        FROM fuel_22_21 t 
        WHERE t.district = gp.district
    )), 2) AS dieselGrowthPct,
    ROUND(((gp.electricChange * 100) / (
        SELECT electric21 
        FROM fuel_22_21 t 
        WHERE t.district = gp.district
    )), 2) AS electricGrowthPct,
    ROUND(((gp.total_vehiclesalesChange * 100) / (
        SELECT total_vehiclesales21 
        FROM fuel_22_21 t 
        WHERE t.district = gp.district
    )), 2) AS totalVehicleSalesGrowthPct
FROM growthPct gp )
-- for bottom 3 districts with lowest electric vehicles,
select 
	district,
	electricGrowthPct
from GrowthPct_22_21
order by electricGrowthPct 
limit 3;
-- for bottom 3 districts with lowest diesel vehicles,
/*
select 
	district,
	dieselGrowthPct
from GrowthPct_22_21
order by dieselGrowthPct 
limit 3;
*/
-- for top 3 districts with highest diesel vehicles,
/*
select 
	district,
	dieselGrowthPct
from GrowthPct_22_21
order by dieselGrowthPct desc 
limit 3;
*/
-- for bottom 3 districts with lowest petrolGrowthPct
/*
select 
	district,
	petrolGrowthPct
from GrowthPct_22_21
order by petrolGrowthPct 
limit 3;
*/
-- for top 3 districts with highest petrolGrowthPct 
/*
select 
	district,
	petrolGrowthPct
from GrowthPct_22_21
order by petrolGrowthPct desc
limit 3;
*/
	
    




