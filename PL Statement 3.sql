/*
The SQL script sets up a stored procedure T3_PL to generate a profit 
and loss statement for a particular year from the h_accounting database.
It creates a temporary table larellano_tmp to hold data from various 
tables, filtered by criteria like non-cancelled entries. The procedure 
then calculates totals like gross profit and earnings before taxes. 
It stores these totals in the temporary table, providing a financial 
snapshot of the organization for the chosen year.
 */
USE h_accounting;

-- Drop existing procedure if it exists--
DROP PROCEDURE IF EXISTS `h_accounting`.`T3_PL`;

-- Create procedure requiring balance sheet year as an input
DELIMITER $$
CREATE PROCEDURE `h_accounting`.`T3_PL`(IN pl_year INT)
	READS SQL DATA
BEGIN
-- Table drop and Creation
DROP TABLE IF EXISTS `h_accounting`.`larellano_tmp`;
CREATE TABLE `h_accounting`.`larellano_tmp` (
    `profit_loss_line_number` INT,
    `section` VARCHAR(100),
    `label` VARCHAR(100),
    `selected_year_amount` decimal (65,2),
    `previous_year_amount` VARCHAR (100)
);
-- Insert Header
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`)
VALUES
	('0','', CONCAT('PROFIT AND LOSS STATEMENT FOR ',`pl_year`));
 
-- Insert Spacing
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`)
VALUES
	('1','', '');   
-- Insert Revenue
-- Will give each item an ID a label to recognise what it is and the 
-- amount for the current year as well as the previous year to be used for later calculation
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'1', 'Gross Profits', 'Revenue', 
    IFNULL(SUM(`jeli`.`credit`),0),
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)
	FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
	WHERE `profit_loss_section_id` IN (68)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `pl_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
WHERE `profit_loss_section_id` IN (68)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `pl_year`;

-- Insert Returns
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'2', 'Gross Profits', 'Returns, Refunds & Discounts', 
    IFNULL(SUM(`jeli`.`credit`),0),
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)
	FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
	WHERE `profit_loss_section_id` IN (69)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `pl_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
WHERE `profit_loss_section_id` IN (69)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `pl_year`;

-- Insert Cost of Sales
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'3','Gross Profits', 'Cost of Sales', 
    IFNULL(SUM(`jeli`.`credit`),0),
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)
	FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
	WHERE `profit_loss_section_id` IN (74)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `pl_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
WHERE `profit_loss_section_id` IN (74)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `pl_year`;

-- Insert Gross Profit
-- Adds up the values belonging to the gross Profits label using the line id
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'4','Gross Profits', 'Total Gross Profit',
	IFNULL(`tmp`.`selected_year_amount`,0) - 
		(SELECT SUM(IFNULL(`tmp`.`selected_year_amount`,0)) 
		FROM `h_accounting`.`larellano_tmp` AS `tmp` 
		WHERE `tmp`.`profit_loss_line_number` IN (2,3)),
	IFNULL(`tmp`.`previous_year_amount`,0) - 
		(SELECT SUM(IFNULL(`tmp`.`previous_year_amount`,0)) 
		FROM `h_accounting`.`larellano_tmp` AS `tmp` 
		WHERE `tmp`.`profit_loss_line_number` IN (2,3))
FROM `h_accounting`.`larellano_tmp` AS `tmp`
WHERE `tmp`.`profit_loss_line_number` = 1;

-- Insert Administrative Expenses
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'5', 'Earnings Before Taxes', 'Administrative Expenses', 
    IFNULL(SUM(`jeli`.`credit`),0),
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)
	FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
	WHERE `profit_loss_section_id` IN (75)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `pl_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
WHERE `profit_loss_section_id` IN (75)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `pl_year`;

