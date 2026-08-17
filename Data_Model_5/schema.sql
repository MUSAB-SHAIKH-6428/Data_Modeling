-- Change the schema acc to req we have seen

CREATE TABLE student (
    student_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
CREATE TABLE course (
    course_id BIGSERIAL PRIMARY KEY,
    course_name VARCHAR(150) NOT NULL
);
CREATE TABLE module (
    module_id BIGSERIAL PRIMARY KEY,
    course_id BIGINT NOT NULL,
    module_name VARCHAR(150) NOT NULL,

    CONSTRAINT fk_module_course
        FOREIGN KEY (course_id)
        REFERENCES course(course_id)
);

CREATE TABLE lesson (
    lesson_id BIGSERIAL PRIMARY KEY,
    module_id BIGINT NOT NULL,
    lesson_name VARCHAR(150) NOT NULL,

    CONSTRAINT fk_lesson_module
        FOREIGN KEY (module_id)
        REFERENCES module(module_id)
);

CREATE TABLE enrollment (
    enrollment_id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    stage VARCHAR(30) NOT NULL,

    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id)
        REFERENCES student(student_id),

    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id)
        REFERENCES course(course_id)
);




CREATE TABLE progress (
    progress_id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL,
    lesson_id BIGINT NOT NULL,
    status VARCHAR(30) NOT NULL,

    CONSTRAINT fk_progress_student
        FOREIGN KEY (student_id)
        REFERENCES student(student_id),

    CONSTRAINT fk_progress_lesson
        FOREIGN KEY (lesson_id)
        REFERENCES lesson(lesson_id)
);

CREATE TABLE assignment (
    assignment_id BIGSERIAL PRIMARY KEY,
    assignment_name VARCHAR(150) NOT NULL
);


CREATE TABLE grade (
    grade_id BIGSERIAL PRIMARY KEY,
    assignment_id BIGINT NOT NULL,
    student_id BIGINT NOT NULL,
    grade NUMERIC(5,2),

    CONSTRAINT fk_grade_assignment
        FOREIGN KEY (assignment_id)
        REFERENCES assignment(assignment_id),

    CONSTRAINT fk_grade_student
        FOREIGN KEY (student_id)
        REFERENCES student(student_id)
);



CREATE TABLE certificate (
    certificate_id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_certificate_student
        FOREIGN KEY (student_id)
        REFERENCES student(student_id),

    CONSTRAINT fk_certificate_course
        FOREIGN KEY (course_id)
        REFERENCES course(course_id)
);