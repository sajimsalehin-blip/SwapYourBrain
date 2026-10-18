<?php
require_once 'config/database.php';require_once 'includes/auth.php';require_once 'includes/functions.php';require_login();$uid=current_user()['user_id'];
if($_SERVER['REQUEST_METHOD']==='POST'){verify_csrf();
    // Use explicit named parameters so every placeholder maps unambiguously to one value.
    $sql="UPDATE UserProfiles SET
        headline=:headline,
        university=:university,
        department=:department,
        academic_year=:academic_year,
        phone=:phone,
        linkedin_url=:linkedin_url,
        github_url=:github_url,
        portfolio_url=:portfolio_url,
        availability=:availability,
        learning_preferences=:learning_preferences
        WHERE user_id=:user_id";
    $params=[];
    foreach(['headline','university','department','academic_year','phone','linkedin_url','github_url','portfolio_url','availability','learning_preferences'] as $f){$params[$f]=trim($_POST[$f]??'');}
    $params['user_id']=$uid;
    $pdo->prepare($sql)->execute($params);
    $pdo->prepare("UPDATE Users SET bio=:bio, location=:location WHERE user_id=:user_id")->execute([
        'bio'=>trim($_POST['bio']??''),
        'location'=>trim($_POST['location']??''),
        'user_id'=>$uid
    ]);
    flash('success','Profile updated.');redirect('profile.php?id='.$uid);
}
$s=$pdo->prepare("SELECT u.*,p.* FROM Users u LEFT JOIN UserProfiles p ON p.user_id=u.user_id WHERE u.user_id=?");$s->execute([$uid]);$u=$s->fetch();$title='Edit profile';include 'includes/header.php';
?>
<div class="page-head"><div><div class="eyebrow">YOUR PROFILE</div><h1>Edit profile.</h1></div></div><form method="post" class="card form"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><div class="form-grid"><label>Headline<input name="headline" value="<?=e($u['headline'])?>"></label><label>University<input name="university" value="<?=e($u['university'])?>"></label></div><div class="form-grid"><label>Department<input name="department" value="<?=e($u['department'])?>"></label><label>Academic year<input name="academic_year" value="<?=e($u['academic_year'])?>"></label></div><div class="form-grid"><label>Location<input name="location" value="<?=e($u['location'])?>"></label><label>Phone<input name="phone" value="<?=e($u['phone'])?>"></label></div><label>Bio<textarea name="bio"><?=e($u['bio'])?></textarea></label><div class="form-grid"><label>LinkedIn<input name="linkedin_url" value="<?=e($u['linkedin_url'])?>"></label><label>GitHub<input name="github_url" value="<?=e($u['github_url'])?>"></label></div><label>Portfolio<input name="portfolio_url" value="<?=e($u['portfolio_url'])?>"></label><label>Availability<input name="availability" value="<?=e($u['availability'])?>"></label><label>Learning preferences<textarea name="learning_preferences"><?=e($u['learning_preferences'])?></textarea></label><button class="btn">Save changes</button></form>
<?php include 'includes/footer.php'; ?>
