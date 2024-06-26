--1.What are the top 5 brands by receipts scanned for most recent month?
WITH RecentMonthReceipts AS (
    SELECT 
        r.id AS receipt_id, 
        r.create_Date, 
        b.name AS brand_name
    FROM 
        Receipts r
    JOIN 
        ReceiptsItemList ril ON r.id = ril.receipt_id
    JOIN 
        Brands b ON ril.barcode = b.barcode
    WHERE 
        r.create_Date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
        AND r.create_Date < DATE_TRUNC('month', CURRENT_DATE)
)
SELECT 
    brand_name, 
    COUNT(receipt_id) AS receipt_count
FROM 
    RecentMonthReceipts
GROUP BY 
    brand_name
ORDER BY 
    receipt_count DESC
LIMIT 5;


--2.How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?

WITH RecentMonthReceipts AS (
    SELECT 
        r.id AS receipt_id, 
        r.create_Date, 
        b.name AS brand_name
    FROM 
        Receipts r
    JOIN 
        ReceiptsItemList ril ON r.id = ril.receipt_id
    JOIN 
        Brands b ON ril.barcode = b.barcode
    WHERE 
        r.create_Date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
        AND r.create_Date < DATE_TRUNC('month', CURRENT_DATE)
),
PreviousMonthReceipts AS (
    SELECT 
        r.id AS receipt_id, 
        r.create_Date, 
        b.name AS brand_name
    FROM 
        Receipts r
    JOIN 
        ReceiptsItemList ril ON r.id = ril.receipt_id
    JOIN 
        Brands b ON ril.barcode = b.barcode
    WHERE 
        r.create_Date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '2 months'
        AND r.create_Date < DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
)
SELECT 
    brand_name,
    COUNT(receipt_id) AS recent_month_receipt_count
FROM 
    RecentMonthReceipts
GROUP BY 
    brand_name
ORDER BY 
    recent_month_receipt_count DESC
LIMIT 5;

SELECT 
    brand_name,
    COUNT(receipt_id) AS previous_month_receipt_count
FROM 
    PreviousMonthReceipts
GROUP BY 
    brand_name
ORDER BY 
    previous_month_receipt_count DESC
LIMIT 5;


SELECT 
    rewardsReceiptStatus, 
    AVG(totalSpent) AS average_spend
FROM 
    Receipts
WHERE 
    rewardsReceiptStatus IN ('Accepted', 'Rejected')
GROUP BY 
    rewardsReceiptStatus;

--3.When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT 
    rewardsReceiptStatus, 
    AVG(totalSpent) AS average_spend
FROM 
    Receipts
WHERE 
    rewardsReceiptStatus IN ('Accepted', 'Rejected')
GROUP BY 
    rewardsReceiptStatus;

--4.When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT 
    rewardsReceiptStatus, 
    SUM(purchasedItemCount) AS total_items_purchased
FROM 
    Receipts
WHERE 
    rewardsReceiptStatus IN ('Accepted', 'Rejected')
GROUP BY 
    rewardsReceiptStatus;

--5.Which brand has the most spend among users who were created within the past 6 months?
WITH RecentUsers AS (
    SELECT 
        id 
    FROM 
        Users 
    WHERE 
        created_Date >= CURRENT_DATE - INTERVAL '6 months'
),
RecentUserReceipts AS (
    SELECT 
        r.id AS receipt_id, 
        r.totalSpent, 
        ril.barcode
    FROM 
        Receipts r
    JOIN 
        ReceiptsItemList ril ON r.id = ril.receipt_id
    WHERE 
        r.userId IN (SELECT id FROM RecentUsers)
)
SELECT 
    b.name AS brand_name, 
    SUM(rur.totalSpent) AS total_spend
FROM 
    RecentUserReceipts rur
JOIN 
    Brands b ON rur.barcode = b.barcode
GROUP BY 
    b.name
ORDER BY 
    total_spend DESC
LIMIT 1;

--6.Which brand has the most transactions among users who were created within the past 6 months?

WITH RecentUsers AS (
    SELECT 
        id 
    FROM 
        Users 
    WHERE 
        created_Date >= CURRENT_DATE - INTERVAL '6 months'
),
RecentUserReceipts AS (
    SELECT 
        r.id AS receipt_id, 
        ril.barcode
    FROM 
        Receipts r
    JOIN 
        ReceiptsItemList ril ON r.id = ril.receipt_id
    WHERE 
        r.userId IN (SELECT id FROM RecentUsers)
)
SELECT 
    b.name AS brand_name, 
    COUNT(rur.receipt_id) AS transaction_count
FROM 
    RecentUserReceipts rur
JOIN 
    Brands b ON rur.barcode = b.barcode
GROUP BY 
    b.name
ORDER BY 
    transaction_count DESC
LIMIT 1;
