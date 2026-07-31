SELECT 
    m.member_id, 
    m.name, 
    m.email, 
    m.phone, 
    ms.end_date
FROM members m
JOIN membership ms ON m.member_id = ms.member_id
WHERE ms.is_active = TRUE 
  AND ms.end_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days';

SELECT 
    c.centre_id, 
    c.name AS centre_name, 
    c.city, 
    COUNT(DISTINCT ca.member_id) AS active_member_count
FROM centre c
JOIN class_schedule cs ON c.centre_id = cs.centre_id
JOIN class_attendance ca ON cs.class_schedule_id = ca.class_schedule_id
JOIN membership ms ON ca.member_id = ms.member_id
WHERE ms.is_active = TRUE
GROUP BY c.centre_id, c.name, c.city
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

SELECT 
    TO_CHAR(end_date, 'YYYY-MM') AS month,
    COUNT(CASE WHEN is_active = FALSE THEN 1 END) AS expired_memberships,
    COUNT(*) AS total_memberships,
    ROUND(
        (COUNT(CASE WHEN is_active = FALSE THEN 1 END)::DECIMAL / COUNT(*)) * 100, 2
    ) AS churn_rate_percentage
FROM membership
GROUP BY TO_CHAR(end_date, 'YYYY-MM')
ORDER BY month DESC;

SELECT 
    m.member_id, 
    m.name, 
    m.email, 
    MAX(ca.attendance_date) AS last_attended_date
FROM members m
JOIN membership ms ON m.member_id = ms.member_id
LEFT JOIN class_attendance ca ON m.member_id = ca.member_id AND ca.is_present = TRUE
WHERE ms.is_active = TRUE
GROUP BY m.member_id, m.name, m.email
HAVING MAX(ca.attendance_date) < CURRENT_DATE - INTERVAL '30 days' 
    OR MAX(ca.attendance_date) IS NULL;
