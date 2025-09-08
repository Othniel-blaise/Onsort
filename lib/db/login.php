<?php
include 'db.php';
session_start();


if ($_SERVER["REQUEST_METHOD"] == "POST") {
$email = trim($_POST['email']);
$password = $_POST['password'];


$sql = "SELECT * FROM users WHERE email=?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();


if ($result->num_rows > 0) {
$user = $result->fetch_assoc();
if (password_verify($password, $user['password'])) {
$_SESSION['username'] = $user['username'];
echo "Bienvenue, " . $_SESSION['username'] . " !";
} else {
echo "Mot de passe incorrect.";
}
} else {
echo "Utilisateur introuvable.";
}
}
?>
<form method="post">
<input type="email" name="email" placeholder="Email" required><br>
<input type="password" name="password" placeholder="Mot de passe" required><br>
<button type="submit">Se connecter</button>
</form>