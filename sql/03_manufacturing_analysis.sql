--===================================================================================================================
--MANUFACTURING ANALYSIS QUERY
--Purpose: Creates clean data table of manufacturing/production KPIs for manufacturing level bottleneck analysis. 
--===================================================================================================================


SELECT  
product_type, --Groups by 3 product types, haircare / cosmetics / skincare
COUNT(*) AS total_SKUs, --Counts total SKUs per product type

--===================================================================================================================
--Cost & revenue metrics: 
ROUND (AVG(total_operational_SKU_costs),2) AS avg_total_operational_SKU_costs, --Operational costs associated with SKUs grouped by product type 
ROUND (AVG(manufacturing_cost),2) AS avg_manufacturing_cost, --Avg. manufacturing cost grouped by product type 
ROUND (AVG(manufacturing_cost_per_unit),2) AS avg_manufacturing_cost_per_unit, --Avg manufacturing cost per unit produced per SKU
ROUND (AVG(cost_revenue_ratio),2) AS avg_cost_revenue_ratio, --Examines cost/production efficiency 

--===================================================================================================================
--Production & reliability metrics: 
ROUND (AVG(production_volume),2) AS avg_production_volume, --Avg. amount produced per SKU 
ROUND (AVG(manufacturing_lead_time),2) AS avg_manufacturing_lead_time, --Manufacturing lead time per product type 
ROUND(AVG(estimated_cycle_time),2) AS avg_cycle_time, --Total supply chain lead time 

--===================================================================================================================
--Quality metrics: 
--Includes avg. defect rate, avg. first pass yield, net inspection score, number of failed and passed inspections, and inspection fail / pass rates 
ROUND (AVG(defect_rate),2) AS avg_defect_rate,
ROUND (AVG(first_pass_yield),2) AS avg_first_pass_yield,
ROUND (SUM (inspection_score),2) AS net_inspection_score,
COUNTIF(inspection_results= 'Fail') AS failed_inspections,
COUNTIF(inspection_results='Pass') AS passed_inspections,
ROUND((COUNTIF(inspection_results= 'Fail'))/(COUNT(*)),2) AS inspection_fail_rate,
ROUND((COUNTIF(inspection_results= 'Pass'))/(COUNT(*)),2) AS inspection_pass_rate


--===================================================================================================================
FROM `supply-chain-project-1.supply_chain.cleaned_orders` 

GROUP BY product_type 

ORDER BY total_SKUs DESC; --Groups by product type and sorts by total SKUs 