-- Insert Selling Expenses Expenses
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'6', 'Earnings Before Taxes', 'Selling Expenses', 
    IFNULL(SUM(`jeli`.`credit`),0),
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)
	FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
	WHERE `profit_loss_section_id` IN (76)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `pl_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
WHERE `profit_loss_section_id` IN (76)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `pl_year`;

-- Insert Other Expenses
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'7', 'Earnings Before Taxes', 'Other Expenses', 
    IFNULL(SUM(`jeli`.`credit`),0),
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)
	FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
	WHERE `profit_loss_section_id` IN (77)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `pl_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
WHERE `profit_loss_section_id` IN (77)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `pl_year`;

-- Insert Other Income
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'8', 'Earnings Before Taxes', 'Other Income', 
    IFNULL(SUM(`jeli`.`credit`),0),
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)
	FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
	WHERE `profit_loss_section_id` IN (78)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `pl_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
WHERE `profit_loss_section_id` IN (78)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `pl_year`;

-- Insert Earnings Before Taxes
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'9', 'Earnings Before Taxes', 'Total Earnings Before Taxes',
	SUM(IFNULL(`tmp`.`selected_year_amount`,0)) - 
		(SELECT SUM(IFNULL(`tmp`.`selected_year_amount`,0)) 
		FROM `h_accounting`.`larellano_tmp` AS `tmp` 
		WHERE `tmp`.`profit_loss_line_number` IN (5,6,7)),
	SUM(IFNULL(`tmp`.`previous_year_amount`,0)) - 
		(SELECT SUM(IFNULL(`tmp`.`previous_year_amount`,0)) 
		FROM `h_accounting`.`larellano_tmp` AS `tmp` 
		WHERE `tmp`.`profit_loss_line_number` IN (5,6,7))
FROM `h_accounting`.`larellano_tmp` AS `tmp`
WHERE `tmp`.`profit_loss_line_number` IN (4,8);

-- Insert Income Tax
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'10','Taxes', 'Income Tax', 
    IFNULL(SUM(`jeli`.`credit`),0),
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)
	FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
	WHERE `profit_loss_section_id` IN (79)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `pl_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
WHERE `profit_loss_section_id` IN (79)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `pl_year`;

-- Insert Other Tax
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'11','Taxes', 'Other Tax', 
    IFNULL(SUM(`jeli`.`credit`),0),
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)
	FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
	WHERE `profit_loss_section_id` IN (80)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `pl_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`profit_loss_section_id`
WHERE `profit_loss_section_id` IN (80)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `pl_year`;

-- Insert Yearly Profit
INSERT INTO `h_accounting`.`larellano_tmp`
	(`profit_loss_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'12','Total', 'Net Profit/Loss',
	SUM(IFNULL(`tmp`.`selected_year_amount`,0)) - 
		(SELECT SUM(IFNULL(`tmp`.`selected_year_amount`,0)) 
		FROM `h_accounting`.`larellano_tmp` AS `tmp` 
		WHERE `tmp`.`profit_loss_line_number` IN (10,11)),
	SUM(IFNULL(`tmp`.`previous_year_amount`,0)) - 
		(SELECT SUM(IFNULL(`tmp`.`previous_year_amount`,0)) 
		FROM `h_accounting`.`larellano_tmp` AS `tmp` 
		WHERE `tmp`.`profit_loss_line_number` IN (10,11))
FROM `h_accounting`.`larellano_tmp` AS `tmp`
WHERE `tmp`.`profit_loss_line_number` IN (9);

-- Show Table
SELECT 
	`profit_loss_line_number`,
    `section` AS 'P&L Section',
    `label` AS 'Account', 
    FORMAT((`selected_year_amount`),2) AS Selected_Year,
	FORMAT(( `previous_year_amount`),2) AS Past_Year,
    IFNULL(CONCAT((FORMAT((`selected_year_amount`-`previous_year_amount`)/(`previous_year_amount`)*100,1)),'%'),'')
    AS `%Chg vs PY`
FROM
    `h_accounting`.`larellano_tmp`;
END $$
DELIMITER ;