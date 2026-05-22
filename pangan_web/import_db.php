<?php
// Import database from SQL file
$sqlFile = 'D:\\SIMHPSB\\simhpsb_db.sql';
$sqlContent = file_get_contents($sqlFile);

// Database credentials
$host = '127.0.0.1';
$user = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Split by semicolon and execute each statement
    $statements = array_filter(array_map('trim', explode(';', $sqlContent)));
    
    foreach ($statements as $statement) {
        if (!empty($statement)) {
            $pdo->exec($statement);
            echo "Executed: " . substr($statement, 0, 50) . "...\n";
        }
    }
    
    echo "\n✓ Database imported successfully!\n";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
