-- 1. Is the property available for specific check-in/check-out dates?

-- 2. What is the revenue per property per month?

-- 3. How many bookings are pending confirmation?

-- 4. What is the guest satisfaction rating?

-- 5. Can we implement dynamic pricing based on demand?


-- 1. Property Availability Check
select property_name, type, date, 
case 
    WHEN available_rooms > 0 THEN 'Yes'
    ELSE 'No'
END AS availability
from property p
join room_type r
on p.property_id = r.property_id
left join room_type_availability a
on r.room_type_id = a.room_type_id
where (property_name = 'Taj Heights') and (date>='2026-08-20' and date< '2026-08-23')
ORDER BY r.type, a.date;


-- 2. Monthly Revenue per Property
select property_name, 
EXTRACT(month from check_out) as month,
EXTRACT(year from check_out) as year,
sum(booking_amount) as monthly_total
from property p
join booking b 
on p.property_id = b.property_id
where status = 'CONFIRMED'
GROUP BY p.property_name, EXTRACT(MONTH FROM b.check_out), EXTRACT(YEAR FROM b.check_out)
order by month;


-- 3. Pending Bookings Count
SELECT COUNT(*) as pending_bookings
from booking
where status = 'PENDING';


-- 4. Guest Satisfaction Rating
select avg(rating) as rating from review
where rater = 'GUEST';


-- 5. Dynamic Pricing Demand Level Analysis
with cte as (
    select room_type_id, date, ((booked_rooms * 100) / (total_rooms)) as demand_percentage 
    from room_demand
)
select *,
case
	when demand_percentage <= 50 then 'LOW'
	when demand_percentage <= 79 then 'MEDIUM'
	else 'HIGH'
end as demand_level 
from cte;