
with total_transactions as(
	SELECT sd.category, EXTRACT (year from od.order_date) as year, sum(od.after_discount) as total_transaction
	FROM ORDER_DETAIL OD 
	JOIN SKU_DETAIL SD on od.sku_id = sd.id
	WHERE od.is_valid = 1
	GROUP BY 1, 2
)
SELECT tt2021.category as category,
	tt2021.total_transaction as total_2021,
	tt2022.total_transaction as total_2022,
	(tt2022.total_transaction - tt2021.total_transaction) as difference,
	CASE 
		WHEN tt2022.total_transaction > tt2021.total_transaction THEN concat('↑ ',
			ROUND((tt2022.total_transaction - tt2021.total_transaction) / nullif(tt2021.total_transaction, 0) * 100), '%')
		WHEN tt2022.total_transaction < tt2021.total_transaction THEN concat('↓ -',
			ROUND((tt2021.total_transaction - tt2022.total_transaction) / nullif(tt2021.total_transaction, 0) * 100), '%')
		ELSE 'stabil'
	END AS information
FROM
    (SELECT category, total_transaction FROM total_transactions WHERE YEAR = 2021) tt2021
FULL OUTER JOIN 
    (SELECT category, total_transaction FROM total_transactions WHERE YEAR = 2022) tt2022
ON tt2021.category = tt2022.category
ORDER BY 1
		
