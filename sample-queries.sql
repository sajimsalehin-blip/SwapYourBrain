USE swap_your_brain;

-- 1. Basic SELECT
SELECT * FROM Users;

-- 2. Find all users who teach Python
SELECT u.user_id, u.first_name, u.last_name
FROM Users u
JOIN UserSkills us ON us.user_id=u.user_id
JOIN Skills s ON s.skill_id=us.skill_id
WHERE s.skill_name='Python' AND us.skill_type='teach';

-- 3. Find users who want to learn Python
SELECT u.first_name,u.last_name
FROM Users u
JOIN UserSkills us ON us.user_id=u.user_id
JOIN Skills s ON s.skill_id=us.skill_id
WHERE s.skill_name='Python' AND us.skill_type='learn';

-- 4. Search skills using LIKE
SELECT * FROM Skills WHERE skill_name LIKE '%SQL%';

-- 5. Count users per skill
SELECT s.skill_name, COUNT(DISTINCT us.user_id) AS users
FROM Skills s LEFT JOIN UserSkills us ON us.skill_id=s.skill_id
GROUP BY s.skill_id ORDER BY users DESC;

-- 6. Average rating per user
SELECT u.first_name,u.last_name,ROUND(AVG(r.rating),2) AS avg_rating
FROM Users u JOIN Reviews r ON r.reviewed_user_id=u.user_id
GROUP BY u.user_id ORDER BY avg_rating DESC;

-- 7. Completed sessions per user
SELECT u.first_name,u.last_name,COUNT(ls.session_id) completed_sessions
FROM Users u LEFT JOIN LearningSessions ls
ON (ls.teacher_id=u.user_id OR ls.learner_id=u.user_id)
AND ls.status='completed'
GROUP BY u.user_id;

-- 8. Most popular skills
SELECT s.skill_name, COUNT(us.user_skill_id) total_relationships
FROM Skills s LEFT JOIN UserSkills us ON us.skill_id=s.skill_id
GROUP BY s.skill_id ORDER BY total_relationships DESC;

-- 9. Pending requests
SELECT r.request_id, a.username sender, b.username receiver,
       rs.skill_name requested_skill, os.skill_name offered_skill
FROM SkillRequests r
JOIN Users a ON a.user_id=r.sender_id
JOIN Users b ON b.user_id=r.receiver_id
JOIN Skills rs ON rs.skill_id=r.requested_skill_id
JOIN Skills os ON os.skill_id=r.offered_skill_id
WHERE r.status='pending';

-- 10. Upcoming sessions
SELECT session_title,session_date,start_time
FROM LearningSessions
WHERE status='scheduled' AND session_date>=CURRENT_DATE
ORDER BY session_date,start_time;

-- 11. Category-wise skill counts
SELECT c.category_name,COUNT(s.skill_id) skill_count
FROM SkillCategories c LEFT JOIN Skills s ON s.category_id=c.category_id
GROUP BY c.category_id ORDER BY skill_count DESC;

-- 12. INNER JOIN example
SELECT u.username,s.skill_name,us.skill_type
FROM Users u
INNER JOIN UserSkills us ON us.user_id=u.user_id
INNER JOIN Skills s ON s.skill_id=us.skill_id;

-- 13. LEFT JOIN example
SELECT s.skill_name,COUNT(us.user_skill_id) people
FROM Skills s
LEFT JOIN UserSkills us ON us.skill_id=s.skill_id
GROUP BY s.skill_id;

-- 14. Aggregate query with HAVING
SELECT s.skill_name,COUNT(us.user_skill_id) people
FROM Skills s JOIN UserSkills us ON us.skill_id=s.skill_id
GROUP BY s.skill_id
HAVING COUNT(us.user_skill_id)>=2
ORDER BY people DESC;

-- 15. Two-way compatible exchanges
SELECT u1.username AS user_a,u2.username AS user_b,
       s1.skill_name AS a_teaches,s2.skill_name AS b_teaches
FROM UserSkills a
JOIN UserSkills b ON a.skill_id=b.skill_id
JOIN Users u1 ON u1.user_id=a.user_id
JOIN Users u2 ON u2.user_id=b.user_id
JOIN Skills s1 ON s1.skill_id=a.skill_id
JOIN Skills s2 ON s2.skill_id=b.skill_id
WHERE a.skill_type='teach' AND b.skill_type='learn'
  AND a.user_id<>b.user_id;

-- 16. UPDATE example
UPDATE LearningSessions SET status='completed' WHERE session_id=1;

-- 17. DELETE example
-- DELETE FROM UserSkills WHERE user_skill_id=123;

-- 18. ORDER BY rating
SELECT u.username,ROUND(AVG(r.rating),2) rating
FROM Users u JOIN Reviews r ON r.reviewed_user_id=u.user_id
GROUP BY u.user_id ORDER BY rating DESC;
