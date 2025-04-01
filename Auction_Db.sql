-- Simplified Database Schema for Review 1
-- Includes core functionality for auction platform

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

CREATE TABLE `member` (
  `member_ID` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  `email` VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE `seller` (
  `member_ID` INT PRIMARY KEY,
  FOREIGN KEY (`member_ID`) REFERENCES `member`(`member_ID`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `buyer` (
  `member_ID` INT PRIMARY KEY,
  FOREIGN KEY (`member_ID`) REFERENCES `member`(`member_ID`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `items` (
  `item_ID` INT PRIMARY KEY AUTO_INCREMENT,
  `seller_ID` INT,
  `itemTitle` VARCHAR(30) NOT NULL,
  `startingBidPrice` FLOAT NOT NULL,
  `endDate` TIMESTAMP NOT NULL,
  FOREIGN KEY (`seller_ID`) REFERENCES `seller`(`member_ID`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `bids` (
  `buyer_ID` INT,
  `item_ID` INT,
  `bidPrice` FLOAT NOT NULL,
  `bidPlacedTime` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`buyer_ID`, `item_ID`),
  FOREIGN KEY (`buyer_ID`) REFERENCES `buyer`(`member_ID`) ON DELETE CASCADE,
  FOREIGN KEY (`item_ID`) REFERENCES `items`(`item_ID`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Sample Data
INSERT INTO `member` (`name`, `email`) VALUES
('Alice Smith', 'alice@example.com'),
('Bob Jones', 'bob@example.com');

INSERT INTO `seller` (`member_ID`) VALUES (1);
INSERT INTO `buyer` (`member_ID`) VALUES (2);

INSERT INTO `items` (`seller_ID`, `itemTitle`, `startingBidPrice`, `endDate`) VALUES
(1, 'Gaming Laptop', 500.0, '2025-02-10 23:59:59');

INSERT INTO `bids` (`buyer_ID`, `item_ID`, `bidPrice`) VALUES
(2, 1, 550.0);
