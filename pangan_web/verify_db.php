<?php
// Verify database tables
try {
    $pdo = new PDO("mysql:host=127.0.0.1;dbname=simhpsb_db", 'root', '');
    
    $tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    
    echo "=== EXISTING TABLES ===\n";
    foreach ($tables as $table) {
        echo "  ✓ $table\n";
    }
    
    if (empty($tables)) {
        echo "  ✗ No tables found!\n";
    }
    
    // Check specific tables
    $requiredTables = ['users', 'petani', 'lahan', 'panen', 'gudang', 'stok_beras', 'harga', 'distribusi', 'alerts'];
    echo "\n=== REQUIRED TABLES ===\n";
    foreach ($requiredTables as $table) {
        $exists = in_array($table, $tables);
        echo "  " . ($exists ? "✓" : "✗") . " $table\n";
    }
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
