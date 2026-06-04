--===================================================================================================================
--DATA CLEANING & KPI ENGINEERING VIEW
--Purpose: Formats & standardizes columns, calculates & adds KPIs, categorizes data & creates a final cleaned view
--===================================================================================================================

CREATE OR REPLACE VIEW `supply-chain-project-1.supply_chain.cleaned_orders` AS --Creates cleaned dataset view named cleaned orders 


--===================================================================================================================
--COLUMN STANDARDIZATION & FORMATTING
--===================================================================================================================


WITH cleaned AS ( 

SELECT --Selects columns from original dataset for first layer of CTE 



--Renames columns for consistency and clarity and rounds floats
--Note: dropped customer demographics, location, availability

    `Product type` AS product_type, 
    CONCAT ('SKU', LPAD(SUBSTR(SKU, 4),2,'0')) AS SKU, --Formats SKUs consistently 
    ROUND(Price, 2) AS SKU_price, 
    `Number of products sold` AS product_sold, 
    ROUND (`Revenue generated`,2) AS revenue, 
    `Stock levels` AS stock_levels, 
    `Lead times` AS fulfillment_lead_time, --Interpeted this field as lead time of order fulfillment 
    `Order quantities` AS order_quantity,
    `Shipping times` AS shipping_times, 
    `Shipping carriers` AS shipping_carrier, 
    ROUND(`Shipping costs`, 2) AS shipping_cost, 
    `Supplier name` AS supplier_name, 
    `Lead time` AS procurement_lead_time, --Interpeted this field as lead time of procurement from suppliers 
    `Production volumes` AS production_volume, 
    `Manufacturing lead time` AS manufacturing_lead_time, 
    ROUND(`Manufacturing costs`, 2) AS manufacturing_cost, 
    `Inspection results` AS inspection_results, 
    ROUND(`Defect rates`,2) AS defect_rate, 
   `Transportation modes` AS transportation_mode, 
   Routes AS routes, 
   ROUND (Costs,2) AS total_operational_SKU_costs

   FROM `supply-chain-project-1.supply_chain.orders`),

--Units: all costs are in USD, lead times in days, revenue in millions USD. 


--===================================================================================================================
--CALCULATED KPIS
--===================================================================================================================

--Second layer of CTE, selects variables from 'cleaned' table and creates metrics table 

metrics AS ( 

  SELECT *, --Selects all columns from 'cleaned'

    round(stock_levels / order_quantity,2) AS stock_demand_ratio, --Inventory alignment with demand, helps identify potential overstock or stockout risk. 
    round(revenue-total_operational_SKU_costs,2) AS estimated_SKU_profit,  --Estimated profitability of each SKU after operational costs
    round((total_operational_SKU_costs / revenue),2) AS cost_revenue_ratio, --Measures proportion of revenue consumed by operational costs and evaluates SKU level operational efficiency.
    round(100-defect_rate,2) AS first_pass_yield, --Proportion of good products produced over first pass. 
    round(fulfillment_lead_time + procurement_lead_time + manufacturing_lead_time,2) AS estimated_cycle_time, --Total supply chain cycle time 
    round(manufacturing_cost / production_volume ,4) AS manufacturing_cost_per_unit --Cost to manufacture per unit
    
    FROM cleaned) 

--===================================================================================================================
--DATA CATEGORIZATION
--===================================================================================================================

Select *, --Selects all columns from metrics table for final cleaned view

    CASE --Categorizes S/D ratio into buckets based on stock risk. 
      WHEN stock_demand_ratio < 0.5 THEN "Stockout Risk"
      WHEN stock_demand_ratio >0.5 AND stock_demand_ratio<1.5  THEN "Balanced"
      WHEN stock_demand_ratio > 1.5 THEN "Overstock Risk"
    END AS inventory_risk_status,

    CASE  --Categorizes profit into positive & negative. 
      WHEN estimated_SKU_profit>0 THEN "Positive"
      ELSE "Negative"
    END AS profitability_of_SKU, 

    CASE --Categorizes first pass yield into buckets defined by 95% acceptable rate. 
      WHEN first_pass_yield>95 THEN "Acceptable"
      ELSE "Unacceptable"
    END AS quality_bucket,

    CASE --Categorizes inspection results to create inspection scoring. 
      WHEN inspection_results = "Fail" THEN -1 
      WHEN inspection_results = "Pending" THEN 0
      WHEN inspection_results = "Pass" THEN 1
    END AS inspection_score, 


    CASE --Categorizes cost to revenue ratio into buckets. 
      WHEN cost_revenue_ratio >1 THEN "Unprofitable"
      WHEN cost_revenue_ratio >=0.6 THEN "High Cost Burden"
      WHEN cost_revenue_ratio <0.6 THEN "Efficient"
    END AS cost_efficiency 

FROM metrics; 



