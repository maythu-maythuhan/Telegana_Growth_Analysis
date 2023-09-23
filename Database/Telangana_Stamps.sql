/*
1. How does the revenue generated from document registration vary across districts in Telangana? 
List down the top 5 districts that showed the highest document registration revenue growth between FY 2019 and 2022.
*/
with district_highest_docrev as (
	with cte as (
	select fiscal_year, district,
	sum(documents_registered_rev) over(partition by district, fiscal_year) as doc_revenue 
from dim_districts d 
join fact_stamps s 
using (dist_code)
join dim_date dd 
on dd.month = s.month
where fiscal_year between 2019 and 2022
group by 1,2,documents_registered_rev
order by  fiscal_year, doc_revenue desc
)
select distinct *,
	dense_rank() over(partition by cte.fiscal_year order by doc_revenue desc) as Ranking
 from cte
)
select * from district_highest_docrev
where Ranking<=5;


/*
2. How does the revenue generated from document registration compare to the revenue generated from e-stamp challans across districts? 
List down the top 5 districts where e-stamps revenue contributes significantly more to the revenue than the documents in FY 2022?
*/
With cte1 as (
select 
	district,
    sum(documents_registered_rev) as total_doc_rev,
    sum(estamps_challans_rev) as total_estamps_rev
from dim_date
join fact_stamps
using (month)
join dim_districts
using (dist_code)
where fiscal_year="2022"
group by 1
order by total_doc_rev desc
)
select *,
	(total_estamps_rev - total_doc_rev) as estamps_doc_diff
from cte1
order by estamps_doc_diff desc
limit 5;

/*
3. Is there any alteration of e-Stamp challan count and document registration count pattern since the implementation of e-Stamp challan? 
If so, what suggestions would you propose to the government?
*/
With cte2 as (
	select 
		fiscal_year,
		sum(documents_registered_cnt) as total_doc_count,
		sum(estamps_challans_cnt) as total_estamp_count
	from dim_date 
	join fact_stamps
	using (month) 
	join dim_districts 
	using (dist_code)
	group by fiscal_year
)
select 
	*,
	(total_estamp_count - total_doc_count) as estamp_doc_count_Diff
from cte2
order by estamp_doc_count_Diff desc;

/*
5. Categorize districts into three segments based on their stamp registration revenue generation 
during the fiscal year 2021 to 2022. 
*/	
with quar as (
with cte4 as (
	with cte3 as (
	select 
		fiscal_year,
		district,
		sum(documents_registered_rev) as total_doc_rev,
		sum(estamps_challans_rev) as total_estamps_rev
	from dim_date 
	join fact_stamps 
	using (month)
	join dim_districts 
	using (dist_code)
	where fiscal_year between 2021 and 2022
	group by 1,2
	order by 1, 3 desc,4 desc
)
select 
		fiscal_year,
		district,
        (total_doc_rev + total_estamps_rev) as total_revenue
from cte3
)
select 
	*,
    NTILE(3) OVER (Partition by fiscal_year ORDER BY total_revenue) AS quartile
from cte4
)
select *,
	case
		when quartile = 1 then "Low"
        when quartile = 2 then "Moderate"
        when quartile = 3 then "High"
    end as segment    
 from quar;









