<?php
require_once 'config/database.php'; require_once 'includes/auth.php'; require_once 'includes/functions.php';
if (current_user()) redirect('dashboard.php');
if ($_SERVER['REQUEST_METHOD']==='POST') {
    verify_csrf(); $first=trim($_POST['first_name']??''); $last=trim($_POST['last_name']??''); $username=trim($_POST['username']??''); $email=trim($_POST['email']??''); $pass=$_POST['password']??''; $confirm=$_POST['confirm']??'';
    if(!$first||!$last||!$username||!filter_var($email,FILTER_VALIDATE_EMAIL)||strlen($pass)<8||$pass!==$confirm) flash('error','Please complete the form correctly. Password must be 8+ characters and match confirmation.');
    else {
      $s=$pdo->prepare("SELECT COUNT(*) FROM Users WHERE username=? OR email=?"); $s->execute([$username,$email]);
      if($s->fetchColumn()) flash('error','Username or email already exists.');
      else {
        $s=$pdo->prepare("INSERT INTO Users(username,email,password_hash,first_name,last_name) VALUES(?,?,?,?,?)"); $s->execute([$username,$email,password_hash($pass,PASSWORD_DEFAULT),$first,$last]);
        $uid=(int)$pdo->lastInsertId(); $pdo->prepare("INSERT INTO UserProfiles(user_id) VALUES(?)")->execute([$uid]);
        $s=$pdo->prepare("SELECT * FROM Users WHERE user_id=?"); $s->execute([$uid]); $_SESSION['user']=$s->fetch(); flash('success','Account created. Welcome to the community!'); redirect('dashboard.php');
      }
    }
}
$title='Create account'; include 'includes/header.php';
?>
<div class="auth-wrap"><div class="auth-card wide"><div class="eyebrow">JOIN THE COMMUNITY</div><h1>Create your account.</h1><p class="muted">Bring one skill. Leave with another.</p>
<form method="post" class="form"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><div class="form-grid"><label>First name<input name="first_name" required></label><label>Last name<input name="last_name" required></label></div><div class="form-grid"><label>Username<input name="username" required></label><label>Email<input type="email" name="email" required></label></div><div class="form-grid"><label>Password<input type="password" name="password" minlength="8" required></label><label>Confirm password<input type="password" name="confirm" minlength="8" required></label></div><button class="btn">Create account →</button></form></div></div>
<?php include 'includes/footer.php'; ?>
