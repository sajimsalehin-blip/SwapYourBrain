DROP DATABASE IF EXISTS swap_your_brain;
CREATE DATABASE swap_your_brain CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE swap_your_brain;

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE Users (
    user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    profile_image VARCHAR(255) DEFAULT NULL,
    location VARCHAR(120) DEFAULT NULL,
    bio TEXT DEFAULT NULL,
    role ENUM('user','admin') NOT NULL DEFAULT 'user',
    status ENUM('active','inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_name (first_name,last_name),
    INDEX idx_users_status (status)
) ENGINE=InnoDB;

CREATE TABLE UserProfiles (
    profile_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL UNIQUE,
    headline VARCHAR(160) DEFAULT NULL,
    university VARCHAR(160) DEFAULT NULL,
    department VARCHAR(120) DEFAULT NULL,
    academic_year VARCHAR(40) DEFAULT NULL,
    phone VARCHAR(30) DEFAULT NULL,
    linkedin_url VARCHAR(255) DEFAULT NULL,
    github_url VARCHAR(255) DEFAULT NULL,
    portfolio_url VARCHAR(255) DEFAULT NULL,
    availability VARCHAR(255) DEFAULT NULL,
    learning_preferences TEXT DEFAULT NULL,
    CONSTRAINT fk_profiles_user FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE SkillCategories (
    category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) DEFAULT NULL
) ENGINE=InnoDB;

CREATE TABLE Skills (
    skill_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id INT UNSIGNED NOT NULL,
    skill_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) DEFAULT NULL,
    difficulty_level ENUM('Beginner','Intermediate','Advanced') NOT NULL DEFAULT 'Beginner',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_skills_category (category_id),
    CONSTRAINT fk_skills_category FOREIGN KEY (category_id) REFERENCES SkillCategories(category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE UserSkills (
    user_skill_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    skill_type ENUM('teach','learn') NOT NULL,
    proficiency_level ENUM('Beginner','Intermediate','Advanced','Expert') NOT NULL DEFAULT 'Beginner',
    years_experience DECIMAL(4,1) NOT NULL DEFAULT 0 CHECK (years_experience >= 0),
    description VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_skill_type (user_id,skill_id,skill_type),
    INDEX idx_userskills_skill_type (skill_id,skill_type),
    CONSTRAINT fk_userskills_user FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_userskills_skill FOREIGN KEY (skill_id) REFERENCES Skills(skill_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE SkillRequests (
    request_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sender_id INT UNSIGNED NOT NULL,
    receiver_id INT UNSIGNED NOT NULL,
    requested_skill_id INT UNSIGNED NOT NULL,
    offered_skill_id INT UNSIGNED NOT NULL,
    message VARCHAR(500) DEFAULT NULL,
    status ENUM('pending','accepted','rejected','cancelled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL DEFAULT NULL,
    CHECK (sender_id <> receiver_id),
    INDEX idx_requests_receiver_status (receiver_id,status),
    INDEX idx_requests_sender_status (sender_id,status),
    CONSTRAINT fk_requests_sender FOREIGN KEY (sender_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_requests_receiver FOREIGN KEY (receiver_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_requests_requested_skill FOREIGN KEY (requested_skill_id) REFERENCES Skills(skill_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_requests_offered_skill FOREIGN KEY (offered_skill_id) REFERENCES Skills(skill_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE SkillMatches (
    match_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user1_id INT UNSIGNED NOT NULL,
    user2_id INT UNSIGNED NOT NULL,
    user1_skill_id INT UNSIGNED NOT NULL,
    user2_skill_id INT UNSIGNED NOT NULL,
    compatibility_score DECIMAL(5,2) NOT NULL CHECK (compatibility_score >= 0 AND compatibility_score <= 100),
    match_status ENUM('suggested','requested','connected','dismissed') NOT NULL DEFAULT 'suggested',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (user1_id <> user2_id),
    INDEX idx_matches_user1 (user1_id,match_status),
    INDEX idx_matches_user2 (user2_id,match_status),
    CONSTRAINT fk_matches_user1 FOREIGN KEY (user1_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_matches_user2 FOREIGN KEY (user2_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_matches_skill1 FOREIGN KEY (user1_skill_id) REFERENCES Skills(skill_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_matches_skill2 FOREIGN KEY (user2_skill_id) REFERENCES Skills(skill_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE LearningSessions (
    session_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    request_id INT UNSIGNED NOT NULL,
    teacher_id INT UNSIGNED NOT NULL,
    learner_id INT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    session_title VARCHAR(180) NOT NULL,
    session_description TEXT DEFAULT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    session_mode ENUM('online','offline') NOT NULL DEFAULT 'online',
    meeting_link VARCHAR(500) DEFAULT NULL,
    location VARCHAR(255) DEFAULT NULL,
    status ENUM('scheduled','completed','cancelled') NOT NULL DEFAULT 'scheduled',
    notes TEXT DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (teacher_id <> learner_id),
    CHECK (end_time > start_time),
    INDEX idx_sessions_teacher_date (teacher_id,session_date),
    INDEX idx_sessions_learner_date (learner_id,session_date),
    CONSTRAINT fk_sessions_request FOREIGN KEY (request_id) REFERENCES SkillRequests(request_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_sessions_teacher FOREIGN KEY (teacher_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sessions_learner FOREIGN KEY (learner_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sessions_skill FOREIGN KEY (skill_id) REFERENCES Skills(skill_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Messages (
    message_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sender_id INT UNSIGNED NOT NULL,
    receiver_id INT UNSIGNED NOT NULL,
    message_text TEXT NOT NULL,
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    CHECK (sender_id <> receiver_id),
    INDEX idx_messages_receiver_read (receiver_id,is_read),
    INDEX idx_messages_conversation (sender_id,receiver_id,sent_at),
    CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Reviews (
    review_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_id INT UNSIGNED NOT NULL,
    reviewer_id INT UNSIGNED NOT NULL,
    reviewed_user_id INT UNSIGNED NOT NULL,
    rating TINYINT UNSIGNED NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text VARCHAR(1000) DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_review_session_reviewer (session_id,reviewer_id),
    INDEX idx_reviews_reviewed_user (reviewed_user_id),
    CONSTRAINT fk_reviews_session FOREIGN KEY (session_id) REFERENCES LearningSessions(session_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_reviewer FOREIGN KEY (reviewer_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_reviewed_user FOREIGN KEY (reviewed_user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Achievements (
    achievement_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    achievement_name VARCHAR(120) NOT NULL,
    description VARCHAR(255) NOT NULL,
    badge_icon VARCHAR(50) NOT NULL DEFAULT '✦',
    achievement_type VARCHAR(80) NOT NULL,
    earned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_achievements_user (user_id),
    CONSTRAINT fk_achievements_user FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Admins (
    admin_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL UNIQUE,
    admin_level ENUM('moderator','manager','superadmin') NOT NULL DEFAULT 'moderator',
    permissions VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_admins_user FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- Demo password hashes:
-- Admin@123 and User@123
INSERT INTO Users (username,email,password_hash,first_name,last_name,location,bio,role) VALUES
('admin','admin@swapyourbrain.com','$2y$12$50V5Mn4txGZ9L6eDOX9pXu.GQKtT1ocl10t5/F7FeJFYznl0ZlIAK','System','Admin','Dhaka','Platform administrator.','admin'),
('alex','alex@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Alex','Rahman','Dhaka','Software engineering student who enjoys Python and databases.','user'),
('sara','sara@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Sara','Ahmed','Dhaka','Designer and guitarist looking to exchange creative skills.','user'),
('tanvir','tanvir@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Tanvir','Hasan','Dhaka','Full-stack learner and programming mentor.','user'),
('nabila','nabila@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Nabila','Khan','Chattogram','Video editor who wants to learn marketing.','user'),
('rifat','rifat@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Rifat','Hossain','Dhaka','Python programmer and math tutor.','user'),
('mim','mim@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Mim','Sultana','Rajshahi','UI/UX enthusiast learning databases.','user'),
('farhan','farhan@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Farhan','Kabir','Dhaka','Business student interested in digital marketing.','user'),
('jannat','jannat@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Jannat','Noor','Sylhet','English speaker and communication coach.','user'),
('sami','sami@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Sami','Islam','Dhaka','Photography lover and beginner web developer.','user'),
('tahsin','tahsin@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Tahsin','Mahmud','Dhaka','Database enthusiast who loves SQL.','user'),
('lima','lima@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Lima','Akter','Khulna','Marketing student learning graphic design.','user'),
('owais','owais@example.com','$2y$12$BdeOPMd7JnBdVJx6B3Aeq.gVWIFaHODgJNCtK4gC7pIr0Tr/IIO4.','Owais','Karim','Dhaka','Music producer learning Python.','user');

INSERT INTO UserProfiles (user_id,headline,university,department,academic_year,availability,learning_preferences) VALUES
(1,'Platform Administrator','Swap Your Brain','Administration','Staff','Weekdays','Operations'),
(2,'Software Engineering Student','North South University','CSE','3rd Year','Evenings','Hands-on projects'),
(3,'UI/UX Designer & Guitarist','North South University','Architecture','2nd Year','Weekends','Visual examples'),
(4,'Full-Stack Developer','BRAC University','CSE','4th Year','Evenings','Project-based'),
(5,'Video Editor','University of Chittagong','Media Studies','3rd Year','Afternoons','Short tutorials'),
(6,'Python & Math Mentor','North South University','CSE','4th Year','Evenings','Problem solving'),
(7,'UI/UX Explorer','East West University','CSE','2nd Year','Weekends','Design challenges'),
(8,'Business & Marketing Learner','North South University','BBA','3rd Year','Evenings','Case studies'),
(9,'English Communication Coach','Independent','Languages','Graduate','Flexible','Conversation practice'),
(10,'Photographer & Web Learner','North South University','CSE','2nd Year','Weekends','Visual learning'),
(11,'SQL Enthusiast','North South University','CSE','3rd Year','Evenings','Database labs'),
(12,'Creative Marketer','University of Dhaka','Marketing','3rd Year','Afternoons','Practical campaigns'),
(13,'Music Producer','Independent','Music','Graduate','Nights','Audio practice');

INSERT INTO SkillCategories (category_name,description) VALUES
('Programming','Programming languages and development'),
('Web Development','Frontend and backend web skills'),
('Database','SQL and database engineering'),
('Graphic Design','Visual design and illustration'),
('Video Editing','Video production and editing'),
('Music','Instruments and music production'),
('Languages','Spoken and written languages'),
('Mathematics','Mathematics and quantitative reasoning'),
('Business','Business and entrepreneurship'),
('Marketing','Marketing and growth'),
('Photography','Photography and visual storytelling'),
('Academic Courses','University-level academic skills');

INSERT INTO Skills (category_id,skill_name,description,difficulty_level) VALUES
(1,'Python','General-purpose programming with Python','Intermediate'),
(1,'C++','Object-oriented and competitive programming','Advanced'),
(1,'Java','Object-oriented application development','Intermediate'),
(1,'JavaScript','Programming for interactive web applications','Intermediate'),
(2,'HTML/CSS','Building and styling web pages','Beginner'),
(2,'PHP','Server-side web development','Intermediate'),
(2,'UI Development','Reusable interface design','Intermediate'),
(3,'SQL','Relational database querying','Intermediate'),
(3,'Database Design','Keys, normalization and relationships','Advanced'),
(3,'MySQL','MySQL database administration and queries','Intermediate'),
(4,'Photoshop','Raster image editing and composition','Intermediate'),
(4,'Figma','UI/UX prototyping and design','Intermediate'),
(4,'Illustrator','Vector illustration','Advanced'),
(5,'Premiere Pro','Professional video editing','Intermediate'),
(5,'After Effects','Motion graphics and compositing','Advanced'),
(6,'Guitar','Acoustic/electric guitar fundamentals','Intermediate'),
(6,'Music Production','Digital audio production','Advanced'),
(6,'Piano','Piano fundamentals','Beginner'),
(7,'English Speaking','Fluent spoken English practice','Intermediate'),
(7,'Public Speaking','Confident presentations and speeches','Intermediate'),
(8,'Calculus','University calculus tutoring','Advanced'),
(8,'Linear Algebra','Matrices and vector spaces','Advanced'),
(9,'Entrepreneurship','Business idea development','Intermediate'),
(10,'Digital Marketing','Online marketing strategy','Intermediate'),
(10,'SEO','Search engine optimization','Intermediate'),
(11,'Photography','Composition and camera skills','Intermediate'),
(12,'Academic Writing','Research and academic writing','Intermediate');

INSERT INTO UserSkills (user_id,skill_id,skill_type,proficiency_level,years_experience,description) VALUES
(2,1,'teach','Advanced',2,'Python for coursework and projects'),
(2,8,'teach','Advanced',2,'SQL and relational queries'),
(2,16,'learn','Beginner',0,'Wants to learn guitar'),
(2,11,'learn','Beginner',0,'Wants to learn Photoshop'),
(3,16,'teach','Intermediate',5,'Guitar lessons for beginners'),
(3,11,'teach','Advanced',4,'Photoshop and design workflows'),
(3,1,'learn','Beginner',0,'Wants practical Python'),
(3,8,'learn','Beginner',0,'Wants SQL fundamentals'),
(4,2,'teach','Advanced',4,'C++ and algorithms'),
(4,6,'teach','Advanced',3,'PHP web development'),
(4,8,'teach','Advanced',3,'Database-backed PHP apps'),
(4,12,'learn','Intermediate',1,'Wants Figma practice'),
(5,14,'teach','Advanced',4,'Premiere Pro editing'),
(5,15,'teach','Intermediate',2,'Motion graphics'),
(5,24,'learn','Beginner',0,'Wants digital marketing'),
(6,1,'teach','Expert',5,'Python tutoring'),
(6,21,'teach','Advanced',4,'Calculus tutoring'),
(6,22,'teach','Advanced',3,'Linear algebra'),
(6,16,'learn','Beginner',0,'Wants guitar'),
(7,12,'teach','Advanced',3,'Figma UI prototyping'),
(7,7,'teach','Intermediate',2,'Frontend interface development'),
(7,8,'learn','Beginner',0,'Wants SQL'),
(8,24,'teach','Advanced',3,'Digital marketing campaigns'),
(8,23,'teach','Intermediate',2,'Business planning'),
(8,11,'learn','Beginner',0,'Wants Photoshop'),
(9,19,'teach','Expert',6,'Conversation and pronunciation'),
(9,20,'teach','Advanced',4,'Presentation coaching'),
(9,27,'learn','Intermediate',1,'Wants academic writing'),
(10,26,'teach','Advanced',4,'Portrait and street photography'),
(10,5,'teach','Intermediate',2,'HTML/CSS basics'),
(10,6,'learn','Beginner',0,'Wants PHP'),
(11,8,'teach','Expert',4,'SQL lab coaching'),
(11,9,'teach','Advanced',3,'Database design'),
(11,3,'teach','Intermediate',2,'Java basics'),
(11,12,'learn','Beginner',0,'Wants Figma'),
(12,24,'teach','Advanced',4,'Digital marketing'),
(12,25,'teach','Intermediate',2,'SEO'),
(12,11,'teach','Intermediate',2,'Photoshop'),
(12,14,'learn','Beginner',0,'Wants Premiere Pro'),
(13,16,'teach','Advanced',8,'Guitar and arrangement'),
(13,17,'teach','Advanced',5,'Music production'),
(13,1,'learn','Beginner',0,'Wants Python'),
(13,18,'teach','Intermediate',3,'Piano fundamentals');

INSERT INTO SkillRequests (sender_id,receiver_id,requested_skill_id,offered_skill_id,message,status,responded_at) VALUES
(2,3,16,1,'I can teach Python if you can teach me guitar.','accepted',CURRENT_TIMESTAMP),
(3,2,1,16,'I would love to swap guitar for Python.','accepted',CURRENT_TIMESTAMP),
(2,3,11,8,'Could we also do a Photoshop/SQL exchange?','pending',NULL),
(3,2,8,11,'Would you like to learn SQL from me?','pending',NULL),
(6,3,16,21,'I can help with calculus in exchange for guitar.','accepted',CURRENT_TIMESTAMP),
(3,6,21,16,'Sounds good!','accepted',CURRENT_TIMESTAMP),
(5,8,24,14,'I can teach video editing for marketing help.','pending',NULL),
(8,5,14,24,'Interested in learning Premiere Pro.','accepted',CURRENT_TIMESTAMP),
(7,11,8,12,'Figma for SQL?','pending',NULL),
(11,7,12,8,'Happy to swap SQL for Figma.','accepted',CURRENT_TIMESTAMP),
(10,4,6,26,'I can teach photography for PHP.','pending',NULL),
(4,10,26,6,'Photography sounds fun.','accepted',CURRENT_TIMESTAMP),
(12,5,14,11,'I can teach marketing for Premiere Pro.','rejected',CURRENT_TIMESTAMP),
(13,2,1,16,'I can teach guitar while learning Python.','pending',NULL),
(9,12,27,19,'Could you help me with academic writing?','pending',NULL),
(12,9,19,24,'I can teach marketing in return for speaking practice.','pending',NULL);

INSERT INTO SkillMatches (user1_id,user2_id,user1_skill_id,user2_skill_id,compatibility_score,match_status) VALUES
(2,3,1,16,100,'connected'),
(2,3,8,11,100,'requested'),
(6,3,21,16,100,'connected'),
(5,8,14,24,100,'requested'),
(7,11,12,8,100,'connected'),
(10,4,26,6,100,'requested'),
(13,2,16,1,100,'suggested'),
(9,12,19,24,75,'suggested'),
(2,6,1,21,50,'suggested'),
(8,12,23,24,75,'suggested'),
(3,7,11,12,75,'suggested'),
(11,2,8,1,75,'suggested');

INSERT INTO LearningSessions (request_id,teacher_id,learner_id,skill_id,session_title,session_description,session_date,start_time,end_time,session_mode,meeting_link,status,notes) VALUES
(1,2,3,1,'Python Basics for Designers','Variables, functions and small exercises.','2026-08-28','19:00:00','20:00:00','online','https://meet.example.com/python-guitar','completed','Great first swap.'),
(2,3,2,16,'Guitar Fundamentals','Chords, rhythm and practice routine.','2026-08-29','18:00:00','19:00:00','offline',NULL,'completed','Practice G and C chords.'),
(5,6,3,21,'Calculus Crash Session','Limits and derivative problem solving.','2026-09-01','20:00:00','21:00:00','online','https://meet.example.com/calculus','scheduled',NULL),
(6,3,6,16,'Guitar Chords','Basic chord transitions.','2026-09-02','18:30:00','19:30:00','offline',NULL,'scheduled',NULL),
(8,5,8,14,'Premiere Editing Workflow','Timeline, cuts and audio cleanup.','2026-09-03','17:00:00','18:00:00','online','https://meet.example.com/premiere','scheduled',NULL),
(10,11,7,8,'SQL Joins','INNER JOIN and LEFT JOIN practice.','2026-09-04','19:00:00','20:00:00','online','https://meet.example.com/sql','scheduled',NULL),
(12,4,10,26,'Photography Basics','Composition and lighting walk-through.','2026-09-05','16:00:00','17:00:00','offline',NULL,'scheduled',NULL),
(1,3,2,16,'Guitar Rhythm Practice','Strumming and timing.','2026-08-20','18:00:00','19:00:00','offline',NULL,'completed','Nice progress.'),
(2,2,3,1,'Python Mini Project','Build a CLI calculator.','2026-08-21','19:00:00','20:00:00','online','https://meet.example.com/python2','completed','Learner completed exercises.'),
(5,6,3,21,'Derivative Practice','More derivative questions.','2026-08-22','20:00:00','21:00:00','online','https://meet.example.com/calc2','completed','Good improvement.'),
(6,3,6,16,'Open Chords','Open chords and rhythm.','2026-08-23','18:00:00','19:00:00','offline',NULL,'completed','Keep practicing.'),
(8,5,8,14,'Color Correction','Basic color correction.','2026-08-24','17:00:00','18:00:00','online','https://meet.example.com/color','completed','Good first edit.'),
(10,11,7,8,'SQL Aggregates','COUNT, AVG and GROUP BY.','2026-08-25','19:00:00','20:00:00','online','https://meet.example.com/sql2','completed','Ready for HAVING.'),
(12,4,10,26,'Camera Settings','Exposure triangle.','2026-08-18','16:00:00','17:00:00','offline',NULL,'completed','Excellent questions.'),
(3,2,3,8,'SQL Fundamentals','Tables, keys and basic SELECT.','2026-09-07','20:00:00','21:00:00','online','https://meet.example.com/sql3','scheduled',NULL);

INSERT INTO Messages (sender_id,receiver_id,message_text,is_read) VALUES
(2,3,'Hey Sara! Ready for our Python session?','1'),
(3,2,'Absolutely. I prepared a small exercise.','1'),
(2,3,'Perfect! I will bring the guitar questions too.','1'),
(3,2,'Deal.','1'),
(6,3,'Would you like to schedule another calculus session?','0'),
(3,6,'Yes, next week works.','1'),
(5,8,'I can show you a Premiere workflow.','1'),
(8,5,'Awesome, I want to learn transitions too.','1'),
(7,11,'Are you free for SQL this weekend?','0'),
(11,7,'Saturday evening should work.','1'),
(10,4,'Thanks for accepting the photography swap!','1'),
(4,10,'Looking forward to it.','1'),
(13,2,'Interested in a guitar/Python exchange?','0'),
(2,13,'Yes, tell me your availability.','0'),
(9,12,'Can we discuss academic writing?','0'),
(12,9,'Sure, I can help with structure.','1'),
(11,2,'Your SQL notes were useful.','1'),
(2,11,'Glad they helped!','1'),
(4,7,'I saw your UI work. Nice job.','1'),
(7,4,'Thank you!','1'),
(8,12,'Your marketing tips are great.','1'),
(12,8,'Happy to share.','1'),
(3,7,'Would you like a Photoshop/UI swap?','0'),
(7,3,'That could work!','1'),
(6,2,'Python and calculus pair well for tutoring.','1'),
(2,6,'Agreed.','1'),
(10,11,'Can you recommend SQL resources?','0'),
(11,10,'Sure, I have some lab examples.','1'),
(13,3,'Your guitar progress looks great.','1'),
(3,13,'Thanks!','1'),
(5,12,'Could you review my video?','0'),
(12,5,'Send it over.','0');

INSERT INTO Reviews (session_id,reviewer_id,reviewed_user_id,rating,review_text) VALUES
(1,3,2,5,'Very clear Python explanations.'),
(2,2,3,5,'Patient and friendly guitar teacher.'),
(8,2,3,5,'Fun rhythm session.'),
(9,3,2,4,'Good mini project guidance.'),
(10,3,6,5,'Excellent calculus tutoring.'),
(11,6,3,5,'Great guitar teacher.'),
(12,8,5,5,'Amazing editing workflow.'),
(13,7,11,5,'SQL examples were easy to follow.'),
(14,10,4,4,'Helpful photography guidance.'),
(14,4,10,5,'Great photographer and mentor.');

INSERT INTO Achievements (user_id,achievement_name,description,badge_icon,achievement_type) VALUES
(2,'First Swap','Completed the first learning session.','★','milestone'),
(2,'Skill Sharer','Taught five learning sessions.','⚡','teaching'),
(2,'Brain Exchanger','Completed multiple skill exchanges.','♻','exchange'),
(3,'First Swap','Completed the first learning session.','★','milestone'),
(3,'Top Mentor','Received consistently high ratings.','🏆','rating'),
(3,'Community Builder','Completed ten community activities.','◆','community'),
(5,'First Swap','Completed the first learning session.','★','milestone'),
(6,'Top Mentor','Received consistently high ratings.','🏆','rating'),
(7,'Curious Mind','Completed multiple learning sessions.','◈','learning'),
(8,'First Swap','Completed the first learning session.','★','milestone'),
(11,'Skill Sharer','Taught five learning sessions.','⚡','teaching'),
(4,'First Swap','Completed the first learning session.','★','milestone'),
(10,'Curious Mind','Completed multiple learning sessions.','◈','learning'),
(12,'Skill Sharer','Shared marketing knowledge.','⚡','teaching'),
(13,'Brain Exchanger','Joined multiple skill exchanges.','♻','exchange');

INSERT INTO Admins (user_id,admin_level,permissions) VALUES
(1,'superadmin','users,skills,categories,requests,sessions,reviews'),
(11,'moderator','reviews,requests');

INSERT INTO SkillRequests (sender_id,receiver_id,requested_skill_id,offered_skill_id,message,status) VALUES
(13,2,1,16,'I can teach guitar while learning Python.','pending',NULL);

-- Additional 20+ UserSkills records for a rich demo
INSERT INTO UserSkills (user_id,skill_id,skill_type,proficiency_level,years_experience) VALUES
(2,5,'teach','Intermediate',2),(2,6,'teach','Intermediate',1),
(3,12,'teach','Advanced',3),(3,13,'teach','Intermediate',2),
(4,4,'teach','Advanced',4),(4,5,'teach','Advanced',4),
(5,15,'teach','Intermediate',2),(5,25,'learn','Beginner',0),
(6,22,'teach','Advanced',3),(6,27,'teach','Intermediate',2),
(7,11,'teach','Intermediate',1),(7,20,'learn','Beginner',0),
(8,25,'teach','Intermediate',2),(8,27,'learn','Beginner',0),
(9,27,'teach','Advanced',4),(9,24,'learn','Beginner',0),
(10,11,'learn','Beginner',0),(10,12,'learn','Beginner',0),
(11,3,'teach','Intermediate',2),(11,9,'learn','Beginner',0),
(12,14,'learn','Beginner',0),(12,20,'teach','Intermediate',2),
(13,18,'teach','Intermediate',3),(13,4,'learn','Beginner',0);
