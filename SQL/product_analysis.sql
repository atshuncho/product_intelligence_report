-- 1. Which products have the highest churn rate over time?

CREATE TABLE IF NOT EXISTS product_performance_v2 AS SELECT *, approvals + rejections AS applications FROM
    product_performance
;

SELECT 
    product_type,
    SUM(churned_customers) AS total_churned,
    SUM(applications) AS total_users,
    ROUND(100.0 * SUM(churned_customers) / NULLIF(SUM(applications), 0),
            2) AS churn_rate_pct
FROM
    product_performance_v2
GROUP BY product_type
ORDER BY churn_rate_pct DESC;


-- 2. Which products have the highest repeat usage rate?

SELECT 
    rep.*,
    non.amount_of_non_repeat_users,
    (amount_of_repeat_users / (amount_of_repeat_users + amount_of_non_repeat_users)) * 100 AS return_percentage
FROM
    (SELECT 
        product_type, COUNT(customer_id) AS amount_of_repeat_users
    FROM
        (SELECT 
        product_type, customer_id
    FROM
        product_usage
    GROUP BY product_type , customer_id
    HAVING COUNT(DISTINCT date) > 1) AS repeat_customers
    GROUP BY product_type) rep
        JOIN
    (SELECT 
        product_type,
            COUNT(customer_id) AS amount_of_non_repeat_users
    FROM
        (SELECT 
        product_type, customer_id
    FROM
        product_usage
    GROUP BY product_type , customer_id
    HAVING COUNT(DISTINCT date) = 1) AS non_repeat_users
    GROUP BY product_type) non ON rep.product_type = non.product_type;
    
-- 3. How does the approval rate vary by product type?
	
SELECT 
    product_type,
    AVG(approvals) AS average_amount_of_approvals,
    SUM(applications) AS amount_of_applications,
    ROUND(100.0 * SUM(approvals) / NULLIF(SUM(applications), 0),
            2) AS approval_rate_pct
FROM
    product_performance_v2
GROUP BY product_type;
-- 4. Which customer segments have the highest app engagement?
CREATE TABLE IF NOT EXISTS customer_and_app_session_details (SELECT app.session_id,
    app.customer_id,
    app.login_time,
    app.logout_time,
    app.features_used,
    app.session_channel,
    app.session_duration_min,
    c.signup_date,
    c.age,
    c.gender,
    c.region,
    c.account_type FROM
    app_sessions_v2 app
        LEFT JOIN
    customers c ON app.customer_id = c.customer_id);	
-- by gender
SELECT 
    *
FROM
    customer_and_app_session_details;
SELECT 
    gender,
    session_channel,
    AVG(session_duration_min) AS average_time_spent_in_minutes
FROM
    customer_and_app_session_details
GROUP BY gender , session_channel
ORDER BY average_time_spent_in_minutes DESC;

-- by region
SELECT 
    region,
    session_channel,
    AVG(session_duration_min) AS average_time_spent_in_minutes
FROM
    customer_and_app_session_details
GROUP BY region , session_channel
ORDER BY average_time_spent_in_minutes;

-- account_type
SELECT 
    account_type,
    session_channel,
    AVG(session_duration_min) AS average_time_spent_in_minutes
FROM
    customer_and_app_session_details
GROUP BY account_type , session_channel
ORDER BY average_time_spent_in_minutes;

-- by age 
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18–25'
        WHEN age BETWEEN 26 AND 35 THEN '26–35'
        WHEN age BETWEEN 36 AND 45 THEN '36–45'
        WHEN age BETWEEN 46 AND 60 THEN '46–60'
        ELSE '60+'
    END AS age_group,
    session_channel,
    AVG(session_duration_min) AS average_time_spent_in_minutes
FROM
    customer_and_app_session_details
GROUP BY age_group , session_channel
ORDER BY age_group What features are most common in long sessions?
SELECT
  'budgeting' AS feature,
  COUNT(*) AS times_used,
  ROUND(AVG(session_duration_min), 2) AS avg_session_duration
