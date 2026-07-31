CREATE DATABASE gym_management;

CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gender VARCHAR(10),
    phone VARCHAR(15) UNIQUE,
    email VARCHAR(100) UNIQUE,
    date_of_birth DATE NOT NULL,
    date_of_joining DATE NOT NULL
);

CREATE TABLE membership_plan (
    membership_plan_id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    time_period INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE membership (
    membership_id SERIAL PRIMARY KEY,
    member_id INT NOT NULL,
    membership_plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_member
        FOREIGN KEY(member_id)
        REFERENCES members(member_id),

    CONSTRAINT fk_plan
        FOREIGN KEY(membership_plan_id)
        REFERENCES membership_plan(membership_plan_id)
);

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    membership_id INT UNIQUE NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20),
    mode VARCHAR(20),

    CONSTRAINT fk_membership
        FOREIGN KEY(membership_id)
        REFERENCES membership(membership_id)
);

CREATE TABLE centre (
    centre_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    branch_name VARCHAR(100),
    city VARCHAR(50),
    intake_capacity INT
);

CREATE TABLE trainer (
    trainer_id SERIAL PRIMARY KEY,
    trainer_name VARCHAR(100) NOT NULL,
    centre_id INT NOT NULL,
    phone VARCHAR(15),
    gender VARCHAR(10),

    CONSTRAINT fk_centre
        FOREIGN KEY(centre_id)
        REFERENCES centre(centre_id)
);

CREATE TABLE classes (
    classes_id SERIAL PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL,
    duration INTEGER NOT NULL
);

CREATE TABLE class_schedule (
    class_schedule_id SERIAL PRIMARY KEY,

    schedule_date DATE NOT NULL,

    schedule_time TIME NOT NULL,

    capacity INT NOT NULL,

    trainer_id INT NOT NULL,

    classes_id INT NOT NULL,

    centre_id INT NOT NULL,

    CONSTRAINT fk_schedule_trainer
        FOREIGN KEY(trainer_id)
        REFERENCES trainer(trainer_id),

    CONSTRAINT fk_schedule_class
        FOREIGN KEY(classes_id)
        REFERENCES classes(classes_id),

    CONSTRAINT fk_schedule_centre
        FOREIGN KEY(centre_id)
        REFERENCES centre(centre_id)
);

CREATE TABLE class_attendance (

    classattendance_id SERIAL PRIMARY KEY,

    attendance_date DATE NOT NULL,

    class_schedule_id INT NOT NULL,

    member_id INT NOT NULL,

    is_present BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_attendance_schedule
        FOREIGN KEY(class_schedule_id)
        REFERENCES class_schedule(class_schedule_id),

    CONSTRAINT fk_attendance_member
        FOREIGN KEY(member_id)
        REFERENCES members(member_id)
);

ALTER TABLE membership
ADD CONSTRAINT chk_membership_dates
CHECK (end_date > start_date);

ALTER TABLE membership_plan
ADD CONSTRAINT chk_price
CHECK(price > 0);

ALTER TABLE centre
ADD CONSTRAINT chk_capacity
CHECK(intake_capacity > 0);

ALTER TABLE class_schedule
ADD CONSTRAINT chk_class_capacity
CHECK(capacity > 0);

ALTER TABLE classes
ADD CONSTRAINT chk_duration
CHECK(duration > 0);

CREATE INDEX idx_membership_member
ON membership(member_id);

CREATE INDEX idx_membership_plan
ON membership(membership_plan_id);

CREATE INDEX idx_payment_membership
ON payment(membership_id);

CREATE INDEX idx_trainer_centre
ON trainer(centre_id);

CREATE INDEX idx_schedule_trainer
ON class_schedule(trainer_id);

CREATE INDEX idx_schedule_class
ON class_schedule(classes_id);

CREATE INDEX idx_schedule_centre
ON class_schedule(centre_id);

CREATE INDEX idx_attendance_member
ON class_attendance(member_id);

CREATE INDEX idx_attendance_schedule
ON class_attendance(class_schedule_id);

CREATE INDEX idx_membership_enddate
ON membership(end_date);

CREATE INDEX idx_attendance_date
ON class_attendance(attendance_date);