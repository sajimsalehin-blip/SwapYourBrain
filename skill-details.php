<?php
require_once 'config/database.php'; require_once 'includes/auth.php'; require_once 'includes/functions.php';
$id=(int)($_GET['id']??0); $s=$pdo->prepare("SELECT s.*,c.category_name FROM Skills s JOIN SkillCategories c ON c.category_id=s.category_id WHERE s.skill_id=?");$s->execute([$id]);$skill=$s->fetch();if(!$skill){http_response_code(404);exit('Skill not found.');}
$q=$pdo->prepare("SELECT u.user_id,u.first_name,u.last_name,u.bio,u.location,us.proficiency_level,us.years_experience,us.description FROM UserSkills us JOIN Users u ON u.user_id=us.user_id WHERE us.skill_id=? AND us.skill_type='teach' AND u.status='active' ORDER BY us.proficiency_level DESC");$q->execute([$id]);$teachers=$q->fetchAll();
$title=$skill['skill_name'];include 'includes/header.php';
?>
<div class="detail-hero"><div class="icon huge">✦</div><div><div class="eyebrow"><?=e($skill['category_name'])?></div><h1><?=e($skill['skill_name'])?></h1><p class="muted"><?=e($skill['description'])?></p><span class="badge"><?=$skill['difficulty_level']?></span></div></div>
<section class="section"><div class="section-head"><h2>People who can teach this</h2><span class="muted"><?=count($teachers)?> available</span></div><div class="grid cards-3"><?php foreach($teachers as $u): ?><a class="card person-card" href="profile.php?id=<?=$u['user_id']?>"><div class="avatar"><?=e(initials($u['first_name'],$u['last_name']))?></div><div><h3><?=e($u['first_name'].' '.$u['last_name'])?></h3><p><?=e($u['bio'])?></p><span class="muted"><?=$u['proficiency_level']?> · <?=$u['years_experience']?> yrs</span></div></a><?php endforeach;?></div></section>
<?php include 'includes/footer.php'; ?>
