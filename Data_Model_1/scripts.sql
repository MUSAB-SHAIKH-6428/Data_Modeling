select m.member_id, m.member_name, m.email, m.phone, ms.end_date from members m
join membership ms
on m.member_id = ms.member_id
where ms.is_active = true
and ms.end_date between current_date and current_date + interval '30 days';


select c.centre_id, c.centre_name, c.city, count(distinct ca.member_id) as active_member_count from centre c
join class_schedule cs
on c.centre_id = cs.centre_id
join class_attendance ca
on cs.class_schedule_id = ca.class_schedule_id
join membership ms
on ca.member_id = ms.member_id
where ms.is_active = true
group by c.centre_id, c.centre_name, c.city
order by active_member_count desc;


select cl.class_name, count(ca.classattendance_id) as total_attendees from classes cl
join class_schedule cs
on cl.classes_id = cs.classes_id
join class_attendance ca
on cs.class_schedule_id = ca.class_schedule_id
where ca.is_present = true
group by cl.classes_id, cl.class_name
order by total_attendees desc;


with CTE as(
select 
    date_trunc('month', m1.end_date) as expiry_month,
    count(distinct m1.membership_id) as total_expired,
    count(distinct case when m2.membership_id is null then m1.membership_id end) as churned_members
from membership m1
left join membership m2
on m1.member_id = m2.member_id
and m2.joined_date > m1.end_date
where m1.end_date < current_date
group by date_trunc('month', m1.end_date)
)
select 
    expiry_month,
    total_expired,
    churned_members,
    round(churned_members * 100.0 / nullif(total_expired, 0), 2) as churn_rate_percent
from cte
order by expiry_month;


select m.member_id, m.member_name, m.email, max(ca.attendance_date) as last_attended_date from members m
join membership ms
on m.member_id = ms.member_id
left join class_attendance ca
on m.member_id = ca.member_id and ca.is_present = true
where ms.is_active = true
group by m.member_id, m.member_name, m.email
having max(ca.attendance_date) < current_date - interval '30 days'
or max(ca.attendance_date) is null;
