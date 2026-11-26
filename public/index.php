<?php

declare(strict_types=1);

require dirname(__DIR__) . '/app/bootstrap.php';
require dirname(__DIR__) . '/app/modules.php';
require dirname(__DIR__) . '/app/records.php';
require dirname(__DIR__) . '/app/views.php';
require dirname(__DIR__) . '/app/dashboard.php';
require dirname(__DIR__) . '/app/student.php';
require dirname(__DIR__) . '/app/attendance.php';

header('Content-Type: text/html; charset=utf-8');
header('Cache-Control: no-store');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: same-origin');
header("Content-Security-Policy: default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; form-action 'self'; base-uri 'none'; frame-ancestors 'self'");

$https = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
session_name('SIMS_SESSION');
session_start([
    'cookie_httponly' => true,
    'cookie_secure' => $https || getenv('APP_COOKIE_SECURE') === '1',
    'cookie_samesite' => 'Lax',
    'use_strict_mode' => true,
    'use_only_cookies' => true,
]);
$_SESSION['csrf'] ??= bin2hex(random_bytes(32));

$page = input($_GET, 'page', 'dashboard');
$action = input($_GET, 'action');
$id = filter_var(input($_GET, 'id'), FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]) ?: 0;
$post = $_SERVER['REQUEST_METHOD'] === 'POST';

try {
    if ($post && !hash_equals($_SESSION['csrf'], input($_POST, 'csrf'))) {
        display_error(403, 'This form has expired. Return to the previous page and reload it.');
        exit;
    }
    $account = user();
    if (!$account) {
        if ($post && $page !== 'login') {
            display_error(401, 'Sign in to continue.');
            exit;
        }
        if ($post) {
            $email = strtolower(input($_POST, 'email'));
            $password = is_string($_POST['password'] ?? null) ? $_POST['password'] : '';
            $candidate = query('SELECT id, password_hash FROM users WHERE email = ?', [$email])->fetch();
            $hash = $candidate['password_hash'] ?? '$2y$12$dIqNhFRc.YlNUPrVpq9/1eHePS2HOGUZIbgIF.BZqTPx4opIjeW5.';
            if (strlen($password) <= 72 && password_verify($password, $hash) && $candidate) {
                session_regenerate_id(true);
                $_SESSION = ['uid' => $candidate['id'], 'csrf' => bin2hex(random_bytes(32))];
                redirect('dashboard');
            }
            login_view('That email and password combination was not recognized.', $email);
            exit;
        }
        login_view();
        exit;
    }

    if ($page === 'logout' && $post) {
        $_SESSION = [];
        $cookie = session_get_cookie_params();
        setcookie(session_name(), '', [
            'expires' => time() - 3600, 'path' => $cookie['path'], 'domain' => $cookie['domain'],
            'secure' => $cookie['secure'], 'httponly' => true, 'samesite' => 'Lax',
        ]);
        session_destroy();
        redirect('login');
    }
    if (in_array($page, ['login', 'logout'], true) && !$post) {
        redirect('dashboard');
    }
    if ($page === 'dashboard' && !$post) {
        dashboard_view($account);
        exit;
    }
    if ($page === 'profile' && !$post) {
        student_view($account, $id, false);
        exit;
    }
    if ($page === 'report' && !$post) {
        student_view($account, $id, true);
        exit;
    }
    if ($page === 'register') {
        if (!can_manage($account)) {
            display_error(403, 'Administrator access is required for the attendance register.', $account);
            exit;
        }
        register_view($account, $post);
        exit;
    }

    $module = modules()[$page] ?? null;
    if (!$module) {
        display_error(404, 'This page could not be found.', $account);
        exit;
    }
    if (!allowed_module($page, $account) || (($action !== '' || $post) && !can_manage($account))) {
        display_error(403, 'Your account does not have access to this action.', $account);
        exit;
    }
    if ($action === '' && !$post) {
        list_view($page, $module, $account);
        exit;
    }
    if ((!$post && !in_array($action, ['new', 'edit'], true))
        || ($post && !in_array($action, ['new', 'edit', 'delete'], true))) {
        display_error(404, 'This action could not be found.', $account);
        exit;
    }

    $existing = $action === 'new' ? null : record($page, $id, $account);
    if ($action !== 'new' && !$existing) {
        display_error(404, 'This record could not be found.', $account);
        exit;
    }
    if (!$post) {
        form_view($page, $module, $account, $existing);
        exit;
    }
    if ($action === 'delete') {
        try {
            delete_record($page, $existing, $account);
            flash(ucfirst($module['item']) . ' deleted.');
        } catch (DomainException $error) {
            flash($error->getMessage(), 'danger');
        } catch (PDOException $error) {
            flash(record_error($error), 'danger');
        }
        redirect($page);
    }

    [$values, $errors] = validate_record($page, $_POST, $existing);
    if (!$errors) {
        try {
            $saved = save_record($page, $values, $existing);
            flash(ucfirst($module['item']) . ' saved.');
            if ($page === 'students') {
                redirect('profile', ['id' => $saved]);
            }
            redirect($page);
        } catch (PDOException $error) {
            $errors['general'] = record_error($error);
        }
    }
    http_response_code(422);
    form_view($page, $module, $account, $existing, $_POST, $errors);
} catch (PDOException $error) {
    error_log('SIMS database error: ' . $error->getMessage());
    display_error(503, 'The database is temporarily unavailable. Check the connection and try again.');
}
