DROP DATABASE IF EXISTS DB;
SHOW databases;
USE db;
SHOW TABLES;
DESC items; 
select * from items;
SELECT * FROM bids WHERE item_ID = 1;
UPDATE items SET endDate = '2024-03-01 00:00:00' WHERE item_ID = 1;
SELECT * FROM bids WHERE item_ID = 1;

-- Create a comprehensive view that shows items with their current highest bid information
CREATE VIEW bid_summary AS
SELECT 
    b.item_ID,
    i.itemTitle, 
    sm.name AS seller_name, 
    COUNT(b.bid_ID) AS total_bids, 
    MAX(b.bidPrice) AS highest_bid, 
    MIN(b.bidPrice) AS lowest_bid,
    AVG(b.bidPrice) AS avg_bid_price,
    CASE 
        WHEN i.endDate < NOW() THEN 'Closed'
        ELSE 'Active'
    END AS auction_status
FROM bids b
JOIN member m ON b.buyer_ID = m.member_ID
JOIN seller s ON b.seller_ID = s.member_ID
JOIN member sm ON s.member_ID = sm.member_ID
JOIN items i ON b.item_ID = i.item_ID
GROUP BY b.item_ID, i.itemTitle, sm.name, i.endDate;

SELECT * FROM bid_summary;


DROP VIEW IF EXISTS bid_summary;




