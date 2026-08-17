-- 1. How many students have completed each course?
select
    course_name,
    count(*) as completed_students
from course c
join enrollment e
    on c.course_id = e.course_id
where stage = 'COMPLETED'
group by course_name
order by completed_students desc;


-- 2. What is the course completion rate and average time-to-completion?
select
    course_name,
    round(count(*) filter(where stage = 'COMPLETED') * 100.0 / count(*), 2) as completion_rate,
    avg(completed_at - enrolled_at) filter(where stage = 'COMPLETED') as avg_days_to_completion
from course
join enrollment
    on course.course_id = enrollment.course_id
group by course_name;


-- 3. Which lessons have the highest dropout rate?
select
    lesson_name,
    round(count(*) filter(where status = 'DROPPED') * 100.0 / count(*), 2) as dropout_rate
from lesson l
join progress p
    on l.lesson_id = p.lesson_id
group by lesson_name
order by dropout_rate desc;


-- 4. What is the distribution of grades for a course?
select
    c.course_name,
    case
        when g.grade >= 90 then 'A'
        when g.grade >= 80 then 'B'
        when g.grade >= 70 then 'C'
        when g.grade >= 60 then 'D'
        else 'F'
    end as grade_category,
    count(*) as student_count
from course c
join assignment a
    on c.course_id = a.course_id
join grade g
    on a.assignment_id = g.assignment_id
group by
    c.course_name,
    case
        when g.grade >= 90 then 'A'
        when g.grade >= 80 then 'B'
        when g.grade >= 70 then 'C'
        when g.grade >= 60 then 'D'
        else 'F'
    end
order by
    c.course_name,
    grade_category;


-- 5. Can we identify students at risk of dropping out?
with cte as (
    select
        name,
        round(count(*) filter(where status = 'DROPPED') * 100.0 / count(*), 2) as dropout_percentage
    from student s
    join progress p
        on s.student_id = p.student_id
    group by name
)
select
    *,
    case
        when dropout_percentage < 20 then 'LOW'
        when dropout_percentage >= 20 and dropout_percentage <= 59 then 'MEDIUM'
        else 'HIGH'
    end as risk_level
from cte;