FROM app_sessions_v2
WHERE features_used LIKE '%budgeting%'

UNION ALL

SELECT
  'loan_calc' AS feature,
  COUNT(*) AS times_used,
  ROUND(AVG(session_duration_min), 2) AS avg_session_duration
FROM app_sessions_v2
WHERE features_used LIKE '%loan_calc%'

UNION ALL

SELECT
  'savings_pot' AS feature,
  COUNT(*) AS times_used,
  ROUND(AVG(session_duration_min), 2) AS avg_session_duration
FROM app_sessions_v2
WHERE features_used LIKE '%savings_pot%'

UNION ALL

SELECT
  'notifications' AS feature,
  COUNT(*) AS times_used,
  ROUND(AVG(session_duration_min), 2) AS avg_session_duration
FROM app_sessions_v2
WHERE features_used LIKE '%notifications%'

ORDER BY avg_session_duration DESC;
    
-- 6.Do mobile users spend more time than web users?
SELECT
	session_channel, SUM(session_duration_min) AS total_usage_minutes
FROM
	customer_and_app_session_details
GROUP BY 
	session_channel
ORDER BY total_usage_minutes;
    
-- 7.Correlation between resolution time and satisfaction score?
SELECT
	satisfaction_score, AVG(resolution_time_hr) AS average_resolution_time
FROM
	support_tickets
GROUP BY 
	satisfaction_score
ORDER BY 
	satisfaction_score DESC; -- shows a negative correlation, as the average time of resolution decreases, the satisfaction score increases as expected 

-- 8.Customers most likely to upgrade from Free to Premium
-- first need to see what is unique about premium users.
-- see if age is an indication

SELECT
    account_type,
    AVG(age) AS average_age_of_user_with_account_type
FROM
	customers
GROUP BY account_type;
-- The avergae age is not a clear indication as the average age of a free user is 43 and the average for a premium user is 46

-- Next I will try and see if premium users tend to use the app more (meaning they will have more session_id's

    
SELECT
    c.account_type,
    COUNT(app.session_id) / COUNT(DISTINCT c.customer_id) AS avg_sessions_per_user
FROM
	app_sessions_v2 app
JOIN
	customers c ON app.customer_id = c.customer_id
GROUP BY
    c.account_type;
-- This did not show a clear correlation as averages were very similar. 
-- Now I will check based on support interactions (e.g., more tickets opened??
SELECT
    c.account_type,
    COUNT(st.ticket_id) / COUNT(DISTINCT c.customer_id) AS avg_tickets_per_account_type
FROM 
	customers c
		LEFT JOIN 
	support_tickets st ON c.customer_id = st.customer_id
GROUP BY
	c.account_type
;

-- The above was also not very helpful as there is only a slight increase in the average tickets premium users create. 
-- I will now see if there is a correlation between the types of ticket users create
SELECT
  c.account_type,
  st.category,
  COUNT(*) AS ticket_count
FROM
  customers c
JOIN
  support_tickets st ON c.customer_id = st.customer_id
GROUP BY
  c.account_type, st.category
ORDER BY
	ticket_count DESC;

-- This shows that premium users are more likely to ask for product feature requests than free users
-- Below I will see which users on the free tier have requested feature requests and have created the most amount of tickets.
SELECT
  c.*,
  st.*
FROM
  customers c
JOIN
  support_tickets st ON c.customer_id = st.customer_id
; 
 
 SELECT
  c.account_type,
  c.customer_id,
  st.category,
  COUNT(st.ticket_id) AS amount_of_feature_requests
FROM
  customers c
JOIN
  support_tickets st ON c.customer_id = st.customer_id
WHERE st.category = 'Product Feature' AND account_type = 'Free'
GROUP BY c.account_type, c.customer_id, st.category
ORDER BY amount_of_feature_requests DESC
LIMIT 10 
;




