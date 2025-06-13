WITH monthly_user_revenue AS (
	SELECT 
		date (date_trunc ('month', payment_date)) AS payment_month,
		user_id,
		game_name,
		sum (revenue_amount_usd) AS total_revenue
	FROM project.games_payments gp
	GROUP BY 1, 2, 3),
user_revenue_with_month_context AS 
	(SELECT
		payment_month,
		user_id,
		game_name,
		total_revenue,
		date (payment_month - INTERVAL '1' month) AS previous_calendar_month, 
		date (payment_month + INTERVAL '1' month) AS next_calendar_month,
		LAG (payment_month) OVER (PARTITION BY user_id ORDER BY payment_month) AS previous_paid_month, 
		LAG (total_revenue) OVER (PARTITION BY user_id ORDER BY payment_month) AS previous_paid_month_revenue,
		LEAD (payment_month) OVER (PARTITION BY user_id ORDER BY payment_month) AS next_paid_month 
	FROM monthly_user_revenue),
user_mrr_and_churn_analysis AS
	(SELECT
		payment_month,
		user_id,
		game_name,
		total_revenue,
		CASE WHEN previous_paid_month IS NULL
			THEN total_revenue
		END AS New_MRR,
		CASE WHEN previous_paid_month IS NULL 
			THEN 1
		END AS New_Paid_Users,
		CASE WHEN next_paid_month IS NULL 
			OR next_paid_month != next_calendar_month
				THEN 1
		END AS Churned_Users,
		CASE WHEN next_paid_month IS NULL
			OR next_paid_month != next_calendar_month
				THEN total_revenue
		END AS Churned_Revenue,
		CASE WHEN previous_paid_month IS NOT NULL 
			AND previous_paid_month != previous_calendar_month
         		THEN total_revenue
    	END AS back_from_churn_revenue,
    	CASE WHEN previous_paid_month IS NOT NULL 
			AND previous_paid_month != previous_calendar_month
         		THEN 1
    	END AS back_from_churn_users,
		CASE WHEN next_paid_month IS NULL 
        	OR next_paid_month != next_calendar_month
        	THEN next_calendar_month
    	END AS Churn_Event_Month,
		CASE WHEN previous_paid_month=previous_calendar_month
			AND total_revenue >  previous_paid_month_revenue
			THEN total_revenue -  previous_paid_month_revenue
		END AS Expansion_MRR,
		CASE WHEN previous_paid_month=previous_calendar_month
			AND total_revenue <  previous_paid_month_revenue
			THEN total_revenue -  previous_paid_month_revenue
		END AS Contraction_MRR
	FROM user_revenue_with_month_context)
	SELECT 
		a.payment_month,
		a.user_id,
		a.game_name,
		a.total_revenue,
		a.Churn_Event_Month,
		a.New_MRR,
		a.New_Paid_Users,
		a.Churned_Users,
		a.Churned_Revenue,
		a.Expansion_MRR,
		a.back_from_churn_revenue,
		a.back_from_churn_users,
		a.Contraction_MRR,
		b.language,
		b.has_older_device_model,
		b.age
	FROM user_mrr_and_churn_analysis a
	INNER JOIN project.games_paid_users b 
		ON a.user_id=b.user_id;
