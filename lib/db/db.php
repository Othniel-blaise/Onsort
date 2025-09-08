<?php
// fichier: db.php
$host = "localhost";
$user = "root"; // par défaut sous WAMP
$pass = ""; // mot de passe root (souvent vide)
$db = "auth_db";


$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
die("Erreur de connexion: " . $conn->connect_error);
}
?>