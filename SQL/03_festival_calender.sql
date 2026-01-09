-- =========================================
-- 03_festival_calendar.sql
-- Purpose: Create festival reference table
-- =========================================

DROP TABLE IF EXISTS festival_calendar;

CREATE TABLE festival_calendar (
    festival_name TEXT,
    festival_date DATE
);

INSERT INTO festival_calendar (festival_name, festival_date) VALUES
('Diwali', '2024-11-01'),
('Holi',   '2024-03-25'),
('Eid',    '2024-04-10');

-- Quick check
SELECT * FROM festival_calendar
ORDER BY festival_date;
