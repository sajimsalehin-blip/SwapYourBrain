<?php
require_once 'config/database.php'; require_once 'includes/auth.php'; require_once 'includes/functions.php';
if (current_user()) redirect('dashboard.php');
if ($_SERVER['REQUEST_METHOD']==='POST') {
    verify_csrf();
    $login=trim($_POST['login']??''); $pass=$_POST['password']??'';
    $s=$pdo->prepare("SELECT * FROM Users WHERE (email=? OR username=?) AND status='active' LIMIT 1"); $s->execute([$login,$login]); $u=$s->fetch();
    if($u && password_verify($pass,$u['password_hash'])) { session_regenerate_id(true); $_SESSION['user']=$u; redirect('dashboard.php'); }
    flash('error','Invalid credentials.');
}
$title='Login'; include 'includes/header.php';
?>
<div class="auth-wrap"><div class="auth-card"><div class="eyebrow">WELCOME BACK</div><h1>Log in.</h1><p class="muted">Continue your next skill exchange.</p>
<form method="post" class="form"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><label>Email or username<input name="login" required autofocus></label><label>Password<input type="password" name="password" required></label><button class="btn">Log in →</button></form>
<div class="demo"><b>Demo:</b> alex@example.com / User@123</div><p class="muted">No account? <a href="register.php">Create one</a></p></div></div>
<?php include 'includes/footer.php'; ?>
