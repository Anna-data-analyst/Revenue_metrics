# Revenue_metrics
This SQL script performs an analysis of the payment behavior of mobile game users. It calculates key revenue metrics such as New_MRR, churned users, expansion revenue, and contraction revenue, and joins this information with user profile data.

## Key Metrics Calculated
The script calculates the following metrics for each user, game, and payment month:

- Total Revenue (Monthly Recurring Revenue): Total revenue by calendar month.
- New MRR: Revenue from users who are paying for the first time.
- New Paid Users: Count of first-time paying users.
- Churned Users: Users who did not return in the following calendar month.
- Churned Revenue: Revenue lost due to churned users.
- Back-from-Churn Revenue: Revenue from users who returned after missing at least one calendar month.
- Back-from-Churn Users: Count of users who returned after a gap.
- Expansion MRR: Increased revenue from returning users compared to the previous month.
- Contraction MRR: Decreased revenue from returning users compared to the previous month.

## Data Sources

- project.games_payments: Contains user payment transactions by game.
- project.games_paid_users: Contains additional user attributes such as language, device type, and age.

## How It Works

The script uses CTEs (monthly_user_revenue, user_revenue_with_month_context, user_mrr_and_churn_analysis) to:

1. Aggregate revenue per user/game/month.
2. Compute monthly deltas using LAG/LEAD window functions.
4. Classify user behavior based on payment continuity:
   - Detect first payments.
   - Identify churn and reactivation.
   - Calculate growth or drop in monthly revenue.

Finally, it joins with the user profile table to enrich the metrics with demographic and device information.

## Use Case

Useful for data analysts and product teams to:
- Monitor user retention and churn.
- Understand revenue dynamics on a monthly basis.
- Identify target cohorts for re-engagement or upsell strategies.
  
## Dashboard
You can view the interactive dashboard here:
https://public.tableau.com/views/Project-Revenuemetrics_/RevenueMetrics?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link
