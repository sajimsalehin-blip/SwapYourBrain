<?php
require_once 'config/database.php';
require_once 'includes/auth.php';
require_once 'includes/functions.php';
require_login();
$uid = current_user()['user_id'];
$rows = find_matches($pdo, $uid, 50);
$title='Matches';
include 'includes/header.php';
?>
<div class="page-head">
  <div>
    <div class="eyebrow">SMART MATCHING</div>
    <h1>Your compatible swappers.</h1>
    <p class="muted">Matches are calculated live from your teach/learn skills in MySQL.</p>
  </div>
</div>

<?php if (!$rows): ?>
  <div class="empty">
    <h2>No matches yet.</h2>
    <p>Add at least one skill you can teach and one skill you want to learn. Then come back here.</p>
    <a class="btn" href="add-skill.php">+ Add a skill</a>
  </div>
<?php else: ?>
  <div class="grid cards-2">
    <?php foreach($rows as $m): ?>
      <div class="card match-card">
        <div class="match-score"><?=number_format((float)$m['compatibility_score'],0)?>%</div>
        <div class="avatar"><?=e(initials($m['first_name'],$m['last_name']))?></div>
        <h2><?=e($m['first_name'].' '.$m['last_name'])?></h2>
        <p class="muted"><?=e($m['bio'])?></p>
        <div class="swap">
          <span><?=e($m['they_can_teach'] ?? 'Relevant skill')?></span>
          <b>↔</b>
          <span><?=e($m['i_can_teach'] ?? 'Your skill')?></span>
        </div>
        <p class="muted">
          <?php if ((float)$m['compatibility_score'] >= 100): ?>Perfect two-way exchange<?php else: ?>One-way useful match<?php endif; ?>
        </p>
        <div class="actions">
          <a class="btn full" href="profile.php?id=<?=$m['other_id']?>">View profile & request</a>
        </div>
      </div>
    <?php endforeach; ?>
  </div>
<?php endif; ?>
<?php include 'includes/footer.php'; ?>
