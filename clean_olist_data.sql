use E_Commerse;

-- 1) حذف التكرار الكامل في geolocation

create table geolocation_clean(
    geolocation_id varchar(40),
    geolocation_zip_code_prefix CHAR(5),
    geolocation_lat DECIMAL(10,7),
    geolocation_lng DECIMAL(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
   
);

INSERT INTO geolocation_clean
SELECT DISTINCT *
FROM geolocation;

SELECT COUNT(*) FROM geolocation_clean;

-- ***********************************************************************         ********************************************************************************
 
-- 2) تجميع geolocation على مستوى الزيب كود

-- 1) حذف الجدول القديم لو موجود عشان ننظف الدنيا
DROP TABLE IF EXISTS geolocation_clean;

-- 2) إنشاء الجدول النهائي المجمع والنظيف مباشرة من الجدول الأصلي geolocation
CREATE TABLE geolocation_clean AS
WITH coords AS (
    -- حساب متوسط الإحداثيات لكل كود بريدي داخل حدود البرازيل فقط
    SELECT
        geolocation_zip_code_prefix AS zip_code_prefix,
        AVG(geolocation_lat) AS lat,
        AVG(geolocation_lng) AS lng
    FROM geolocation
    WHERE geolocation_lat BETWEEN -33.75 AND 5.27
      AND geolocation_lng BETWEEN -73.99 AND -34.79
    GROUP BY geolocation_zip_code_prefix
),
city_rank AS (
    -- اختيار المدينة والولاية الأكثر تكراراً لكل كود بريدي بدقة
    SELECT
        geolocation_zip_code_prefix AS zip_code_prefix,
        geolocation_city AS city,
        geolocation_state AS state,
        ROW_NUMBER() OVER (
            PARTITION BY geolocation_zip_code_prefix
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM geolocation
    GROUP BY geolocation_zip_code_prefix, geolocation_city, geolocation_state
)
-- دمج النتائج معاً وحفظها بداخل الجدول الجديد geolocation_clean
SELECT 
    c.zip_code_prefix, 
    c.lat, 
    c.lng, 
    r.city, 
    r.state
FROM coords c
JOIN city_rank r
  ON r.zip_code_prefix = c.zip_code_prefix 
 WHERE r.rn = 1;

SELECT zip_code_prefix, COUNT(*) FROM geolocation_clean
GROUP BY zip_code_prefix HAVING COUNT(*) > 1;   -- لازم ترجع صفر صفوف

-- *********************************************************************              *************************************************************************************

-- 3) حذف التكرار في order_reviews

CREATE TABLE order_reviews_clean (
    review_id VARCHAR(32) NOT NULL,
    order_id VARCHAR(32) NOT NULL,
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

INSERT INTO order_reviews_clean
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY review_answer_timestamp DESC
           ) AS rn
    FROM order_reviews
)

SELECT review_id, order_id, review_score,
       review_comment_title, review_comment_message,
       review_creation_date, review_answer_timestamp
FROM ranked
WHERE rn = 1;

SELECT order_id FROM order_reviews_clean GROUP BY order_id HAVING COUNT(*) > 1;  -- صفر صفوف

-- ***************************************************************                   *********************************************************

-- 4) فحص الـ Referential Integrity

SELECT 'orders without items' AS check_name, COUNT(*) AS cnt
FROM orders o LEFT JOIN order_items i ON i.order_id = o.order_id
WHERE i.order_id IS NULL
UNION ALL
SELECT 'orders without payments', COUNT(*)
FROM orders o LEFT JOIN order_payments p ON p.order_id = o.order_id
WHERE p.order_id IS NULL
UNION ALL
SELECT 'orders without review', COUNT(*)
FROM orders o LEFT JOIN order_reviews_clean r ON r.order_id = o.order_id
WHERE r.order_id IS NULL
UNION ALL
SELECT 'products with category missing from translation', COUNT(*)
FROM products p
LEFT JOIN product_category_translation t
       ON t.product_category_name = p.product_category_name
WHERE p.product_category_name IS NOT NULL AND t.product_category_name IS NULL
UNION ALL
SELECT 'customers whose zip is not in geolocation', COUNT(*)
FROM customers c LEFT JOIN geolocation_clean g
       ON g.zip_code_prefix = c.customer_zip_code_prefix
WHERE g.zip_code_prefix IS NULL
UNION ALL
SELECT 'sellers whose zip is not in geolocation', COUNT(*)
FROM sellers s LEFT JOIN geolocation_clean g
       ON g.zip_code_prefix = s.seller_zip_code_prefix
