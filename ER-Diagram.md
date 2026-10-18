# Swap Your Brain — ER Diagram

The database contains **exactly 12 tables**.

```mermaid
erDiagram
    Users ||--|| UserProfiles : has
    SkillCategories ||--o{ Skills : contains
    Users ||--o{ UserSkills : owns
    Skills ||--o{ UserSkills : tagged
    Users ||--o{ SkillRequests : sends
    Users ||--o{ SkillRequests : receives
    Skills ||--o{ SkillRequests : requested
    Skills ||--o{ SkillRequests : offered
    Users ||--o{ SkillMatches : user1
    Users ||--o{ SkillMatches : user2
    Skills ||--o{ SkillMatches : skill1
    Skills ||--o{ SkillMatches : skill2
    SkillRequests ||--o{ LearningSessions : creates
    Users ||--o{ LearningSessions : teaches
    Users ||--o{ LearningSessions : learns
    Skills ||--o{ LearningSessions : covers
    Users ||--o{ Messages : sends
    Users ||--o{ Messages : receives
    LearningSessions ||--o{ Reviews : receives
    Users ||--o{ Reviews : writes
    Users ||--o{ Reviews : receives
    Users ||--o{ Achievements : earns
    Users ||--o| Admins : administers
```

The central many-to-many concepts are represented through `UserSkills`, while exchange compatibility is materialized in `SkillMatches`. `SkillRequests` connects users and skills, and accepted requests can produce `LearningSessions`.
