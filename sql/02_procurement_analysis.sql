--===================================================================================================================
--PROCUREMENT ANALYSIS QUERY
--Purpose: Creates clean data table of procurement KPIs for supplier bottleneck analysis. 
--===================================================================================================================

SELECT  
supplier_name,  --Groups by five suppliers
COUNT(*) AS total_SKUs, --Counts total SKUs per supplier 
ROUND (AVG(total_operational_SKU_costs),2) AS avg_total_operational_SKU_costs, --Operational costs associated with SKUs grouped by supplier 

--===================================================================================================================
--Reliability metrics: 
ROUND (AVG(procurement_lead_time),2) AS avg_procurement_lead_time, --Procurement time per supplier 
ROUND(AVG(estimated_cycle_time),2) AS avg_cycle_time,  --Total supply chain lead time 

--===================================================================================================================
--Quality metrics: 
--Includes avg. defect rate, avg. first pass yield, net inspection score, number of failed and passed inspections, and inspection fail / pass rates 
ROUND (AVG(first_pass_yield),2) AS avg_first_pass_yield,
ROUND (AVG(defect_rate),2) AS avg_defect_rate, 
ROUND (SUM(inspection_score),2) AS inspection_score, 
COUNTIF(inspection_results= 'Fail') AS failed_inspections,
COUNTIF(inspection_results='Pass') AS passed_inspections, 
ROUND((COUNTIF(inspection_results= 'Fail'))/(COUNT(*)),2) AS inspection_fail_rate,
ROUND((COUNTIF(inspection_results= 'Pass'))/(COUNT(*)),2) AS inspection_pass_rate

--===================================================================================================================
FROM `supply-chain-project-1.supply_chain.cleaned_orders` 

GROUP BY supplier_name 

ORDER BY supplier_name ASC; --Groups and sorts by supplier name 