SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- Create Database
CREATE DATABASE IF NOT EXISTS DB;
USE DB;

-- Table: member
CREATE TABLE member (
  member_ID INT(11) NOT NULL AUTO_INCREMENT,
  password VARCHAR(20) NOT NULL,
  email VARCHAR(60) NOT NULL,
  name VARCHAR(30) NOT NULL,
  phoneNumber VARCHAR(10) NOT NULL,
  homeAddress VARCHAR(60) NOT NULL,
  PRIMARY KEY (member_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: administrator
CREATE TABLE administrator (
  member_ID INT(11) NOT NULL,
  PRIMARY KEY (member_ID),
  FOREIGN KEY (member_ID) REFERENCES member(member_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: seller
CREATE TABLE seller (
  member_ID INT(11) NOT NULL,
  bankAccountNum VARCHAR(12) NOT NULL,
  routingNum VARCHAR(9) NOT NULL,
  PRIMARY KEY (member_ID),
  FOREIGN KEY (member_ID) REFERENCES member(member_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: items
CREATE TABLE items (
  item_ID INT(11) NOT NULL AUTO_INCREMENT,
  seller_ID INT(11) NOT NULL,
  startingBidPrice DECIMAL(10, 2) NOT NULL,
  description TEXT NOT NULL,
  startDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  endDate TIMESTAMP NOT NULL,
  category VARCHAR(30) NOT NULL,
  itemTitle VARCHAR(30) NOT NULL,
  PRIMARY KEY (item_ID),
  FOREIGN KEY (seller_ID) REFERENCES seller(member_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table: bids (Normalized: Removed seller_ID)
CREATE TABLE bids (
  bid_ID INT(11) NOT NULL AUTO_INCREMENT,
  buyer_ID INT(11) NOT NULL,
  item_ID INT(11) NOT NULL,
  bidPlacedTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  bidStatus TINYINT(1) NOT NULL,
  bidPrice DECIMAL(10, 2) NOT NULL,
  bidIncrement DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (bid_ID),
  FOREIGN KEY (buyer_ID) REFERENCES member(member_ID) ON DELETE CASCADE,
  FOREIGN KEY (item_ID) REFERENCES items(item_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Sample Data
INSERT INTO member (member_ID, password, email, name, phoneNumber, homeAddress) VALUES
(1, 'aaron_2025', 'aaron_2025@gmail.com', 'Aaron 2025', '4076147198', '100 Oak Ave, City, WA'),
(2, 'shannon_2025', 'shannon_2025@yahoo.com', 'Shannon 2025', '9788685889', '200 Greystone Ave, CT'),
(3, 'patsy_2025', 'patsy_2025@gmail.com', 'Patsy 2025', '7139037400', '300 Greenview Rd, NJ'),
(4, 'ricardo_2025', 'ricardo_2025@gmail.com', 'Ricardo 2025', '6312091617', '400 Oak Rd, KY'),
(5, 'jaime_2025', 'jaime_2025@gmail.com', 'Jaime 2025', '2673504056', '500 Harvey St, GA'),
(6, 'heidi_2025', 'heidi_2025@hotmail.com', 'Heidi 2025', '8054712064', '600 Fairground Ct, MD'),
(7, 'lamar_2025', 'lamar_2025@yahoo.com', 'Lamar 2025', '8285812939', '700 Saxton St, CT'),
(8, 'user8_2025', 'user8@example.com', 'User Eight', '1234567890', '800 Example St, NY'),
(9, 'user9_2025', 'user9@example.com', 'User Nine', '2345678901', '900 Example Ave, CA'),
(10, 'user10_2025', 'user10@example.com', 'User Ten', '3456789012', '1000 Example Blvd, TX');

INSERT INTO administrator (member_ID) VALUES (1), (2), (3);

INSERT INTO seller (member_ID, bankAccountNum, routingNum) VALUES
(4, '12345678', '111111111'),
(7, '23456789', '222222222'),
(9, '34567890', '333333333'),
(10, '45678901', '444444444');

INSERT INTO items (item_ID, seller_ID, startingBidPrice, description, startDate, endDate, category, itemTitle) VALUES
(1, 4, 10.00, 'Limited Edition Art Print', '2025-02-05 14:45:00', '2025-02-20 14:45:00', 'Art', 'Art Print'),
(2, 7, 500.00, 'Brand New Gaming Laptop', '2025-02-05 14:45:00', '2025-02-25 14:45:00', 'Electronics', 'Gaming Laptop'),
(3, 9, 80.00, 'Professional Camera Lens', '2025-02-05 14:45:00', '2025-03-05 14:45:00', 'Photography', 'Camera Lens'),
(4, 10, 5.00, 'Vintage Comic Book', '2025-02-05 14:45:00', '2025-03-10 14:45:00', 'Collectibles', 'Comic Book');

INSERT INTO bids (buyer_ID, item_ID, bidPlacedTime, bidStatus, bidPrice, bidIncrement) VALUES
(5, 1, '2025-02-05 14:45:00', 1, 15.00, 1.00),
(6, 2, '2025-02-05 14:45:00', 0, 40.00, 5.00),
(8, 4, '2025-02-05 14:45:00', 1, 10.00, 1.00);

-- View: bid_details (Adjusted for seller via join)
CREATE VIEW bid_details AS
SELECT 
    b.bid_ID, 
    m.name AS buyer_name, 
    sm.name AS seller_name, 
    i.itemTitle, 
    b.bidPrice, 
    b.bidPlacedTime
FROM bids b
JOIN member m ON b.buyer_ID = m.member_ID
JOIN items i ON b.item_ID = i.item_ID
JOIN seller s ON i.seller_ID = s.member_ID
JOIN member sm ON s.member_ID = sm.member_ID;

-- Trigger: remove_expired_bids
DELIMITER //
CREATE TRIGGER remove_expired_bids
BEFORE UPDATE ON items
FOR EACH ROW
BEGIN
    IF NEW.endDate < NOW() THEN
        DELETE FROM bids WHERE item_ID = NEW.item_ID;
    END IF;
END//
DELIMITER ;

-- View: bid_summary
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
JOIN items i ON b.item_ID = i.item_ID
JOIN seller s ON i.seller_ID = s.member_ID
JOIN member sm ON s.member_ID = sm.member_ID
GROUP BY b.item_ID, i.itemTitle, sm.name, i.endDate;

-- Procedure: process_bids (for item_ID = 1)
DELIMITER //
CREATE PROCEDURE process_bids()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_bid_ID INT;
    DECLARE v_bidPrice DECIMAL(10, 2);
    DECLARE cur CURSOR FOR
        SELECT bid_ID, bidPrice FROM bids WHERE item_ID = 1;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_bid_ID, v_bidPrice;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT v_bid_ID, v_bidPrice;
    END LOOP;
    CLOSE cur;
END//
DELIMITER ;

-- Procedure: find_highest_bids
DROP PROCEDURE IF EXISTS find_highest_bids;

DELIMITER //
CREATE PROCEDURE find_highest_bids()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE current_item_id INT;
    DECLARE current_item_title VARCHAR(30);
    DECLARE highest_bid DECIMAL(10, 2);
    DECLARE highest_bidder VARCHAR(30);
    
    DECLARE item_cursor CURSOR FOR 
        SELECT DISTINCT i.item_ID, i.itemTitle
        FROM items i
        JOIN bids b ON i.item_ID = b.item_ID
        ORDER BY i.item_ID;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    CREATE TEMPORARY TABLE IF NOT EXISTS highest_item_bids (
        item_id INT,
        item_title VARCHAR(30),
        highest_bid DECIMAL(10, 2),
        bidder_name VARCHAR(30)
    );
    
    OPEN item_cursor;
    item_loop: LOOP
        FETCH item_cursor INTO current_item_id, current_item_title;
        IF done THEN
            LEAVE item_loop;
        END IF;
        
        SELECT b.bidPrice, m.name
        INTO highest_bid, highest_bidder
        FROM bids b
        JOIN member m ON b.buyer_ID = m.member_ID
        WHERE b.item_ID = current_item_id
        ORDER BY b.bidPrice DESC
        LIMIT 1;
        
        INSERT INTO highest_item_bids
        VALUES (current_item_id, current_item_title, highest_bid, highest_bidder);
    END LOOP;
    
    CLOSE item_cursor;
    SELECT * FROM highest_item_bids;
    DROP TEMPORARY TABLE IF EXISTS highest_item_bids;
END//
DELIMITER ;
