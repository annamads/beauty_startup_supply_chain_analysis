--===================================================================================================================
--INVENTORY ANALYSIS QUERY
--Purpose: Creates clean data table of inventory & demand KPIs for order fulfillment level bottleneck analysis. 
--===================================================================================================================

--===================================================================================================================
SELECT  
product_type, --Groups by 3 product types, haircare / cosmetics / skincare
COUNT(*) AS total_SKUs, --Counts total SKUs per product type

--===================================================================================================================
--Inventory & demand metrics: 
ROUND(AVG(product_sold),2) AS avg_product_sold, --Avg. product sold per SKU 
ROUND (AVG(stock_levels),2) AS avg_stock_levels, --Avg. stock levels per SKU 
ROUND (AVG(order_quantity),2) AS avg_order_quantity, --Avg. order size per SKU 

--===================================================================================================================
--Reliability metrics:
ROUND (AVG(fulfillment_lead_time),2) AS avg_fulfillment_lead_time, --Avg. lead time for order fulfillment 
ROUND(AVG(estimated_cycle_time),2) AS avg_cycle_time, --Total supply chain lead time 

--===================================================================================================================
--Inventory risk profile metrics: 

--Inventory alighment with demand - helps identify potential overstock or stockout risk. 
ROUND(AVG(stock_demand_ratio),2) AS avg_stock_demand_ratio, 

 --S/D ratio less than 0.5, demonstrates high demand vs stock 
COUNTIF(inventory_risk_status = 'Stockout Risk') AS count_stockout_SKUs,
ROUND(COUNTIF(inventory_risk_status = 'Stockout Risk')/COUNT(*),2) AS stockout_risk_percent,

--S/D ratio between 0.5 and 1.5, demonstrates balanced stock with demand
COUNTIF(inventory_risk_status = 'Balanced') AS count_balanced_SKUs, 
ROUND(COUNTIF(inventory_risk_status = 'Balanced')/COUNT(*),2) AS balanced_percent,

--S/D ratio greater than 1.5, demonstrates high stock compared with demand. 
COUNTIF(inventory_risk_status = 'Overstock Risk') AS count_overstock_SKUs, 
ROUND(COUNTIF(inventory_risk_status = 'Overstock Risk')/COUNT(*),2) AS overstock_risk_percent

--===================================================================================================================
FROM `supply-chain-project-1.supply_chain.cleaned_orders` 

GROUP BY product_type 

ORDER BY avg_stock_demand_ratio DESC; --Groups by product type and sorts by average S/D ratio. 