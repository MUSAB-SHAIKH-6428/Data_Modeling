select course_name, count(*) as  completed_students from course c
join enrollment e
on c.course_id = e.course_id
where stage = 'COMPLETED'
group by course_name
order by  completed_students desc

select  course_name ,round(count(*)filter(where stage = 'COMPLETED') *100.0  /(count(*)), 2)
as completion_rate, avg(completed_at - enrolled_at) filter(where stage = 'COMPLETED') as avg_days_to_completion
from course
join enrollment
on course.course_id = enrollment.course_id
group by course_name

select lesson_name, round(count(*)filter(where status = 'DROPPED' ) *100.0/count(*), 2) as dropout_rate from lesson l
join progress p
on l.lesson_id =  p.lesson_id
group by lesson_name
order by dropout_rate desc



Select
    c.course_name,
    case
        when g.grade >= 90 THEN 'A'
        when g.grade >= 80 THEN 'B'
        when g.grade >= 70 THEN 'C'
        when g.grade >= 60 THEN 'D'
        ELSE 'F'
    END as grade_category,
    COUNT(*) as student_count
from course c
join assignment a
    on c.course_id = a.course_id
join grade g
    on a.assignment_id = g.assignment_id
GROUP BY
    c.course_name,
    CasE
        when g.grade >= 90 THEN 'A'
        when g.grade >= 80 THEN 'B'
        when g.grade >= 70 THEN 'C'
        when g.grade >= 60 THEN 'D'
        ELSE 'F'
    end
order By
    c.course_name,
    grade_category