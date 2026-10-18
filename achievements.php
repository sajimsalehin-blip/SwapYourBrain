<?php
require_once 'config/database.php';require_once 'includes/auth.php';require_once 'includes/functions.php';require_login();$s=$pdo->prepare("SELECT * FROM Achievements WHERE user_id=? ORDER BY earned_at DESC");$s->execute([current_user()['user_id']]);$rows=$s->fetchAll();$title='Achievements';include 'includes/header.php';
?>
<div class="page-head"><div><div class="eyebrow">MILESTONES</div><h1>Your achievements.</h1><p class="muted">Every swap leaves a little evidence of growth.</p></div></div><div class="grid cards-3"><?php foreach($rows as $a):?><div class="card achievement-card"><div class="badge-icon"><?=$a['badge_icon']?></div><h3><?=e($a['achievement_name'])?></h3><p><?=e($a['description'])?></p><small><?=e($a['earned_at'])?></small></div><?php endforeach;?></div>
<?php include 'includes/footer.php'; ?>
