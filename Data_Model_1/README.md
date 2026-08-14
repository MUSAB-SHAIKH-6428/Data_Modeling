# Fitness Gym Chain Database & Data Model

## Problem Overview
Relational database schema for a multi-location fitness gym chain managing members, membership plans, subscriptions, payments, gym centres, trainers, classes, schedules, and attendance.

## 1. Physical Data Model (ERD)

![Data Model](DATA_MODEL.png)

## Schema Architecture

The database model consists of 9 core tables:

| Table Name | Description | Key Attributes |
| :--- | :--- | :--- |
| **`members`** | Master table for member profile details | `member_id`, `name`, `email`, `phone`, `date_of_joining` |
| **`membership_plan`** | Plan definitions (e.g., Monthly, Annual) | `membership_plan_id`, `type`, `time_period`, `price` |
| **`membership`** | Member subscription records | `membership_id`, `member_id`, `membership_plan_id`, `start_date`, `end_date`, `is_active` |
| **`payment`** | Financial transactions for memberships | `payment_id`, `membership_id`, `payment_date`, `amount`, `status`, `mode` |
| **`centre`** | Gym location facilities | `centre_id`, `name`, `branch_name`, `city`, `intake_capacity` |
| **`trainer`** | Fitness trainers assigned to centres | `trainer_id`, `trainer_name`, `centre_id`, `phone` |
| **`classes`** | Fitness class definitions | `classes_id`, `class_name`, `duration` |
| **`class_schedule`** | Scheduled sessions across locations | `class_schedule_id`, `schedule_date`, `schedule_time`, `capacity`, `trainer_id`, `classes_id`, `centre_id` |
| **`class_attendance`** | Attendance logs per scheduled session | `classattendance_id`, `attendance_date`, `class_schedule_id`, `member_id`, `is_present` |

## Key Business Queries
All SQL solutions are in [`scripts.sql`](scripts.sql):

1. **Approaching Expirations:** Identifies active memberships expiring within the next 30 days.
2. **Active Members per Location:** Counts active members across each gym centre.
3. **Class Popularity:** Ranks fitness classes by total confirmed attendance.
4. **Monthly Churn Rate:** Calculates the percentage of memberships expiring without renewal per month.
5. **Inactive Members (30+ Days):** Flags members with no recorded attendance in the last 30+ days.