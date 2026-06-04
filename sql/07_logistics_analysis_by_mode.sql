--===================================================================================================================
--LOGISTICS (MODE) ANALYSIS QUERY
--Purpose: Creates clean data table of logistics KPIs for transportation mode bottleneck analysis. 
--===================================================================================================================


SELECT  
transportation_mode, --Groups by 4 modes (road, rail, air, sea)
COUNT(*) AS total_SKUs, --Counts total SKUs per mode  

--===================================================================================================================
--Key metrics include avg. shipping time and avg. shipping cost. Supplementary metrics include avg. fulfillment lead time and total supply chain lead time. 
ROUND(AVG(shipping_times),2) AS avg_shipping_time, 
ROUND(AVG(shipping_cost),2) AS avg_shipping_cost, 
ROUND (AVG(fulfillment_lead_time),2) AS avg_fulfillment_lead_time,
ROUND(AVG(estimated_cycle_time),2) AS avg_cycle_time

--===================================================================================================================
FROM `supply-chain-project-1.supply_chain.cleaned_orders` 

GROUP BY transportation_mode --Groups and sorts by transportation mode