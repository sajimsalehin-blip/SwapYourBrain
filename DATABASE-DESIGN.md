# DATABASE DESIGN

## Tables

| Table | Purpose | Primary Key |
|---|---|---|
| Users | Authentication and core identity | user_id |
| UserProfiles | Extended profile data | profile_id |
| SkillCategories | Skill grouping | category_id |
| Skills | Skill catalogue | skill_id |
| UserSkills | User-to-skill teach/learn relationship | user_skill_id |
| SkillRequests | Skill exchange requests | request_id |
| SkillMatches | Calculated compatible exchanges | match_id |
| LearningSessions | Scheduled learning events | session_id |
| Messages | User-to-user messages | message_id |
| Reviews | Session-based ratings | review_id |
| Achievements | Earned badges | achievement_id |
| Admins | Administrative privileges | admin_id |

## Important constraints

- `Users.username` and `Users.email` are UNIQUE.
- `UserProfiles.user_id` is UNIQUE, creating a one-to-one profile relationship.
- `UserSkills(user_id, skill_id, skill_type)` is UNIQUE.
- `Reviews(session_id, reviewer_id)` is UNIQUE.
- Requests, matches, sessions and messages prevent self-referencing through CHECK constraints.
- Ratings are restricted to 1–5.
- Session end time must be later than start time.
- Foreign keys use cascading actions where ownership is appropriate and RESTRICT where deleting referenced skills/categories could destroy historical meaning.
