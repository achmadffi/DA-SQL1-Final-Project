
SELECT * FROM ORDER_DETAIL OD 

SELECT * FROM SKU_DETAIL SD 

SELECT * FROM PAYMENT_DETAIL PD 

SELECT * FROM CUSTOMER_DETAIL CD

SELECT EXTRACT(month from order_date) as bulan, 
	SUM(after_discount) as totalnilaitransaksi 
FROM order_detail od
WHERE IS_VALID = 1 AND EXTRACT (year from order_date) = 2021
GROUP BY 1
ORDER BY 2 DESC
