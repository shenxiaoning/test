#!/usr/bin/env php
<?php
use Phalcon\Cli\Console;

define('BASE_PATH', dirname(__DIR__));
define('APP_PATH', BASE_PATH . '/app');

//为了引入env函数
require BASE_PATH.'/vendor/autoload.php';


/**
 * 加载环境变量
 */
$dotenv = new Dotenv\Dotenv(BASE_PATH);
$dotenv->load();

/**
 * The FactoryDefault Dependency Injector automatically registers the services that
 * provide a full stack framework. These default services can be overidden with custom ones.
 */

/**
 * Include Services
 */
include APP_PATH . '/config/services_cli.php';


// 设置运行环境变量
$runtime = env('runtime', 'dev');

define('RUNTIME', $runtime);

//设置报错级别
if (RUNTIME == 'pro') {
    error_reporting(E_ERROR | E_WARNING | E_PARSE);
    ini_set('display_errors','off');
} else {
    error_reporting(E_ALL);
    ini_set('display_errors','on');
}

/**
 * Get config service for use in inline setup below
 */
$config = $di->get("config");

/**
 * Include Autoloader
 */
include APP_PATH . '/config/loader.php';


try {
    /**
     * Create a console application
     */

    $console = new Console($di);
    /**
     * 处理console应用参数
     */
    $arguments = [];
    $arguments['config'] = $config;
    foreach ($argv as $k => $arg) {
        if ($k === 1) {
            $arguments["task"] = $arg;
        } elseif ($k === 2) {
            $arguments["action"] = $arg;
        } elseif ($k >= 3) {
            $arguments["params"][] = $arg;
        }
    }
    /**
     * 默认现实command列表
     */
    if(count($argv) == 1){
        $arguments["task"] = 'main';
        $arguments["action"] = 'main';
    }

    /**
     * Handle
     */
    $console->handle($arguments);

    /**
     * If configs is set to true, then we print a new line at the end of each execution
     *
     * If we dont print a new line,
     * then the next command prompt will be placed directly on the left of the output
     * and it is less readable.
     *
     * You can disable this behaviour if the output of your application needs to don't have a new line at end
     */
    if (isset($config["printNewLine"]) && $config["printNewLine"]) {
        echo PHP_EOL;
    }

} catch (Exception $e) {
    echo $e->getMessage() . PHP_EOL;
    echo $e->getTraceAsString() . PHP_EOL;

    $exceptionLogger = $di->get('logger');
    $log = [
        'msg' => $e->getMessage(),
        'file'  => $e->getFile(),
        'line'  => $e->getLine(),
        'trace' => $e->getTraceAsString(),
    ];

    $exceptionLogger->error(json_encode($log, JSON_UNESCAPED_UNICODE));
    exit(255);
}

