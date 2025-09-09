<?php
include 'db.php';


if ($_SERVER["REQUEST_METHOD"] == "POST") {
$username = trim($_POST['username']);
$email = trim($_POST['email']);
$password = password_hash($_POST['password'], PASSWORD_DEFAULT);


$sql = "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $username, $email, $password);


if ($stmt->execute()) {
echo "Inscription réussie. <a href='login.php'>Connectez-vous ici</a>";
} else {
echo "Erreur: " . $stmt->error;
}
}
?>
<form method="post">
<input type="text" name="username" placeholder="Nom d'utilisateur" required><br>
<input type="email" name="email" placeholder="Email" required><br>
<input type="password" name="password" placeholder="Mot de passe" required><br>
<button type="submit">S'inscrire</button>
</form>