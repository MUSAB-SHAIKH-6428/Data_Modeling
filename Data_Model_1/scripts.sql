SELECT 
    m.member_id, 
    m.member_name, 
    m.email, 
    m.phone, 
    ms.end_date
FROM members m
JOIN membership ms ON m.member_id = ms.member_id
WHERE ms.is_active = TRUE 
  AND ms.end_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days';

SELECT 
    c.centre_id, 
    c.centre_name,
    c.city, 
    COUNT(DISTINCT ca.member_id) AS active_member_count
FROM centre c
JOIN class_schedule cs ON c.centre_id = cs.centre_id
JOIN class_attendance ca ON cs.class_schedule_id = ca.class_schedule_id
JOIN membership ms ON ca.member_id = ms.member_id
WHERE ms.is_active = TRUE
GROUP BY c.centre_id, c.centre_name, c.city
ORDER BY active_member_count DESC;

SELECT 
    cl.class_name, 
    COUNT(ca.classattendance_id) AS total_attendees
FROM classes cl
JOIN class_schedule cs ON cl.classes_id = cs.classes_id
JOIN class_attendance ca ON cs.class_schedule_id = ca.class_schedule_id
WHERE ca.is_present = TRUE
GROUP BY cl.classes_id, cl.class_name
ORDER BY total_attendees DESC;

WITH expired_memberships AS (
    SELECT
        membership_id,
        member_id,
        end_date,
        DATE_TRUNC('month', end_date) AS expiry_month
    FROM membership
),
renewed AS (
    SELECT DISTINCT
        m1.membership_id
    FROM membership m1
    JOIN membership m2
        ON m1.member_id = m2.member_id
       AND m2.start_date > m1.end_date
),
churn_rate AS (
SELECT
    e.expiry_month, 
    COUNT(*) AS total_expired,
    COUNT(*) FILTER (
        WHERE e.membership_id NOT IN
        (SELECT membership_id FROM renewed)
    ) AS churned_members  
FROM expired_memberships e 
GROUP BY e.expiry_month)
SELECT
    expiry_month,
    total_expired,
    churned_members,
    ROUND(
        churned_members * 100.0 /
        NULLIF(total_expired,0),
        2
    ) AS churn_rate_percent
FROM churn_rate
ORDER BY expiry_month;

SELECT 
    m.member_id, 
    m.member_name, 
    m.email, 
    MAX(ca.attendance_date) AS last_attended_date
FROM members m
JOIN membership ms ON m.member_id = ms.member_id
LEFT JOIN class_attendance ca ON m.member_id = ca.member_id AND ca.is_present = TRUE
WHERE ms.is_active = TRUE
GROUP BY m.member_id, m.member_name, m.email
HAVING MAX(ca.attendance_date) < CURRENT_DATE - INTERVAL '30 days' 
    OR MAX(ca.attendance_date) IS NULL;
