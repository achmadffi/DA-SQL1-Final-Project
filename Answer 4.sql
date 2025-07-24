
SELECT pd.payment_method, 
	COUNT(DISTINCT od.id) AS jumlahorder 
FROM ORDER_DETAIL OD 
LEFT JOIN PAYMENT_DETAIL PD ON od.payment_id = pd.id
WHERE IS_valid = 1 AND EXTRACT (YEAR FROM order_date) = 2022
GROUP BY 1
ORDER BY 2 DESC LIMIT 5
