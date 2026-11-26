USE sims;
SET NAMES utf8mb4;
SET time_zone = '+08:00';
SET @demo_hash = '$2y$12$dIqNhFRc.YlNUPrVpq9/1eHePS2HOGUZIbgIF.BZqTPx4opIjeW5.';
SET @year = YEAR(CURRENT_DATE) - IF(MONTH(CURRENT_DATE) < 6, 1, 0);
SET @school_year = CONCAT(@year, '-', @year + 1);
SET @previous_year = CONCAT(@year - 1, '-', @year);
SET @june = CONCAT(@year, '-06-08');

INSERT INTO users (id, name, email, password_hash, role) VALUES
(1, 'Alex Rivera', 'admin@campus.test', @demo_hash, 'admin'),
(2, 'Mara Santos', 'teacher@campus.test', @demo_hash, 'teacher'),
(3, 'Sofia Reyes', 'student@campus.test', @demo_hash, 'student'),
(4, 'Isabel Reyes', 'parent@campus.test', @demo_hash, 'parent'),
(5, 'Daniel Cruz', 'd.cruz@campus.test', @demo_hash, 'teacher'),
(6, 'Joanna Lim', 'j.lim@campus.test', @demo_hash, 'teacher');

INSERT INTO students (id, student_no, first_name, last_name, birth_date, email, phone, status, account_id, parent_id) VALUES
(1, 'ST-1042', 'Sofia', 'Reyes', '2011-02-14', 'sofia.reyes@example.test', NULL, 'Active', 3, 4),
(2, 'ST-1043', 'Lucas', 'Garcia', '2012-05-21', NULL, NULL, 'Active', NULL, NULL),
(3, 'ST-1044', 'Amara', 'Cruz', '2012-03-07', NULL, NULL, 'Active', NULL, NULL),
(4, 'ST-1045', 'Mateo', 'Dela Cruz', '2011-11-08', NULL, NULL, 'Active', NULL, NULL),
(5, 'ST-1046', 'Bea', 'Mendoza', '2012-01-18', NULL, NULL, 'Active', NULL, NULL),
(6, 'ST-1047', 'Nico', 'Santos', '2011-08-15', NULL, NULL, 'Active', NULL, NULL),
(7, 'ST-1048', 'Alyssa', 'Flores', '2010-10-26', NULL, NULL, 'Active', NULL, NULL),
(8, 'ST-1049', 'Gabriel', 'Torres', '2011-04-04', NULL, NULL, 'Active', NULL, NULL),
(9, 'ST-1050', 'Mika', 'Ramos', '2011-07-01', NULL, NULL, 'Active', NULL, NULL),
(10, 'ST-1051', 'Elijah', 'Aquino', '2011-10-09', NULL, NULL, 'Active', NULL, NULL),
(11, 'ST-1052', 'Hana', 'Villanueva', '2010-02-17', NULL, NULL, 'Active', NULL, NULL),
(12, 'ST-1053', 'Paolo', 'Gonzales', '2010-08-02', NULL, NULL, 'Active', NULL, NULL),
(13, 'ST-1054', 'Lia', 'David', '2011-10-10', NULL, NULL, 'Active', NULL, NULL),
(14, 'ST-1055', 'Joaquin', 'Tan', '2010-09-11', NULL, NULL, 'Active', NULL, NULL),
(15, 'ST-1056', 'Sam', 'Bautista', '2011-12-01', NULL, NULL, 'Transferred', NULL, NULL);

INSERT INTO classes (id, name, school_year, room, teacher_id) VALUES
(1, 'Grade 9 · Narra', @school_year, 'Room 204', 2),
(2, 'Grade 9 · Acacia', @school_year, 'Room 205', 5),
(3, 'Grade 10 · Molave', @school_year, 'Room 301', 6),
(4, 'Grade 10 · Ipil', @school_year, 'Room 302', 2),
(5, 'Grade 8 · Mahogany', @previous_year, 'Room 102', 2);

INSERT INTO enrollments (id, student_id, class_id, enrolled_on, status) VALUES
(1, 1, 1, @june, 'Enrolled'), (2, 2, 1, @june, 'Enrolled'),
(3, 3, 1, @june, 'Enrolled'), (4, 4, 1, @june, 'Enrolled'),
(5, 5, 2, @june, 'Enrolled'), (6, 6, 2, @june, 'Enrolled'),
(7, 7, 3, @june, 'Enrolled'), (8, 8, 3, @june, 'Enrolled'),
(9, 9, 2, @june, 'Enrolled'), (10, 10, 2, @june, 'Enrolled'),
(11, 11, 4, @june, 'Enrolled'), (12, 12, 4, @june, 'Enrolled'),
(13, 13, 3, @june, 'Enrolled'), (14, 14, 3, @june, 'Enrolled'),
(15, 15, 1, @june, 'Withdrawn'), (16, 1, 5, CONCAT(@year - 1, '-06-10'), 'Completed');

