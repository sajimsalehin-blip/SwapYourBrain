<?php
require_once 'config/database.php';
require_once 'includes/auth.php';
require_once 'includes/functions.php';

$id = (int)($_GET['id'] ?? (current_user()['user_id'] ?? 0));
$st = $pdo->prepare("SELECT u.*,p.* FROM Users u LEFT JOIN UserProfiles p ON p.user_id=u.user_id WHERE u.user_id=?");
$st->execute([$id]);
$u = $st->fetch();
if (!$u) { http_response_code(404); exit('Profile not found.'); }

$me = current_user();

// Handle a skill-exchange request submitted from this profile.
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $me && $me['user_id'] !== $id && ($_POST['action'] ?? '') === 'send_request') {
    verify_csrf();
    $requestedSkill = (int)($_POST['requested_skill_id'] ?? 0);
    $offeredSkill = (int)($_POST['offered_skill_id'] ?? 0);
    $message = trim($_POST['message'] ?? '');

    // The receiver must actually teach the requested skill.
    $q = $pdo->prepare("SELECT COUNT(*) FROM UserSkills WHERE user_id=? AND skill_id=? AND skill_type='teach'");
    $q->execute([$id, $requestedSkill]);
    $receiverTeaches = (int)$q->fetchColumn() > 0;

    // The sender must actually teach the offered skill.
    $q = $pdo->prepare("SELECT COUNT(*) FROM UserSkills WHERE user_id=? AND skill_id=? AND skill_type='teach'");
    $q->execute([$me['user_id'], $offeredSkill]);
    $senderTeaches = (int)$q->fetchColumn() > 0;

    if (!$receiverTeaches || !$senderTeaches) {
        flash('error', 'Please choose valid skills from the two skill lists.');
    } else {
        $q = $pdo->prepare("SELECT COUNT(*) FROM SkillRequests WHERE sender_id=? AND receiver_id=? AND requested_skill_id=? AND offered_skill_id=? AND status='pending'");
        $q->execute([$me['user_id'],$id,$requestedSkill,$offeredSkill]);
        if ((int)$q->fetchColumn() > 0) {
            flash('error', 'You already have a pending request for this skill exchange.');
        } else {
            $q = $pdo->prepare("INSERT INTO SkillRequests (sender_id,receiver_id,requested_skill_id,offered_skill_id,message,status) VALUES (?,?,?,?,?,'pending')");
            $q->execute([$me['user_id'],$id,$requestedSkill,$offeredSkill,$message !== '' ? $message : null]);
            flash('success', 'Skill exchange request sent!');
        }
    }
    redirect('profile.php?id='.$id);
}

$teach = $pdo->prepare("SELECT us.*,s.skill_name FROM UserSkills us JOIN Skills s ON s.skill_id=us.skill_id WHERE us.user_id=? AND us.skill_type='teach' ORDER BY s.skill_name");
$teach->execute([$id]);
$teach = $teach->fetchAll();
$learn = $pdo->prepare("SELECT us.*,s.skill_name FROM UserSkills us JOIN Skills s ON s.skill_id=us.skill_id WHERE us.user_id=? AND us.skill_type='learn' ORDER BY s.skill_name");
$learn->execute([$id]);
$learn = $learn->fetchAll();

$myTeach = [];
if ($me && $me['user_id'] !== $id) {
    $q = $pdo->prepare("SELECT us.skill_id,s.skill_name FROM UserSkills us JOIN Skills s ON s.skill_id=us.skill_id WHERE us.user_id=? AND us.skill_type='teach' ORDER BY s.skill_name");
    $q->execute([$me['user_id']]);
    $myTeach = $q->fetchAll();
}

$reviews = $pdo->prepare("SELECT r.*,u.first_name,u.last_name FROM Reviews r JOIN Users u ON u.user_id=r.reviewer_id WHERE r.reviewed_user_id=? ORDER BY r.created_at DESC LIMIT 5");
$reviews->execute([$id]);
$reviews = $reviews->fetchAll();
$ach = $pdo->prepare("SELECT * FROM Achievements WHERE user_id=? ORDER BY earned_at DESC");
$ach->execute([$id]);
$ach = $ach->fetchAll();

// Show an existing pending request between the two users, if any.
$pendingRequest = null;
if ($me && $me['user_id'] !== $id) {
    $q = $pdo->prepare("SELECT r.request_id,r.sender_id,r.receiver_id,rs.skill_name requested_skill,os.skill_name offered_skill FROM SkillRequests r JOIN Skills rs ON rs.skill_id=r.requested_skill_id JOIN Skills os ON os.skill_id=r.offered_skill_id WHERE r.status='pending' AND ((r.sender_id=? AND r.receiver_id=?) OR (r.sender_id=? AND r.receiver_id=?)) ORDER BY r.created_at DESC LIMIT 1");
    $q->execute([$me['user_id'],$id,$id,$me['user_id']]);
    $pendingRequest = $q->fetch() ?: null;
}

