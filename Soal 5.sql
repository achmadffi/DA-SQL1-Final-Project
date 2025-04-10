
WITH nama AS(
    SELECT id, 
	CASE
		WHEN lower(sku_name) LIKE '%samsung%' THEN 'Samsung'
		WHEN lower(sku_name) LIKE '%apple%' OR LOWER(sku_name) LIKE '%iphone%' OR LOWER(sku_name) LIKE '%macbook%' THEN 'Apple'
		WHEN lower(sku_name) LIKE '%sony%' THEN 'Sony'
		WHEN lower(sku_name) LIKE '%huawei%' THEN 'Huawei'
		WHEN lower(sku_name) LIKE '%lenovo%' THEN 'Lenovo'
	END AS brand -- CTE merubah huruf menjadi kecil dan mengambil karakter tertentu
    FROM SKU_DETAIL SD
)
SELECT n.brand, SUM(od.after_discount) AS total_transaction_value 
FROM order_detail od
LEFT JOIN nama n ON od.SKU_ID = n.id
WHERE is_valid = 1 AND n.brand NOTNULL 
GROUP BY 1
ORDER BY 2 DESC 
