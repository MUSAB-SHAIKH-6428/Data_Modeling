select p.product_id, p.product_name,  sum(i.available_quantity) as total_quantity from product p
join Product_Variant pv
on p.product_id = pv.product_id
join Inventory i
on pv.product_variant_id= i.product_variant_id
GROUP BY p.product_id, p.product_name
order by p.product_id, total_quantity desc;

select c.customer_name, o.order_id, o.Ordered_At, s.Shipment_Status from customer c
join orders o
on c.customer_id = o.customer_id
left join shipment s
on o.order_id = s.order_id
where c.customer_name = 'Rahul Sharma'
order by o.Ordered_At desc


with CTE as(
select p.Product_Name, 
pv.sku, 
w.warehouse_name as warehouse, 
i.available_quantity as Available, 
i.threshold_level as Threshold,
case 
	when i.available_quantity = 0 then 'Out of Stock'
	when i.available_quantity < i.threshold_level then 'Low Stock'
	end as Status
from product p
join Product_Variant pv
on p.product_id = pv.product_id
left join Inventory i
on pv.product_variant_id= i.product_variant_id
left join warehouse w
on i.warehouse_id = w.warehouse_id
)
select * from cte
where status is not null;

select pc.category_name, sum(o.Price * Quantity) as Revenue from product_category pc
join product p
on pc.category_id = p.category_id
join Product_Variant pv
on p.product_id = pv.product_id
join order_item o
on pv.product_variant_id = o.product_variant_id
group by pc.category_name
order by revenue desc

SELECT
    o.order_id,
    w.warehouse_name,
    CASE
        WHEN COUNT(*) = COUNT(
            CASE
                WHEN i.available_quantity >= oi.quantity THEN 1
            END
        )
        THEN 'YES'
        ELSE 'NO'
    END AS can_fulfill
FROM orders o
JOIN customer_address ca
    ON o.ca_id = ca.ca_id
JOIN warehouse w
    ON w.city = ca.customer_city
JOIN order_item oi
    ON o.order_id = oi.order_id
JOIN inventory i
    ON i.product_variant_id = oi.product_variant_id
   AND i.warehouse_id = w.warehouse_id
GROUP BY
    o.order_id,
    w.warehouse_name;
	