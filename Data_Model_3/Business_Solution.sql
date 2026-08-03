-- Real-Time Store Inventory Query
-- Checks current available stock for products at a specific store location

SELECT 
    s.store_name,
    p.name AS product_name,
    pv.sku,
    pv.net_quantity,
    i.available_quantity,
    i.reserved_quantity,
    i.threshold_quantity,
    i.last_updated_at
FROM inventory i
JOIN store s ON i.store_id = s.store_id
JOIN product_variant pv ON i.product_variant_id = pv.product_variant_id
JOIN product p ON pv.product_id = p.product_id
WHERE s.store_id = 1 AND i.available_quantity > 0
ORDER BY p.name;


-- Store-Specific Catalog and Pricing Lookup
-- Allows customers to search products and compare store-specific pricing

SELECT 
    p.name AS product_name,
    pv.sku,
    s.store_name,
    sc.price,
    sc.is_available
FROM store_catalog sc
JOIN store s ON sc.store_id = s.store_id
JOIN product_variant pv ON sc.product_variant_id = pv.product_variant_id
JOIN product p ON pv.product_id = p.product_id
WHERE p.name ILIKE '%Milk%'
ORDER BY p.name, sc.price ASC;


-- Load Saved Shopping List with Current Store Pricing
-- Retrieves items from customer's saved list with active prices at the selected store

SELECT 
    sl.shopping_list_name,
    p.name AS product_name,
    sli.quantity,
    sc.price AS unit_price,
    (sli.quantity * sc.price) AS total_item_price
FROM shopping_list sl
JOIN shopping_list_item sli ON sl.shopping_list_id = sli.shopping_list_id
JOIN product_variant pv ON sli.product_variant_id = pv.product_variant_id
JOIN product p ON pv.product_id = p.product_id
JOIN store_catalog sc ON pv.product_variant_id = sc.product_variant_id
WHERE sl.customer_id = 10 AND sc.store_id = 2;


-- Shopper Assignment Query Based on Proximity
-- Finds nearest available shoppers to a store using distance calculation

SELECT 
    shp.shopper_id,
    shp.name AS shopper_name,
    shp.phone,
    sl.latitude AS shopper_lat,
    sl.longitude AS shopper_lng,
    ( 6371 * acos( cos( radians(st.latitude) ) * cos( radians( sl.latitude )) 
    * cos( radians( sl.longitude ) - radians(st.longitude) ) 
    + sin( radians(st.latitude) ) * sin( radians( sl.latitude )))) AS distance_km
FROM shopper shp
JOIN shopper_location sl ON shp.shopper_id = sl.shopper_id
CROSS JOIN store st
WHERE st.store_id = 1 
  AND shp.is_available = TRUE 
  AND shp.is_active = TRUE
ORDER BY distance_km ASC
LIMIT 5;


-- Out-of-Stock Substitution Tracking
-- Tracks pending substitution proposals requiring customer real-time approval
SELECT 
    sub.substitution_id,
    sub.order_item_id,
    c.name AS customer_name,
    p_orig.name AS original_product,
    p_sub.name AS substituted_product,
    sub.substituted_status,
    sub.approved_at
FROM substitution sub
JOIN customer c ON sub.customer_id = c.customer_id
JOIN product_variant pv_orig ON sub.original_product_variant_id = pv_orig.product_variant_id
JOIN product p_orig ON pv_orig.product_id = p_orig.product_id
LEFT JOIN product_variant pv_sub ON sub.substituted_product_variant_id = pv_sub.product_variant_id
LEFT JOIN product p_sub ON pv_sub.product_id = p_sub.product_id
WHERE sub.substituted_status = 'Pending_Approval';


-- Order Lifecycle Tracking & Delivery Summary
-- Monitors order status, shopper assignment, payment details, and ratings
SELECT 
    o.order_id,
    c.name AS customer_name,
    s.store_name,
    shp.name AS shopper_name,
    o.order_status,
    o.ordered_at,
    o.order_total,
    d.tracking_number,
    d.delivered_at,
    d.rating,
    d.review
FROM orders o
JOIN customer c ON o.customer_id = c.customer_id
JOIN store s ON o.store_id = s.store_id
LEFT JOIN shopper shp ON o.shopper_id = shp.shopper_id
LEFT JOIN delivery d ON o.order_id = d.order_id
ORDER BY o.ordered_at DESC;


-- Shopper Efficiency Analytics
-- Measures total completed orders and average items picked per shopper
SELECT 
    shp.shopper_id,
    shp.name AS shopper_name,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    COALESCE(SUM(oi.quantity), 0) AS total_items_picked,
    ROUND(AVG(oi_summary.total_items_per_order), 2) AS avg_items_picked_per_order
FROM shopper shp
JOIN orders o ON shp.shopper_id = o.shopper_id
JOIN order_item oi ON o.order_id = oi.order_id
JOIN (
    SELECT order_id, SUM(quantity) AS total_items_per_order
    FROM order_item
    GROUP BY order_id
) oi_summary ON o.order_id = oi_summary.order_id
WHERE o.order_status = 'delivered'
GROUP BY shp.shopper_id, shp.name
ORDER BY completed_orders DESC;
