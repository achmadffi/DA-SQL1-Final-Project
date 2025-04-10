
SELECT * FROM ORDER_DETAIL OD 

SELECT * FROM SKU_DETAIL SD 

SELECT * FROM PAYMENT_DETAIL PD 

SELECT * FROM CUSTOMER_DETAIL CD

-- Soal 1
SELECT EXTRACT(month from order_date) as bulan, 
		SUM(after_discount) as totalnilaitransaksi 
FROM order_detail od
WHERE IS_VALID = 1 AND EXTRACT (year from order_date) = 2021
GROUP BY 1
ORDER BY 2 DESC

SELECT date_format(order_date, '%m') as bulan, SUM(after_discount) as nilaitransaksi from ORDER_DETAIL OD
WHERE IS_VALID = 1 AND EXTRACT (year from order_date) = 2021
group by 1
ORDER BY 2 DESC 

-- Soal 2
SELECT sd.category, 
		SUM(after_discount) as terbesar 
FROM ORDER_DETAIL OD
LEFT JOIN SKU_DETAIL SD on od.sku_id = sd.id
WHERE EXTRACT (year from order_date) = 2022 and is_valid = 1
GROUP BY 1
ORDER BY 2 DESC

-- Soal 3
with transaksi as(
	SELECT sd.category,
	SUM(CASE 
		when extract(year from od.order_date) = 2021 then od.after_discount end) as nilaitransaksi2021, -- nilai transaksi 2021
	SUM(CASE 
		when extract(year from od.order_date) = 2022 then od.after_discount end) as nilaitransaksi2022 -- nilai transaksi 2022	
from ORDER_DETAIL OD
left join SKU_DETAIL SD on od.sku_id = sd.id
WHERE EXTRACT (year from order_date) in (2021, 2022) and od.is_valid = 1
GROUP BY 1
)
SELECT *, 
	CASE 
		when t.nilaitransaksi2021 < t.nilaitransaksi2022 then 'Peningkatan'
		ELSE 'Penurunan'
	end as perubahan
FROM transaksi t

-- Soal 3 Modifikasi
WITH transaksi AS(
	SELECT sd.category,
	SUM(CASE 
		WHEN EXTRACT(YEAR FROM od.order_date) = 2021 THEN od.after_discount END) AS nilaitransaksi_2021, 
	SUM(CASE 
		WHEN EXTRACT(YEAR FROM od.order_date) = 2022 THEN od.after_discount END) AS nilaitransaksi_2022 
FROM ORDER_DETAIL OD
LEFT JOIN SKU_DETAIL SD ON od.sku_id = sd.id
WHERE EXTRACT (YEAR FROM order_date) IN (2021, 2022) AND od.is_valid = 1
GROUP BY 1
)
SELECT *, 
	(t.nilaitransaksi_2022 - t.nilaitransaksi_2021) AS difference,
	CASE 
		WHEN t.nilaitransaksi_2021 < t.nilaitransaksi_2022 THEN 'Peningkatan'
		ELSE 'Penurunan'
	END AS informasi
FROM transaksi t

-- Soal 3 Teman
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
		

-- Soal 3
with transaksi1 as(
	SELECT sd.category, EXTRACT(year from order_date) as tahun, SUM(od.after_discount) as nilaitransaksi2021 from ORDER_DETAIL OD 
	left join SKU_DETAIL SD on od.sku_id = sd.id
	WHERE IS_valid = 1 AND EXTRACT (year from order_date) = 2021
	group by 1,2 -- CTE nilai transaksi 2021
),
transaksi2 as(
	SELECT sd.category, EXTRACT(year from order_date) as tahun, SUM(od.after_discount) as nilaitransaksi2022 from ORDER_DETAIL OD 
	left join SKU_DETAIL SD on od.sku_id = sd.id
	WHERE IS_valid = 1 AND EXTRACT (year from order_date) = 2022
	group by 1,2 -- CTE nilai transaksi 2022
)
SELECT t1.category, t1.nilaitransaksi2021, t2.nilaitransaksi2022, 
	CASE 
		when t1.nilaitransaksi2021 < t2.nilaitransaksi2022 then 'Peningkatan'
		ELSE 'Penurunan'
	end as perubahan
from transaksi1 t1
left join transaksi2 t2 on t1.category = t2.category

-- Soal 4
SELECT pd.payment_method, 
		COUNT(DISTINCT od.id) AS jumlahorder 
