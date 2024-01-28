--Aditya Nugraha--
--------------------------------------------------------------------------------------------------------------------------------------
--1. Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi paling besar?
--------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    EXTRACT(MONTH FROM order_date) AS bulan,
    SUM(after_discount) AS total_nilai_transaksi
FROM 
    order_detail
WHERE 
    EXTRACT(YEAR FROM order_date) = 2021 
    AND is_valid = 1
GROUP BY 
    EXTRACT(MONTH FROM order_date)
ORDER BY 
    total_nilai_transaksi DESC
LIMIT 1;

--------------------------------------------------------------------------------------------------------------------------------------
--2. Selama transaksi pada tahun 2022, kategori apa yang menghasilkan nilai transaksi paling besar? 
--------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    sd.category AS kategori,
    SUM(od.after_discount) AS total_nilai_transaksi
FROM 
    order_detail od
INNER JOIN 
    sku_detail sd ON od.sku_id = sd.id
WHERE 
    EXTRACT(YEAR FROM od.order_date) = 2022 
    AND od.is_valid = 1
GROUP BY 
    sd.category
ORDER BY 
    total_nilai_transaksi DESC
LIMIT 1;

--------------------------------------------------------------------------------------------------------------------------------------
--3. Bandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022. Sebutkan kategori apa saja yang mengalami 
--peningkatan dan kategori apa yang mengalami penurunan nilai transaksi dari tahun 2021 ke 2022
--------------------------------------------------------------------------------------------------------------------------------------
SELECT
    category,
    SUM(CASE WHEN tahun = 2021 THEN total_transaksi ELSE 0 END) AS total_2021,
    SUM(CASE WHEN tahun = 2022 THEN total_transaksi ELSE 0 END) AS total_2022,
    CASE
        WHEN SUM(CASE WHEN tahun = 2022 THEN total_transaksi ELSE 0 END) >
             SUM(CASE WHEN tahun = 2021 THEN total_transaksi ELSE 0 END) THEN 'Naik'
        WHEN SUM(CASE WHEN tahun = 2022 THEN total_transaksi ELSE 0 END) <
             SUM(CASE WHEN tahun = 2021 THEN total_transaksi ELSE 0 END) THEN 'Turun'
        ELSE 'Tidak Berubah'
    END AS status_perubahan
FROM (
    SELECT
        sd.category,
        EXTRACT(YEAR FROM od.order_date) AS tahun,
        ROUND(SUM(od.after_discount * od.qty_ordered)::numeric, 0) AS total_transaksi
    FROM
        order_detail od
    JOIN
        sku_detail sd ON od.sku_id = sd.id
    WHERE
        od.is_valid = 1
        AND EXTRACT(YEAR FROM od.order_date) IN (2021, 2022)
    GROUP BY
        sd.category, EXTRACT(YEAR FROM od.order_date)
) AS TransaksiPerKategori
GROUP BY
    category
ORDER BY
    status_perubahan ASC;
   
 --------------------------------------------------------------------------------------------------------------------------------------  
-- 4. Memfilter top 5 metode pembayaran yang paling populer digunakan selama 2022
--------------------------------------------------------------------------------------------------------------------------------------
SELECT
    payment_method,
    COUNT(DISTINCT od.id) AS total_payment
FROM
    order_detail od
JOIN
    payment_detail pd ON od.payment_id = pd.id
WHERE
    od.is_valid = 1
    AND EXTRACT(YEAR FROM od.order_date) = 2022
GROUP BY
    payment_method
ORDER BY
    total_payment DESC
LIMIT 5;

--------------------------------------------------------------------------------------------------------------------------------------
--5. Memfilter top 5 produk dengan transaksi terbanyak
--------------------------------------------------------------------------------------------------------------------------------------
SELECT
    CASE
        WHEN LOWER(sd.sku_name) LIKE '%samsung%' THEN 'Samsung'
        WHEN LOWER(sd.sku_name) LIKE '%apple%' THEN 'Apple'
        WHEN LOWER(sd.sku_name) LIKE '%sony%' THEN 'Sony'
        WHEN LOWER(sd.sku_name) LIKE '%huawei%' THEN 'Huawei'
        WHEN LOWER(sd.sku_name) LIKE '%lenovo%' THEN 'Lenovo'
        ELSE sd.sku_name
    END AS product_category,
    ROUND(SUM(od.after_discount * od.qty_ordered)::numeric, 0) AS total_sales
FROM
    order_detail od
JOIN
    sku_detail sd ON od.sku_id = sd.id
WHERE
    od.is_valid = 1
    AND sd.sku_name ILIKE ANY (ARRAY['%Samsung%', '%Apple%', '%Sony%', '%Huawei%', '%Lenovo%'])
GROUP BY
    product_category
ORDER BY
    total_sales DESC;
