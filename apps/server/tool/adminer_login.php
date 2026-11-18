<?php
$signedIn = !empty($_SESSION['pwds']['pgsql']['db'][getenv('POSTGRES_USER')]);
if (!$signedIn && !isset($_POST['auth']) && !isset($_GET['logout'])) {
    $_POST['auth'] = [
        'driver' => 'pgsql',
        'server' => 'db',
        'username' => getenv('POSTGRES_USER'),
        'password' => getenv('POSTGRES_PASSWORD'),
        'db' => getenv('POSTGRES_DB'),
    ];
}

return new class extends \Adminer\Plugin {};
