USE `studentdbms`;

CREATE TABLE IF NOT EXISTS `marks` (
  `SID` int(32) NOT NULL,
  `KTUID` varchar(64) NOT NULL,
  `C1` varchar(64) DEFAULT NULL,
  `C2` varchar(64) DEFAULT NULL,
  `C3` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE marks drop SID;

LOAD DATA INFILE '/var/lib/mysql-files/in.csv'
IGNORE INTO TABLE `marks`
FIELDS TERMINATED BY ',';

ALTER TABLE `marks` ADD `SID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;