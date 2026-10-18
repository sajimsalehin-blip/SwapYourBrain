<?php
require_once 'config/database.php'; require_once 'includes/auth.php'; require_once 'includes/functions.php';
$title='Learn differently';
$skills=$pdo->query("SELECT s.*, c.category_name, COUNT(us.user_skill_id) AS people FROM Skills s JOIN SkillCategories c ON c.category_id=s.category_id LEFT JOIN UserSkills us ON us.skill_id=s.skill_id GROUP BY s.skill_id ORDER BY people DESC LIMIT 8")->fetchAll();
$users=$pdo->query("SELECT u.user_id,u.first_name,u.last_name,u.bio,u.location,COALESCE(AVG(r.rating),0) rating FROM Users u LEFT JOIN Reviews r ON r.reviewed_user_id=u.user_id WHERE u.status='active' AND u.role='user' GROUP BY u.user_id ORDER BY rating DESC,u.created_at DESC LIMIT 6")->fetchAll();
include 'includes/header.php';
?>
<section class="hero">
  <div class="eyebrow">PEER-TO-PEER LEARNING</div>
  <h1>Trade knowledge.<br><em>Grow together.</em></h1>
  <p class="hero-copy">Exchange skills, discover people, and learn something new without money. Everyone has something to teach. Everyone has something to learn.</p>
  <div class="actions"><a class="btn" href="skills.php">Find a skill →</a><a class="btn ghost" href="register.php">Start swapping</a></div>
  <div class="hero-stats"><span><b>12+</b> learners</span><span><b>25+</b> skills</span><span><b>100%</b> peer powered</span></div>
</section>
<section class="section">
  <div class="section-head"><div><div class="eyebrow">DISCOVER</div><h2>Popular skills</h2></div><a href="skills.php">Browse all →</a></div>
  <div class="grid cards-4">
  <?php foreach($skills as $s): ?><a class="card skill-card" href="skill-details.php?id=<?=$s['skill_id']?>"><span class="icon">✦</span><small><?=e($s['category_name'])?></small><h3><?=e($s['skill_name'])?></h3><p><?=e($s['description'])?></p><span class="muted"><?=$s['people']?> people sharing</span></a><?php endforeach; ?>
  </div>
</section>
<section class="section split">
  <div><div class="eyebrow">HOW IT WORKS</div><h2>One skill in.<br>One skill out.</h2><p class="muted">Find someone who can teach what you want to learn, while you teach something they need. Our relational matching engine surfaces complementary exchanges.</p></div>
  <div class="steps"><div><b>01</b><strong>Build your profile</strong><span>Tell the community what you know and what you want to learn.</span></div><div><b>02</b><strong>Find your match</strong><span>Compare skills and compatibility scores.</span></div><div><b>03</b><strong>Make the swap</strong><span>Request, schedule, learn, review, repeat.</span></div></div>
</section>
<section class="section">
  <div class="section-head"><div><div class="eyebrow">COMMUNITY</div><h2>Featured swappers</h2></div><a href="users.php">Meet everyone →</a></div>
  <div class="grid cards-3">
  <?php foreach($users as $u): ?><a class="card person-card" href="profile.php?id=<?=$u['user_id']?>"><div class="avatar"><?=e(initials($u['first_name'],$u['last_name']))?></div><div><h3><?=e($u['first_name'].' '.$u['last_name'])?></h3><p><?=e($u['bio'])?></p><span class="rating">★ <?=number_format((float)$u['rating'],1)?></span></div></a><?php endforeach; ?>
  </div>
</section>
<section class="cta"><div class="eyebrow">READY?</div><h2>Don't just learn.<br><em>Swap your brain.</em></h2><a class="btn" href="register.php">Create free account →</a></section>
<?php include 'includes/footer.php'; ?>
