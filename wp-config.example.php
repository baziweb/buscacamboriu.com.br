<?php
/**
 * Configuração do WordPress para Busca Camboriú
 * 
 * IMPORTANTE: Este arquivo é um EXEMPLO e não deve ser commitado no Git.
 * Copie para wp-config.php e configure com suas credenciais reais.
 */

// ** Configurações de MySQL - Você pode obter essas informações do seu provedor de hospedagem ** //
/** Nome do banco de dados */
define( 'DB_NAME', 'your_database_name' );

/** Nome do usuário do MySQL */
define( 'DB_USER', 'your_database_user' );

/** Senha do MySQL */
define( 'DB_PASSWORD', 'your_database_password' );

/** Nome do host MySQL */
define( 'DB_HOST', 'localhost' );

/** Charset para criar as tabelas do banco de dados */
define( 'DB_CHARSET', 'utf8mb4' );

/** Tipo de collation para o banco de dados */
define( 'DB_COLLATE', '' );

/**
 * Chaves únicas de autenticação e salts
 * Gere essas chaves em: https://api.wordpress.org/secret-key/1.1/salt/
 */
define( 'AUTH_KEY',         'coloque sua chave única aqui' );
define( 'SECURE_AUTH_KEY',  'coloque sua chave única aqui' );
define( 'LOGGED_IN_KEY',    'coloque sua chave única aqui' );
define( 'NONCE_KEY',        'coloque sua chave única aqui' );
define( 'AUTH_SALT',        'coloque sua chave única aqui' );
define( 'SECURE_AUTH_SALT', 'coloque sua chave única aqui' );
define( 'LOGGED_IN_SALT',   'coloque sua chave única aqui' );
define( 'NONCE_SALT',       'coloque sua chave única aqui' );

/**
 * Prefixo das tabelas do WordPress
 * Você pode ter múltiplas instalações em um único banco de dados se der
 * um prefixo único para cada uma
 */
$table_prefix = 'wp_';

/**
 * Configurações de ambiente
 */
// Detectar ambiente baseado no hostname ou variável de ambiente
$hostname = $_SERVER['HTTP_HOST'] ?? $_SERVER['SERVER_NAME'] ?? 'localhost';

if (strpos($hostname, 'buscacamboriu.com.br') !== false && strpos($hostname, 'dev.') === false) {
    // PRODUÇÃO
    define('WP_ENV', 'production');
    define('WP_DEBUG', false);
    define('WP_DEBUG_LOG', false);
    define('WP_DEBUG_DISPLAY', false);
    define('SCRIPT_DEBUG', false);
} else {
    // DESENVOLVIMENTO
    define('WP_ENV', 'development');
    define('WP_DEBUG', true);
    define('WP_DEBUG_LOG', true);
    define('WP_DEBUG_DISPLAY', true);
    define('SCRIPT_DEBUG', true);
}

/**
 * Configurações de segurança
 */
// Bloquear edição de arquivos via admin
define('DISALLOW_FILE_EDIT', true);

// SSL/HTTPS
if (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') {
    define('FORCE_SSL_ADMIN', true);
}

/**
 * Configurações de performance
 */
// Cache
define('WP_CACHE', true);

// Compressão GZIP
define('COMPRESS_CSS', true);
define('COMPRESS_SCRIPTS', true);

// Limitar revisões de posts
define('WP_POST_REVISIONS', 3);

// Lixeira automática (30 dias)
define('EMPTY_TRASH_DAYS', 30);

/**
 * Configurações de upload
 */
define('WP_MEMORY_LIMIT', '256M');
define('MAX_EXECUTION_TIME', 300);

/**
 * URLs personalizadas (se necessário)
 */
// define('WP_HOME', 'https://buscacamboriu.com.br');
// define('WP_SITEURL', 'https://buscacamboriu.com.br');

/**
 * Configurações de backup e manutenção
 */
// Definir diretório de backup (fora do document root se possível)
define('BACKUP_DIR', dirname(__FILE__) . '/backups/');

/**
 * Configurações de log personalizado
 */
if (WP_DEBUG) {
    // Log personalizado para deploy
    ini_set('log_errors', 1);
    ini_set('error_log', dirname(__FILE__) . '/wp-content/debug.log');
}

/**
 * Configurações multisite (se necessário no futuro)
 */
// define('WP_ALLOW_MULTISITE', true);

/* Isso é tudo, pare de editar! Boa sorte. */

/** Caminho absoluto para o diretório WordPress. */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/** Configurar as variáveis do WordPress e incluir arquivos. */
require_once( ABSPATH . 'wp-settings.php' );
