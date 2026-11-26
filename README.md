# Student Manager for XAMPP

This project uses PHP with a MySQL-compatible database. XAMPP's **MySQL** service can run MariaDB. Use an XAMPP release with PHP 8.1 or newer and the `pdo_mysql` and `mbstring` extensions enabled.

## Install a fresh local demo

1. Extract the ZIP and copy the `student-manager` folder into XAMPP's `htdocs` directory. On Windows, the resulting entry point is `C:\xampp\htdocs\student-manager\index.php`.
2. Start **Apache** and **MySQL** in the XAMPP Control Panel.
3. Open [phpMyAdmin](http://localhost/phpmyadmin/) as a database administrator. From the server home page, open **Import**, select `database/xampp-demo.sql` inside the project, and click **Import**. This creates the `sims` database, sample records, and a dedicated database account. Run this import once on a fresh installation.
4. Open [Student Manager](http://localhost/student-manager/) and sign in with a demo account. The shared demo password is `CampusDemo!2026`.

| Role | Email |
| --- | --- |
| Administrator | admin@campus.test |
| Teacher | teacher@campus.test |
| Student | student@campus.test |
| Parent | parent@campus.test |

## Use an existing database

If you already have a working `sims` database, keep it and skip the demo import. If the app database account is missing, run the four account and grant statements at the bottom of `database/xampp-demo.sql` in phpMyAdmin. Your existing tables and records stay in place.

The default connection is to `127.0.0.1:3306` as the local `sims` database user. If your MySQL settings differ, set `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, or `DB_PASSWORD` using Apache's `SetEnv` directive in the project's `.htaccess` file. Add Apache's port to the browser URLs if it differs from port 80.

```apache
SetEnv DB_PORT 3307
```

For a blank installation, import `database/schema.sql` and provision a database account. Create the first administrator from a terminal in the project folder.

```bat
C:\xampp\php\php.exe bin\create-admin.php "School Administrator" admin@school.example
```

The command prompts for a password. If you configured custom database credentials, set the equivalent environment variables in your terminal before running it.
