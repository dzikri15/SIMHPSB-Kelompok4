<?php
// Check MySQL version
try {
    $pdo = new PDO("mysql:host=127.0.0.1", 'root', '');
    $version = $pdo->query('SELECT VERSION()')->fetchColumn();
    echo "MySQL Version: $version\n";
    
    $pdo = null;
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
