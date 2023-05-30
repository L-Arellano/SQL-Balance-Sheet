/* 
This SQL code builds a balance sheet in the 'h_accounting' database 
by creating a temporary table with line items for a given year. It categorizes 
items into sections like Assets, Liabilities, Equity, and calculates totals 
by pulling data from existing tables, accounting for filters like 
'balance_sheet_section_id' and 'cancelled' status. The data for the selected 
year and the previous year are calculated based on journal entries. The procedure 'T3_BS'
 can then generate the balance sheet for a specific year when called with the year as the argument.
 */
USE h_accounting;

-- Drop existing procedure if it exists --
DROP PROCEDURE IF EXISTS `h_accounting`.`T3_BS`;

-- Create procedure requiring balance sheet year as an input
DELIMITER $$
CREATE PROCEDURE `h_accounting`.`T3_BS`(IN bs_year INT)
	READS SQL DATA
BEGIN
-- Table drop and Creation
DROP TABLE IF EXISTS `h_accounting`.`larellano_tmp`;
CREATE TABLE `h_accounting`.`larellano_tmp` (
    `balance_sheet_line_number` INT,
    `section` VARCHAR(100),
    `label` VARCHAR(100),
    `selected_year_amount` DECIMAL(65, 2),
    `previous_year_amount` DECIMAL(65, 2)
);
-- Insert Current Assets
-- Inserts Labels to identidy the item as well as the values for the 
-- chosen year and previous year which we will later use to calculate the percentage change
INSERT INTO `h_accounting`.`larellano_tmp`
	(`balance_sheet_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'1', 'Assets', 'Current Assets', 
    IFNULL(SUM(`jeli`.`debit`),0)-IFNULL(SUM(`jeli`.`credit`),0), 
    (SELECT IFNULL(SUM(`jeli`.`debit`),0)-IFNULL(SUM(`jeli`.`credit`),0)
    FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
	WHERE `balance_sheet_section_id` IN (61)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `bs_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS acc ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
WHERE `balance_sheet_section_id` IN (61)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `bs_year`;

-- Insert Fixed Assets
INSERT INTO `h_accounting`.`larellano_tmp`
	(`balance_sheet_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'2', 'Assets', 'Fixed Assets', 
    IFNULL(SUM(`jeli`.`debit`),0)-IFNULL(SUM(`jeli`.`credit`),0), 
    (SELECT IFNULL(SUM(`jeli`.`debit`),0)-IFNULL(SUM(`jeli`.`credit`),0)
    FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
	WHERE `balance_sheet_section_id` IN (62)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `bs_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS acc ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
WHERE `balance_sheet_section_id` IN (62)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `bs_year`;

-- Insert Deferred Assets
INSERT INTO `h_accounting`.`larellano_tmp`
	(`balance_sheet_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT 
	'3', 'Assets', 'Deferred Assets', 
    IFNULL(SUM(`jeli`.`debit`),0)-IFNULL(SUM(`jeli`.`credit`),0), 
    (SELECT IFNULL(SUM(`jeli`.`debit`),0)-IFNULL(SUM(`jeli`.`credit`),0)
    FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
	WHERE `balance_sheet_section_id` IN (63)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `bs_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS acc ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
WHERE `balance_sheet_section_id` IN (63)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `bs_year`;

-- Insert Current Liabilities
INSERT INTO `h_accounting`.`larellano_tmp`
	(`balance_sheet_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT
	'4', 'Liabilities & Equity', 'Current Liabilities', 
    IFNULL(SUM(`jeli`.`credit`),0)-IFNULL(SUM(`jeli`.`debit`),0), 
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)-IFNULL(SUM(`jeli`.`debit`),0)
    FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
	WHERE `balance_sheet_section_id` IN (64)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `bs_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS acc ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
WHERE `balance_sheet_section_id` IN (64)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `bs_year`;

-- Insert Long Term Liabilities
INSERT INTO `h_accounting`.`larellano_tmp`
	(`balance_sheet_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT
	'5', 'Liabilities & Equity', 'Long Term Liabilities', 
    IFNULL(SUM(`jeli`.`credit`),0)-IFNULL(SUM(`jeli`.`debit`),0), 
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)-IFNULL(SUM(`jeli`.`debit`),0)
    FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
	WHERE `balance_sheet_section_id` IN (65)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `bs_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS acc ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
WHERE `balance_sheet_section_id` IN (65)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `bs_year`;

-- Insert Deferred Liabilities
INSERT INTO `h_accounting`.`larellano_tmp`
	(`balance_sheet_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT
	'6', 'Liabilities & Equity', 'Deferred Liabilities', 
    IFNULL(SUM(`jeli`.`credit`),0)-IFNULL(SUM(`jeli`.`debit`),0), 
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)-IFNULL(SUM(`jeli`.`debit`),0)
    FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
	WHERE `balance_sheet_section_id` IN (66)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `bs_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS acc ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
WHERE `balance_sheet_section_id` IN (66)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `bs_year`;

-- Insert Equity
INSERT INTO `h_accounting`.`larellano_tmp`
	(`balance_sheet_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT
	'7', 'Liabilities & Equity', 'Equity', 
    IFNULL(SUM(`jeli`.`credit`),0)-IFNULL(SUM(`jeli`.`debit`),0), 
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)-IFNULL(SUM(`jeli`.`debit`),0)
    FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
	WHERE `balance_sheet_section_id` IN (67)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `bs_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS acc ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
WHERE `balance_sheet_section_id` IN (67)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `bs_year`;

-- Insert Total Assets
INSERT INTO `h_accounting`.`larellano_tmp`
	(`balance_sheet_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT
	'8', 'Totals', 'Total Assets', 
    IFNULL(SUM(`jeli`.`debit`),0)-IFNULL(SUM(`jeli`.`credit`),0), 
    (SELECT IFNULL(SUM(`jeli`.`debit`),0)-IFNULL(SUM(`jeli`.`credit`),0)
    FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
	WHERE `balance_sheet_section_id` IN (61,62,63)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `bs_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS acc ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
WHERE `balance_sheet_section_id` IN (61,62,63)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `bs_year`;

-- Insert Total Liabilities
INSERT INTO `h_accounting`.`larellano_tmp`
	(`balance_sheet_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT
	'9', 'Totals', 'Total Liabilities', 
    IFNULL(SUM(`jeli`.`credit`),0)-IFNULL(SUM(`jeli`.`debit`),0), 
    (SELECT IFNULL(SUM(`jeli`.`credit`),0)-IFNULL(SUM(`jeli`.`debit`),0)
    FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
		INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
		INNER JOIN `h_accounting`.`account` AS `acc` ON `acc`.`account_id` = `jeli`.`account_id`
		INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
	WHERE `balance_sheet_section_id` IN (64,65,66,67)
	AND `je`.`cancelled` = 0
	AND YEAR (`je`.`entry_date`) = `bs_year`-1)
FROM `h_accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `h_accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `h_accounting`.`account` AS acc ON `acc`.`account_id` = `jeli`.`account_id`
	INNER JOIN `h_accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `acc`.`balance_sheet_section_id`
WHERE `balance_sheet_section_id` IN (64,65,66,67)
AND `je`.`cancelled` = 0
AND YEAR (`je`.`entry_date`) = `bs_year`;

-- Insert End of Year Balance
-- The final balance is Assets - Liabilities and Equity which are lines 8 and 9 on the temporary table respectively
-- These are added and if all is correct should add up to 0.

INSERT INTO `h_accounting`.`larellano_tmp`
	(`balance_sheet_line_number`, `section`, `label`, `selected_year_amount`, `previous_year_amount`)
SELECT
	'10', 'Totals', 'End of Year Balance',
    `tmp`.`selected_year_amount` - 
	(SELECT SUM(`tmp`.`selected_year_amount`) 
    FROM `h_accounting`.`larellano_tmp` AS `tmp` 
    WHERE `tmp`.`balance_sheet_line_number` IN (9)),
    `tmp`.`previous_year_amount` - 
	(SELECT SUM(`tmp`.`previous_year_amount`) 
    FROM `h_accounting`.`larellano_tmp` AS `tmp` 
    WHERE `tmp`.`balance_sheet_line_number` IN (9))
FROM `h_accounting`.`larellano_tmp` AS `tmp`
WHERE `tmp`.`balance_sheet_line_number` IN (8);

-- Show Table
-- This will use tha data on the temporary table to calculate and print the percentage change
SELECT 
	`section` AS 'Balance Sheet Section', 
	`label` AS 'Account', 
	FORMAT ((`selected_year_amount`),1) AS Current_Year,
    FORMAT ((`previous_year_amount`),1) AS Past_Year,
	CONCAT(IFNULL(FORMAT((`selected_year_amount`-`previous_year_amount`)/(`previous_year_amount`)*100,1),0),'%') 
    AS `%Chg vs PY`
FROM 
	`h_accounting`.`larellano_tmp`;
END $$
DELIMITER ;