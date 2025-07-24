
SELECT sd.category, 
	SUM(after_discount) as terbesar 
FROM ORDER_DETAIL OD
LEFT JOIN SKU_DETAIL SD on od.sku_id = sd.id
WHERE EXTRACT (year from order_date) = 2022 and is_valid = 1
GROUP BY 1
ORDER BY 2 DESC