INSERT INTO attendance (enrollment_id, attendance_date, status)
WITH RECURSIVE offsets AS (SELECT 0 AS day_offset UNION ALL SELECT day_offset + 1 FROM offsets WHERE day_offset < 6)
SELECT n.id, DATE_SUB(CURRENT_DATE, INTERVAL o.day_offset DAY),
    CASE WHEN MOD(n.id + o.day_offset * 2, 13) = 0 THEN 'Absent'
         WHEN MOD(n.id + o.day_offset, 8) = 0 THEN 'Late'
         WHEN MOD(n.id + o.day_offset, 15) = 0 THEN 'Excused'
         ELSE 'Present' END
FROM enrollments n CROSS JOIN offsets o
WHERE n.id <= 14 AND (o.day_offset <> 4 OR n.id <= 11) AND (o.day_offset <> 2 OR n.id <= 12);

INSERT INTO grades (enrollment_id, subject, term, score, remarks) VALUES
(1, 'English', 'Quarter 1', 93, 'Strong written analysis'),
(1, 'Mathematics', 'Quarter 1', 91, 'Consistent progress'),
(1, 'Science', 'Quarter 1', 94, NULL),
(1, 'Social Studies', 'Quarter 1', 92, NULL),
(1, 'English', 'Quarter 2', 95, NULL),
(1, 'Mathematics', 'Quarter 2', 94, NULL),
(1, 'Science', 'Quarter 2', 96, NULL),
(1, 'Social Studies', 'Quarter 2', 93, NULL),
(2, 'Mathematics', 'Quarter 1', 89, NULL),
(2, 'Science', 'Quarter 1', 90, NULL),
(3, 'English', 'Quarter 1', 92, NULL),
(5, 'Mathematics', 'Quarter 1', 87, NULL),
(7, 'Science', 'Quarter 1', 92, NULL),
(11, 'Mathematics', 'Quarter 1', 94, NULL),
(16, 'Mathematics', 'Quarter 4', 92, NULL);

INSERT INTO timetable (class_id, title, kind, starts_at, ends_at, room) VALUES
(1, 'Mathematics', 'Class', CONCAT(CURRENT_DATE + INTERVAL 1 DAY, ' 08:00:00'), CONCAT(CURRENT_DATE + INTERVAL 1 DAY, ' 09:00:00'), 'Room 204'),
(1, 'Science laboratory', 'Class', CONCAT(CURRENT_DATE + INTERVAL 1 DAY, ' 10:00:00'), CONCAT(CURRENT_DATE + INTERVAL 1 DAY, ' 11:00:00'), 'Lab 2'),
(2, 'English composition', 'Class', CONCAT(CURRENT_DATE + INTERVAL 1 DAY, ' 09:00:00'), CONCAT(CURRENT_DATE + INTERVAL 1 DAY, ' 10:00:00'), 'Room 205'),
(3, 'Social Studies assessment', 'Exam', CONCAT(CURRENT_DATE + INTERVAL 2 DAY, ' 09:00:00'), CONCAT(CURRENT_DATE + INTERVAL 2 DAY, ' 10:30:00'), 'Room 301'),
(1, 'Quarterly Mathematics exam', 'Exam', CONCAT(CURRENT_DATE + INTERVAL 4 DAY, ' 13:00:00'), CONCAT(CURRENT_DATE + INTERVAL 4 DAY, ' 14:30:00'), 'Room 204'),
(4, 'Science review', 'Class', CONCAT(CURRENT_DATE + INTERVAL 3 DAY, ' 08:00:00'), CONCAT(CURRENT_DATE + INTERVAL 3 DAY, ' 09:00:00'), 'Room 302');

INSERT INTO fees (student_id, description, amount, paid, due_date) VALUES
(1, 'Quarter 2 tuition', 8500.00, 5500.00, CURRENT_DATE + INTERVAL 18 DAY),
(1, 'Laboratory materials', 1200.00, 1200.00, CURRENT_DATE - INTERVAL 7 DAY),
(2, 'Quarter 2 tuition', 8500.00, 0.00, CURRENT_DATE + INTERVAL 18 DAY),
(3, 'Laboratory materials', 1200.00, 600.00, CURRENT_DATE - INTERVAL 3 DAY),
(7, 'Quarter 2 tuition', 8500.00, 8500.00, CURRENT_DATE + INTERVAL 18 DAY);

INSERT INTO announcements (title, body, audience, published_on) VALUES
('Quarterly exam timetable', 'The updated exam timetable is available in Timetable. Check your room and start time before exam day.', 'All', CURRENT_DATE),
('Parent–teacher appointments', 'The next conference cycle is open. Contact the school office to arrange an appointment with your class adviser.', 'Parents', CURRENT_DATE - INTERVAL 1 DAY),
('Attendance records review', 'Please review attendance records before the end of the week and send any corrections to the registrar.', 'Teachers', CURRENT_DATE - INTERVAL 2 DAY),
('Library hours extended', 'The library will stay open until 5:30 PM on weekdays during the examination period.', 'Students', CURRENT_DATE - INTERVAL 3 DAY);
