<<<<<<< HEAD
# Swap Your Brain

> A peer-to-peer skill-sharing platform where everyone can teach and everyone can learn.

## Tech stack
- PHP 8+
- MySQL/MariaDB
- HTML/CSS
- Vanilla JavaScript
- PDO
- XAMPP / Apache

No Node.js, Laravel, Composer or build step is required.

## Database
Database name: `swap_your_brain`

**Exactly 12 tables** are created by `database.sql`.

## XAMPP setup

1. Install XAMPP and start **Apache** and **MySQL**.
2. Copy the `swap-your-brain` folder into `C:\xampp\htdocs\`.
3. Open `http://localhost/phpmyadmin`.
4. Import `database.sql`.
5. Confirm the database `swap_your_brain` exists.
6. If your MySQL root account has a password, edit `config/database.php`.
7. Visit `http://localhost/swap-your-brain/`.

## Demo accounts

### Admin
Email: `admin@swapyourbrain.com`
Password: `Admin@123`

### User
Email: `alex@example.com`
Password: `User@123`

The same demo user password is used for the seeded non-admin accounts.

## Main features
- Registration / login / logout
- Password hashing
- Session authentication
- User profiles
- Teach / learn skill relationships
- Skill and user search
- SQL-backed skill matching
- Skill exchange requests
- Learning sessions
- Messaging
- Reviews and ratings
- Achievement badges
- Admin dashboard
- User activation/deactivation
- Skill/category management
- Relational sample SQL queries

## Folder structure

- `index.php` — landing page
- `login.php`, `register.php`, `logout.php` — authentication
- `skills.php`, `skill-details.php`, `users.php` — public discovery
- `dashboard.php` — user dashboard
- `profile.php`, `edit-profile.php` — profile
- `my-skills.php`, `add-skill.php` — skills
- `matches.php` — matching
- `requests.php` — exchange requests
- `sessions.php`, `schedule-session.php` — learning sessions
- `messages.php` — messaging
- `reviews.php` — ratings
- `achievements.php` — badges
- `admin/` — administrator pages
- `config/` — database connection
- `includes/` — shared authentication/UI/functions
- `assets/` — CSS/JavaScript
- `database.sql` — schema + seed data
- `sample-queries.sql` — SQL demonstration
- `DATABASE-DESIGN.md` — schema documentation
- `ER-Diagram.md` / `ER-Diagram.png` — ER documentation
- `PROJECT-REPORT.md` — project report

## Security
The project uses PDO prepared statements, `password_hash()`, `password_verify()`, sessions, CSRF tokens on state-changing forms, authorization checks, server-side validation and `htmlspecialchars()` for displayed user data.

## Troubleshooting

**Database connection failed:** make sure MySQL is running and the database has been imported.

**Access denied:** update the username/password in `config/database.php`.

**Page not found:** make sure the project is inside the XAMPP `htdocs` directory.

**Login fails:** import the supplied SQL again so the generated password hashes are restored.

## Viva focus

Be prepared to explain:
1. Why `UserSkills` is necessary.
2. The PK/FK relationships.
3. Why requests reference two users and two skills.
4. How `SkillMatches` represents compatibility.
5. Why prepared statements are used.
6. How CRUD is implemented.
7. How `JOIN`, `GROUP BY`, `COUNT`, `AVG`, `LIKE` and `HAVING` are used.
8. Why there are exactly 12 tables.
=======
# SwapYourBrain
Skill Exchanging website 
>>>>>>> d42e9f37f1745e91e3a89ddb1e93e13e11f756de
