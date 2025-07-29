# 📊 Product Intelligence Analysis – SQL Project

This SQL project explores key business metrics and customer behavior using structured queries. The dataset simulates product usage, customer engagement, and support feedback within a financial application.

---

## 📁 Project Structure

- `product_performance.sql`  
  Contains SQL queries used to analyze churn, approval rates, repeat usage, engagement, and support behavior.

---

## 🔍 Key Business Questions Answered

1. **Which products have the highest churn rate over time?**  
   Calculates churn rate per product type by analyzing approvals, rejections, and churned customers.

2. **Which products have the highest repeat usage rate?**  
   Identifies products frequently used by customers over multiple days.

3. **How does the approval rate vary by product type?**  
   Examines the success rate of applications per product.

4. **Which customer segments have the highest app engagement?**  
   Breaks down average session duration by:
   - Gender
   - Region
   - Account type
   - Age group

5. **What features are most common in long sessions?**  
   Compares average session time when specific features (e.g. budgeting, savings pot) are used. Also used an undesrtanding of unstructured data.

6. **Do mobile users spend more time than web users?**  
   Compares total usage minutes by session channel.

7. **Is there a correlation between resolution time and satisfaction score?**  
   Investigates if longer support resolution times reduce satisfaction.

8. **Which customers are most likely to upgrade from Free to Premium?**  
   Explores behavioral and demographic traits of premium users and identifies free users with premium-like engagement.

---

## 🛠 Tools Used

- **SQL**
  - Aggregations (SUM, AVG, COUNT)
  - Filtering and subqueries
  - Joins (LEFT JOIN, INNER JOIN)
  - CASE statements for segmentation
  - Temporary tables (via `CREATE TABLE IF NOT EXISTS`)

---

## 📈 Sample Metrics Generated

| Metric | Example |
|--------|---------|
| Churn Rate % | 26% |
| Approval Rate % | 84.11% |
| Total Applications | 16,000+ |
| Avg Session Duration | by age, gender, region, etc. |
| Feature Usage Ranking | Budgeting, Loan Calc, Notifications... |

---

## 🎯 Business Impact

The insights from this SQL analysis could be used to:
- Improve **product design** by understanding user churn and feature engagement
- Optimize **customer support** by linking resolution time to satisfaction
- Drive **conversion** strategies by targeting free-tier users likely to upgrade

---

## 🚀 How to Use

1. Open the SQL file in BigQuery, MySQL, or your preferred SQL engine.
2. Run section by section to explore each insight.
3. Modify filters (e.g. date range, account_type) to personalize the analysis.

---

## 💡 Future Work

- Visualize results in Power BI or Looker Studio
- Add time-series tracking for churn and approval trends
- Integrate machine learning predictions (e.g. churn risk)
