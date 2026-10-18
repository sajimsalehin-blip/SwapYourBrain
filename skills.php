<?php
require_once 'config/database.php'; require_once 'includes/auth.php'; require_once 'includes/functions.php';
$q=trim($_GET['q']??''); $cat=(int)($_GET['category']??0); $difficulty=$_GET['difficulty']??'';
$sql="SELECT s.*,c.category_name,(SELECT COUNT(*) FROM UserSkills x WHERE x.skill_id=s.skill_id AND x.skill_type='teach') teachers,(SELECT COUNT(*) FROM UserSkills x WHERE x.skill_id=s.skill_id AND x.skill_type='learn') learners FROM Skills s JOIN SkillCategories c ON c.category_id=s.category_id WHERE 1=1"; $params=[];
if($q){$sql.=" AND (s.skill_name LIKE ? OR s.description LIKE ? OR c.category_name LIKE ?)";$params=["%$q%","%$q%","%$q%"];}
if($cat){$sql.=" AND s.category_id=?";$params[]=$cat;} if($difficulty){$sql.=" AND s.difficulty_level=?";$params[]=$difficulty;}
$sql.=" ORDER BY teachers DESC,s.skill_name"; $st=$pdo->prepare($sql);$st->execute($params);$skills=$st->fetchAll();$cats=$pdo->query("SELECT * FROM SkillCategories ORDER BY category_name")->fetchAll();
$title='Skill directory'; include 'includes/header.php';
?>
<div class="page-head"><div><div class="eyebrow">SKILL DIRECTORY</div><h1>Find your next skill.</h1><p class="muted">Search people, topics and categories across the community.</p></div></div>
<form class="filterbar" method="get"><input name="q" value="<?=e($q)?>" placeholder="Search Python, design, music..."><select name="category"><option value="0">All categories</option><?php foreach($cats as $c): ?><option value="<?=$c['category_id']?>" <?=$cat==$c['category_id']?'selected':''?>><?=e($c['category_name'])?></option><?php endforeach;?></select><select name="difficulty"><option value="">Any level</option><?php foreach(['Beginner','Intermediate','Advanced'] as $d): ?><option <?=$difficulty===$d?'selected':''?>><?=$d?></option><?php endforeach;?></select><button class="btn">Search</button></form>
<div class="grid cards-3"><?php foreach($skills as $s): ?><a class="card skill-card" href="skill-details.php?id=<?=$s['skill_id']?>"><div class="skill-top"><span class="icon">✦</span><span class="badge"><?=$s['difficulty_level']?></span></div><small><?=e($s['category_name'])?></small><h3><?=e($s['skill_name'])?></h3><p><?=e($s['description'])?></p><div class="stats-row"><span>↗ <?=$s['teachers']?> teach</span><span>↘ <?=$s['learners']?> learn</span></div></a><?php endforeach; ?></div>
<?php if(!$skills): ?><div class="empty">No skills matched your search.</div><?php endif; ?>
<?php include 'includes/footer.php'; ?>
