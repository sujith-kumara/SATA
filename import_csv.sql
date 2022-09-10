-- LOAD DATA INFILE 'in.csv' 
-- INTO TABLE marks 
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;
USE studentdbms;
-- cls && mysql -u root < "C:\Users\sujit\OneDrive\Desktop\sata\StudentManagement-System-dbms-miniproject-main\student management\import_csv.sql"
DELIMITER //
CREATE OR REPLACE PROCEDURE grade_pct(IN grade VARCHAR(64), IN dept VARCHAR(64)) BEGIN
SELECT CONCAT('DEPT=', dept, ' GRADE=', grade) AS '';
SET @gnum := (SELECT COUNT(DISTINCT KTUID) FROM marks WHERE C2 LIKE CONCAT('%', grade, '%') AND KTUID LIKE CONCAT('%', dept, '%'));
SET @tnum := (SELECT COUNT(DISTINCT KTUID) FROM marks WHERE KTUID LIKE CONCAT('%', dept, '%'));
SELECT @gnum AS NUM, @tnum AS DEN, (@gnum/@tnum)*100 AS PCT, (1-(@gnum/@tnum))*100 AS INV;
END //
CREATE OR REPLACE PROCEDURE dept_subj_grade_pct(IN dept VARCHAR(64), IN subj VARCHAR(64), IN grade VARCHAR(64)) BEGIN
SELECT CONCAT('DEPT=', dept, ' SUBJ=', subj, ' GRAD=', grade) AS '';
SET @gnum := (SELECT COUNT(DISTINCT KTUID) FROM marks WHERE C1 LIKE CONCAT('%', subj, '%') AND C2 LIKE CONCAT('%', grade, '%') AND KTUID LIKE CONCAT('%', dept, '%'));
SET @tnum := (SELECT COUNT(DISTINCT KTUID) FROM marks WHERE KTUID LIKE CONCAT('%', dept, '%'));
SELECT @gnum AS NUM, @tnum AS DEN, (@gnum/@tnum)*100 AS PCT, (1-(@gnum/@tnum))*100 AS INV;
END //
DELIMITER ;
CALL grade_pct('F', ''); -- clg fail n pass pct
CALL grade_pct('F', 'CS'); -- CS fail n pass pct
CALL grade_pct('F', 'ME'); -- ME fail n pass pct
CALL grade_pct('F', 'EC'); -- EC fail n pass pct
CALL grade_pct('F', 'EE'); -- EE fail n pass pct
CALL dept_subj_grade_pct('CS', 'CSL201', 'S'); -- S in CSL201 in CS
CALL dept_subj_grade_pct('EE', 'MAT201', 'S'); -- S in MAT201 in EE
CALL dept_subj_grade_pct('ME', 'MAT201', 'S'); -- S in MAT201 in ME
CALL dept_subj_grade_pct('EC', 'MAT201', 'S'); -- S in MAT201 in EC
SELECT * FROM marks WHERE KTUID LIKE '%CS054%';
-- DROP PROCEDURE IF EXISTS grade_pct;
-- DROP PROCEDURE IF EXISTS dept_subj_grade_pct;