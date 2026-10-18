# SWAP YOUR BRAIN — PROJECT REPORT

## 1. Project Name
Swap Your Brain

## 2. Introduction
Swap Your Brain is a peer-to-peer skill-sharing platform designed around the idea that users can exchange knowledge instead of paying for conventional lessons.

## 3. Problem Statement
Students often possess useful skills but lack an easy way to discover people who need those skills while offering something they themselves want to learn.

## 4. Proposed Solution
The system stores users, profiles, skills, teach/learn relationships, requests, matches, sessions, messages, reviews and achievements in a relational MySQL database.

## 5. Objectives
- Enable skill discovery.
- Support reciprocal skill exchange.
- Demonstrate relational SQL concepts.
- Implement complete CRUD workflows.
- Provide authentication and role-based authorization.
- Demonstrate joins and aggregate queries.

## 6. Target Users
University students, hobbyists, peer tutors and learners.

## 7. Functional Requirements
Registration, login, profile management, skill management, searching, matching, requests, sessions, messaging, reviews, achievements and administration.

## 8. Non-functional Requirements
Security, usability, responsive design, maintainability and database integrity.

## 9. ER Diagram
See `ER-Diagram.md` and `ER-Diagram.png`.

## 10. Database Table Structure
See `DATABASE-DESIGN.md`.

## 11. Primary Keys
Every table has a surrogate integer primary key.

## 12. Foreign Keys
Foreign keys connect profiles to users, skills to categories, user skills to users/skills, requests to users/skills, matches to users/skills, sessions to requests/users/skills, messages to users, reviews to sessions/users, achievements to users and admins to users.

## 13. Relationships
The design contains one-to-one, one-to-many and associative relationships.

## 14. CRUD Implementation
Create/read/update/delete operations are implemented across profiles, skills, requests, sessions, messages, reviews and administrative data.

## 15. Authentication
PHP sessions provide login state. Passwords are stored using `password_hash()` and verified using `password_verify()`.

## 16. Search
Skill and user directories use parameterized SQL `LIKE` queries plus category and difficulty filters.

## 17. Smart Matching
Compatibility is represented in `SkillMatches`. A perfect two-way exchange occurs when one user's teach skill equals another user's learn skill and vice versa.

## 18. Admin Implementation
Administrators can view users, activate/deactivate users, manage skills/categories and inspect requests, sessions and reviews.

## 19. UI/UX
The interface uses a dark SaaS-style design, responsive grids, reusable cards, badges, forms and subtle transitions.

## 20. Best Feature
The reciprocal skill matching concept directly demonstrates how normalized relational data can produce useful application-level recommendations.

## 21. Security
Prepared statements, password hashing, sessions, authorization checks, output escaping, CSRF tokens and server-side validation are used.

## 22. Future Improvements
Real-time messaging, image uploads, availability calendars, stronger matching algorithms, notifications and moderation workflows could be added without changing the core 12-table requirement.

## 23. Installation
See `README.md`.

## 24. Demo Credentials
Admin: `admin@swapyourbrain.com` / `Admin@123`

User: `alex@example.com` / `User@123`