$title = $u['first_name'].' '.$u['last_name'];
include 'includes/header.php';
?>
<div class="profile-hero">
  <div class="avatar xlarge"><?=e(initials($u['first_name'],$u['last_name']))?></div>
  <div class="profile-main">
    <div class="eyebrow"><?=e($u['headline']??'Skill Swapper')?></div>
    <h1><?=e($u['first_name'].' '.$u['last_name'])?></h1>
    <p class="muted"><?=e($u['bio'])?></p>
    <div class="meta">📍 <?=e($u['location']??'Remote')?> · <?=e($u['university']??'Independent')?></div>
  </div>
  <?php if($me && $me['user_id']===$id): ?>
    <a class="btn ghost" href="edit-profile.php">Edit profile</a>
  <?php endif; ?>
</div>

<?php if($me && $me['user_id'] !== $id): ?>
<section class="card" style="margin-bottom:16px">
  <div class="section-head"><div><div class="eyebrow">START A SWAP</div><h2>Send a skill exchange request</h2></div></div>
  <?php if ($pendingRequest): ?>
    <div class="alert success">There is already a pending request between you and this person: <b><?=e($pendingRequest['requested_skill'])?></b> in exchange for <b><?=e($pendingRequest['offered_skill'])?></b>.</div>
  <?php elseif (!$teach): ?>
    <div class="empty">This person has no skills listed yet.</div>
  <?php elseif (!$myTeach): ?>
    <div class="alert error">Add at least one skill you can teach before sending a swap request.</div>
    <a class="btn" href="add-skill.php">+ Add a skill</a>
  <?php else: ?>
    <form method="post" class="form">
      <input type="hidden" name="csrf" value="<?=e(csrf_token())?>">
      <input type="hidden" name="action" value="send_request">
      <div class="form-grid">
        <label>Skill you want to learn from <?=e($u['first_name'])?>
          <select name="requested_skill_id" required>
            <?php foreach($teach as $x): ?><option value="<?=$x['skill_id']?>"><?=e($x['skill_name'])?> · <?=e($x['proficiency_level'])?></option><?php endforeach; ?>
          </select>
        </label>
        <label>Skill you will teach them
          <select name="offered_skill_id" required>
            <?php foreach($myTeach as $x): ?><option value="<?=$x['skill_id']?>"><?=e($x['skill_name'])?></option><?php endforeach; ?>
          </select>
        </label>
      </div>
      <label>Message <span class="muted">(optional)</span>
        <textarea name="message" maxlength="500" placeholder="Tell them why you'd like to swap..."></textarea>
      </label>
      <div class="actions"><button class="btn" type="submit">Send request →</button><a class="btn ghost" href="/swap-your-brain/messages.php?user=<?=$id?>">Message</a></div>
    </form>
  <?php endif; ?>
</section>
<?php endif; ?>

<div class="profile-grid">
<section>
  <div class="card"><h2>Can teach</h2><div class="tags"><?php foreach($teach as $x):?><span class="tag"><?=e($x['skill_name'])?> · <?=e($x['proficiency_level'])?></span><?php endforeach;?></div></div>
  <div class="card"><h2>Wants to learn</h2><div class="tags"><?php foreach($learn as $x):?><span class="tag"><?=e($x['skill_name'])?></span><?php endforeach;?></div></div>
  <div class="card"><h2>Recent reviews</h2><?php foreach($reviews as $r):?><div class="review"><b><?=e($r['first_name'].' '.$r['last_name'])?></b> <span class="rating"><?=str_repeat('★',(int)$r['rating'])?></span><p><?=e($r['review_text'])?></p></div><?php endforeach;?></div>
</section>
<aside>
  <div class="card"><h3>Swap stats</h3><div class="stat"><b><?=number_format(avg_rating($pdo,$id),1)?></b><span>average rating</span></div><div class="stat"><b><?=completed_count($pdo,$id)?></b><span>completed sessions</span></div><div class="stat"><b><?=count($ach)?></b><span>achievements</span></div></div>
  <div class="card"><h3>Achievements</h3><div class="badges"><?php foreach($ach as $a):?><span class="achievement" title="<?=e($a['description'])?>"><?=$a['badge_icon']?> <?=e($a['achievement_name'])?></span><?php endforeach;?></div></div>
</aside>
</div>
<?php include 'includes/footer.php'; ?>
