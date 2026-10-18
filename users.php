<?php
require_once 'config/database.php';require_once 'includes/auth.php';require_once 'includes/functions.php';
$q=trim($_GET['q']??'');$sql="SELECT u.*,COALESCE(AVG(r.rating),0) rating,(SELECT COUNT(*) FROM UserSkills us WHERE us.user_id=u.user_id AND us.skill_type='teach') teach_count FROM Users u LEFT JOIN Reviews r ON r.reviewed_user_id=u.user_id WHERE u.status='active' AND u.role='user'";$p=[];
if($q){$sql.=" AND (CONCAT(u.first_name,' ',u.last_name) LIKE ? OR u.username LIKE ? OR u.bio LIKE ? OR u.location LIKE ?)";$p=["%$q%","%$q%","%$q%","%$q%"];}
$sql.=" GROUP BY u.user_id ORDER BY rating DESC,u.first_name";$st=$pdo->prepare($sql);$st->execute($p);$users=$st->fetchAll();$title='People';include 'includes/header.php';
?>
<div class="page-head"><div><div class="eyebrow">THE COMMUNITY</div><h1>Meet the swappers.</h1></div></div>
<form class="filterbar"><input name="q" value="<?=e($q)?>" placeholder="Search by name, location or bio"><button class="btn">Search</button></form>
<div class="grid cards-3"><?php foreach($users as $u): ?><a class="card person-card" href="profile.php?id=<?=$u['user_id']?>"><div class="avatar large"><?=e(initials($u['first_name'],$u['last_name']))?></div><div><h3><?=e($u['first_name'].' '.$u['last_name'])?></h3><p><?=e($u['bio'])?></p><span class="rating">★ <?=number_format((float)$u['rating'],1)?></span><span class="muted"> · <?=$u['teach_count']?> skills taught</span></div></a><?php endforeach;?></div>
<?php include 'includes/footer.php'; ?>
