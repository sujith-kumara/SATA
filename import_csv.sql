-- LOAD DATA INFILE 'in.csv' 
-- INTO TABLE marks 
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;
USE studentdbms;
-- DROP PROCEDURE grade_pct;
-- cls && mysql -u root < "C:\Users\sujit\OneDrive\Desktop\sata\StudentManagement-System-dbms-miniproject-main\student management\import_csv.sql"
DELIMITER //
CREATE PROCEDURE grade_pct(IN grade VARCHAR(64), IN dept VARCHAR(64))
BEGIN
SELECT CONCAT('DEPT: ', dept, ' GRADE: ', grade) AS '';
SET @gnum := (SELECT COUNT(DISTINCT KTUID) FROM marks WHERE C2=grade AND KTUID LIKE CONCAT('%', dept, '%'));
SET @tnum := (SELECT COUNT(DISTINCT KTUID) FROM marks WHERE KTUID LIKE CONCAT('%', dept, '%'));
SELECT @gnum AS NUM, @tnum AS DEN, (@gnum/@tnum)*100 AS PCT, (1-(@gnum/@tnum))*100 AS INV;
END
//
DELIMITER ;
CALL grade_pct('F', ''); -- clg fail n pass pct
CALL grade_pct('F', 'CS'); -- cs fail n pass pct
CALL grade_pct('F', 'ME'); -- me fail n pass pct
DROP PROCEDURE grade_pct;