WHERE g.zip_code_prefix IS NULL;

-- فحص إضافي لحالات الأوردرات التي لا تحتوي على عناصر
SELECT o.order_status, COUNT(*) AS cnt
FROM orders o LEFT JOIN order_items i ON i.order_id = o.order_id
WHERE i.order_id IS NULL
GROUP BY o.order_status;

-- **********************************************************************             *******************************************************************

-- 5) إصلاح الزيب كود (رجوع الصفر في الأول)

-- 1) تعديل نوع الأعمدة في MySQL باستخدام MODIFY COLUMN
ALTER TABLE customers MODIFY COLUMN customer_zip_code_prefix VARCHAR(5);
ALTER TABLE sellers MODIFY COLUMN seller_zip_code_prefix VARCHAR(5);
ALTER TABLE geolocation_clean MODIFY COLUMN zip_code_prefix VARCHAR(5);

-- 2) إضافة الأصفار الناقصة في البداية لتتكون من 5 خانات بالضبط
UPDATE customers 
SET customer_zip_code_prefix = LPAD(customer_zip_code_prefix, 5, '0');

UPDATE sellers 
SET seller_zip_code_prefix = LPAD(seller_zip_code_prefix, 5, '0');

UPDATE geolocation_clean 
SET zip_code_prefix = LPAD(zip_code_prefix, 5, '0');

SELECT COUNT(*) 
FROM customers 
WHERE LENGTH(customer_zip_code_prefix) < 5;

-- **************************************************************                 ******************************************************************

-- 6) تصحيح payment_installments = 0 للـ credit_card

-- 1) إنشاء الجدول النظيف ونسخ البيانات دفعة واحدة
CREATE TABLE order_payments_clean AS
SELECT * FROM order_payments;

-- 2) تعديل القيم الخاطئة (اللي دافعين كرت وأقساطهم صفر نخليها 1)
UPDATE order_payments_clean
SET payment_installments = 1
WHERE payment_type = 'credit_card' AND payment_installments = 0;

-- *************************************************************                ********************************************************************************

-- 7) not_defined وقيم الدفع الصفرية

SELECT p.order_id, p.payment_type, p.payment_value, o.order_status
FROM order_payments_clean p
JOIN orders o ON o.order_id = p.order_id
WHERE p.payment_type = 'not_defined' OR p.payment_value = 0;

-- 1) إضافة عمود الـ Flag للجدول النظيف (بنستخدم TINYINT كبديل ممتاز وآمن للـ BIT)
ALTER TABLE order_payments_clean 
ADD COLUMN flag_zero_or_undefined TINYINT NOT NULL DEFAULT 0;

-- 2) تحديث القيم وتفعيل العلم (Flag = 1) للأوردرات اللي فيها مشاكل
UPDATE order_payments_clean
SET flag_zero_or_undefined = 1
WHERE payment_type = 'not_defined' OR payment_value = 0;

SELECT flag_zero_or_undefined, COUNT(*) AS count_orders
FROM order_payments_clean
GROUP BY flag_zero_or_undefined;

-- *************************************************************************                              ***********************************************************

-- 8) مقارنة مجموع الدفع بمجموع (السعر + الشحن)

CREATE TABLE payment_mismatch AS
WITH item_tot AS (
    SELECT order_id, SUM(price + freight_value) AS items_total
    FROM order_items
    GROUP BY order_id
),
pay_tot AS (
    SELECT order_id, SUM(payment_value) AS paid_total
    FROM order_payments_clean
    GROUP BY order_id
)
SELECT i.order_id, i.items_total, p.paid_total,
       ABS(i.items_total - p.paid_total) AS diff
FROM item_tot i
JOIN pay_tot p ON p.order_id = i.order_id
WHERE ABS(i.items_total - p.paid_total) > 0.01;

-- ************************************************************************                   ******************************************************************************

-- 9) الترجمة الناقصة والفئات الفاضية

-- 1) إضافة الفئات الناقصة لجدول الترجمة عندك (تأكدي من اسم الجدول product_category_translation)
INSERT INTO product_category_translation (product_category_name, product_category_name_english)
VALUES ('pc_gamer', 'pc_gamer'),
       ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparers'),
       ('unknown', 'unknown');

-- 2) إنشاء الجدول النظيف products_clean ونسخ الداتا دفعة واحدة بـ MySQL syntax
CREATE TABLE products_clean AS
SELECT * FROM products;

-- 3) تحديث القيم الفاضية أو الـ NULL إلى 'unknown'
UPDATE products_clean
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL OR product_category_name = '';