FROM ORDER_DETAIL OD 
LEFT JOIN PAYMENT_DETAIL PD ON od.payment_id = pd.id
WHERE IS_valid = 1 AND EXTRACT (YEAR FROM order_date) = 2022
GROUP BY 1
ORDER BY 2 DESC LIMIT 5

-- Soal 5
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

-- Soal 5
with nama as(
	SELECT id, TRIM(LOWER(REPLACE(REPLACE(SKU_NAME, '_', ' '), '-', ' '))) as name from SKU_DETAIL SD 
	WHERE SKU_NAME LIKE '%samsung%' 
		OR SKU_NAME LIKE '%apple%' 
		OR SKU_NAME LIKE '%sony%' 
		OR SKU_NAME LIKE '%huawei%' 
		OR SKU_NAME LIKE '%lenovo%' 
), -- merubah tanda baca menjadi spasi, merubah awalan huruf menjadi kapital, menghilangkan spasi berlebih
produk as(
	SELECT n.id, n.name, 
		case
			when split_part(n.name, ' ', 1) = 'samsung' or SPLIT_PART(n.name, ' ', 2) = 'samsung' THEN 'SAMSUNG'
			when split_part(n.name, ' ', 1) = 'apple' or SPLIT_PART(n.name, ' ', 2) = 'apple' THEN 'APPLE'
			when split_part(n.name, ' ', 1) = 'sony' or SPLIT_PART(n.name, ' ', 2) = 'sony' THEN 'SONY'
			when split_part(n.name, ' ', 1) = 'huawei' or SPLIT_PART(n.name, ' ', 2) = 'huawei' THEN 'HUAWEI'
			when split_part(n.name, ' ', 1) = 'lenovo' or SPLIT_PART(n.name, ' ', 2) = 'lenovo' THEN 'LENOVO'
		end AS splitname 
	from nama n -- mengambil karakter tertentu
),
tbl_join as(
	SELECT od.AFTER_DISCOUNT, p.splitname from order_detail od
	left join PRODUK P on od.SKU_ID = p.id
	WHERE is_valid = 1 and p.splitname NOTNULL -- menggabungkan tabel CTE nama dan CTE produk
)
SELECT tb.splitname, SUM(tb.after_discount) as nilaitransaksi from tbl_join tb
group by 1
ORDER BY 2 DESC 

-- Soal 5 Teman
with top_product as(
SELECT 
	case
		when regexp_contains(LOWER(sd.sku_name), r'samsung') then 'samsung'
		when regexp_contains(LOWER(sd.sku_name), r'apple|iphone|macbook') then 'apple'
		when regexp_contains(LOWER(sd.sku_name), r'sony') then 'sony'
		when regexp_contains(LOWER(sd.sku_name), r'huawei') then 'huawei'
		when regexp_contains(LOWER(sd.sku_name), r'lenovo') then 'lenovo'
	end as nama_produk,
	sum(od.after_discount) as value
from ORDER_DETAIL OD 
left join SKU_DETAIL SD on od.SKU_ID = sd.ID 
WHERE IS_VALID = 1
GROUP BY 1
ORDER BY 2 DESC 
)
SELECT * FROM top_product
WHERE nama_produk IS not NULL 
	



-- Coba
with transaksi as(
	SELECT pd.payment_method, EXTRACT (YEAR from cd.registered_date) as tahun, SUM(od.after_discount) as nilai_transaksi from ORDER_DETAIL OD 
	left join PAYMENT_DETAIL PD on od.payment_id = pd.id
	LEFT JOIN CUSTOMER_DETAIL CD on od.customer_id = cd.id
	WHERE is_valid = 1
	GROUP BY 1, 2
)
SELECT t2021.payment_method,
		t2021.nilai_transaksi as transaksi_2021,
		t2022.nilai_transaksi as transaksi_2022,
		(t2022.nilai_transaksi - t2021.nilai_transaksi) as perubahan,
		case
			when t2022.nilai_transaksi > t2021.nilai_transaksi then 'Peningkatan'
			WHEN t2022.nilai_transaksi < t2021.nilai_transaksi then 'Penurunan'
			ELSE 'Tidak Ada Perubahan'
		end as status
from
	(select t.payment_method, t.nilai_transaksi from transaksi t where t.tahun = 2021) as t2021
left join
	(select t.payment_method, t.nilai_transaksi from transaksi t where t.tahun = 2022) as t2022
ON t2021.payment_method = t2022.payment_method
ORDER BY 1


SELECT MOD(QTY_ORDERED, 2) from ORDER_DETAIL OD

