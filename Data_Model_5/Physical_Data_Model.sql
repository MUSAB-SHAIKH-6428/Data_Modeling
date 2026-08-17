create table student (
    student_id bigserial primary key,
    name varchar(100) not null
);

create table course (
    course_id bigserial primary key,
    course_name varchar(150) not null
);

create table module (
    module_id bigserial primary key,
    course_id bigint not null,
    module_name varchar(150) not null,

    constraint fk_module_course
        foreign key (course_id)
        references course(course_id)
);

create table lesson (
    lesson_id bigserial primary key,
    module_id bigint not null,
    lesson_name varchar(150) not null,

    constraint fk_lesson_module
        foreign key (module_id)
        references module(module_id)
);

create table enrollment (
    enrollment_id bigserial primary key,
    student_id bigint not null,
    course_id bigint not null,
    stage varchar(30) not null,
    enrolled_at timestamp not null default current_timestamp,
    completed_at timestamp,

    constraint fk_enrollment_student
        foreign key (student_id)
        references student(student_id),

    constraint fk_enrollment_course
        foreign key (course_id)
        references course(course_id),

    constraint uq_student_course
        unique (student_id, course_id),

    constraint chk_enrollment_stage
        check (
            stage in (
                'ENROLLED',
                'IN_PROGRESS',
                'COMPLETED',
                'DROPPED'
            )
        ),

    constraint chk_completion_date
        check (
            completed_at is null
            or completed_at >= enrolled_at
        )
);

create table progress (
    progress_id bigserial primary key,
    student_id bigint not null,
    lesson_id bigint not null,
    status varchar(30) not null,

    constraint fk_progress_student
        foreign key (student_id)
        references student(student_id),

    constraint fk_progress_lesson
        foreign key (lesson_id)
        references lesson(lesson_id),

    constraint uq_student_lesson
        unique (student_id, lesson_id),

    constraint chk_progress_status
        check (
            status in (
                'NOT_STARTED',
                'IN_PROGRESS',
                'COMPLETED',
                'DROPPED'
            )
        )
);

create table assignment (
    assignment_id bigserial primary key,
    course_id bigint not null,
    assignment_name varchar(150) not null,

    constraint fk_assignment_course
        foreign key (course_id)
        references course(course_id)
);

create table grade (
    grade_id bigserial primary key,
    assignment_id bigint not null,
    student_id bigint not null,
    grade numeric(5,2) not null,

    constraint fk_grade_assignment
        foreign key (assignment_id)
        references assignment(assignment_id),

    constraint fk_grade_student
        foreign key (student_id)
        references student(student_id),

    constraint uq_student_assignment
        unique (student_id, assignment_id),

    constraint chk_grade
        check (grade between 0 and 100)
);

create table certificate (
    certificate_id bigserial primary key,
    student_id bigint not null,
    course_id bigint not null,
    issued_at timestamp not null default current_timestamp,

    constraint fk_certificate_student
        foreign key (student_id)
        references student(student_id),

    constraint fk_certificate_course
        foreign key (course_id)
        references course(course_id),

    constraint uq_student_course_certificate
        unique (student_id, course_id)
);
