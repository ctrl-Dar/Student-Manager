<?php

declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require dirname(__DIR__) . '/app/bootstrap.php';

$name = trim($argv[1] ?? '');
$email = strtolower(trim($argv[2] ?? ''));
if (!$name || mb_strlen($name) > 100 || strlen($email) > 190 || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    fwrite(STDERR, "Usage: php bin/create-admin.php 'Name' admin@example.com\n");
    exit(1);
}
fwrite(STDERR, "Enter a password of at least 12 characters: ");
$password = rtrim((string) fgets(STDIN), "\r\n");
if (strlen($password) < 12 || strlen($password) > 72 || str_contains($password, "\0")) {
    fwrite(STDERR, "Password must be 12 to 72 bytes.\n");
    exit(1);
}
try {
    query('INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)',
        [$name, $email, password_hash($password, PASSWORD_DEFAULT), 'admin']);
    echo "Administrator created.\n";
} catch (PDOException $error) {
    fwrite(STDERR, "Unable to create the administrator. Check the database connection and use a unique email.\n");
    exit(1);
}
