-- Number of jobs reviewed: Amount of jobs reviewed over time.
-- Your task: Calculate the number of jobs reviewed per hour per day for November 2020?

SELECT 
    ds,
    COUNT(job_id) * 3600 / SUM(time_spent) AS jobs_per_hour
FROM
    case_study_1
WHERE
    ds BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY ds

-- Throughput: It is the no. of events happening per second.
-- Your task: Let’s say the above metric is called throughput. Calculate 7 day rolling average of throughput? For throughput, do you prefer daily metric or 7-day rolling and why?

SELECT ds, throughput_per_day, sum(numjobs) over (order by ds rows between 6 preceding and current row)/sum(timespent) over (order by ds rows between 6 preceding and current row) as throughput_rolling_7d
from
(SELECT 
    ds, COUNT(job_id) AS numjobs, SUM(time_spent) AS timespent, COUNT(job_id)/SUM(time_spent) as throughput_per_day
FROM
    case_study_1
WHERE
    ds BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY ds
ORDER BY ds) as a

-- Percentage share of each language: Share of each language for different contents.
-- Your task: Calculate the percentage share of each language in the last 30 days?

WITH a as (
SELECT 
    language, COUNT(job_id) AS numjobs
FROM
    case_study_1
WHERE
    ds BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY language
),
b as (
SELECT 
    language, SUM(num_jobs) AS total_jobs
FROM
    (SELECT 
        language, COUNT(job_id) num_jobs
    FROM
        case_study_1
    WHERE
        ds BETWEEN '2020-11-01' AND '2020-11-30'
    GROUP BY language) b
)
SELECT 
    a.language,
    (numjobs * 100 / total_jobs) AS share_of_each_language,
    total_jobs
FROM
    a
        CROSS JOIN
    b
ORDER BY share_of_each_language

-- Duplicate rows: Rows that have the same value present in them.
-- Your task: Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?

WITH duplicate_num as 
(
SELECT *,
RANK() over(partition by job_id order by event) ranknum
FROM case_study_1
)
SELECT 
    *
FROM
    duplicate_num
WHERE
    ranknum > 1

-- User Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service.
-- Your task: Calculate the weekly user engagement?

SELECT 
    WEEK(occurred_at) AS week_num,
    COUNT(DISTINCT user_id) AS weekly_active_user
FROM
    events
WHERE
    event_type = 'engagement'
GROUP BY week_num
ORDER BY week_num

-- User Growth: Amount of users growing over time for a product.
-- Your task: Calculate the user growth for product?

select date_of_month, all_users, sum(all_users) over (order by date_of_month) as Cum_all_users from
(
SELECT 
    DAY(created_at) AS date_of_month, COUNT(*) AS all_users
FROM
    users
WHERE
    state = 'active'
GROUP BY date_of_month
ORDER BY date_of_month
) a

Weekly Retention: Users getting retained weekly after signing-up for a product.
Your task: Calculate the weekly retention of users-sign up cohort?

SELECT 
    COUNT(DISTINCT CASE
            WHEN z.age_of_user > 35 THEN z.user_id
            ELSE NULL
        END) AS '5+ weeks',
    COUNT(DISTINCT CASE
            WHEN
                z.age_of_user < 35
                    AND z.age_of_user <= 28
            THEN
                z.user_id
            ELSE NULL
        END) AS '5 weeks',
    COUNT(DISTINCT CASE
            WHEN
                z.age_of_user < 28
                    AND z.age_of_user <= 21
            THEN
                z.user_id
            ELSE NULL
        END) AS '4 weeks',
    COUNT(DISTINCT CASE
            WHEN
                z.age_of_user < 21
                    AND z.age_of_user <= 14
            THEN
                z.user_id
            ELSE NULL
        END) AS '3 weeks',
    COUNT(DISTINCT CASE
            WHEN
                z.age_of_user < 14
                    AND z.age_of_user <= 7
            THEN
                z.user_id
            ELSE NULL
        END) AS '2 weeks',
    COUNT(DISTINCT CASE
            WHEN z.age_of_user < 7 AND z.age_of_user <= 0 THEN z.user_id
            ELSE NULL
        END) AS 'Less than a week'
FROM
    (SELECT 
        u.user_id,
            DATEDIFF(e.occurred_at, u.activated_at) AS age_of_user
    FROM
        users u
    LEFT JOIN events e ON u.user_id = e.user_id
    WHERE
        e.event_type = 'engagement'
    GROUP BY user_id
    ORDER BY user_id) z

-- Weekly Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service weekly.
-- Your task: Calculate the weekly engagement per device?

SELECT 
	device,
    WEEK(occurred_at) AS week_num,
    COUNT(DISTINCT user_id) AS weekly_active_user
FROM
    events
WHERE
    event_type = 'engagement'
GROUP BY device, week_num
ORDER BY week_num

-- Email Engagement: Users engaging with the email service.
-- Your task: Calculate the email engagement metrics?

SELECT 
    WEEK(occurred_at) AS week_num, action, COUNT(action) as No_of_instances
FROM
    email_events
GROUP BY week_num , action
order by week_num