SCHOOL API开发规范
==========


开发工具 & 环境
-------------
* IDE: PhpStorm  /VSCode
* 环境搭建：[mac 环境包]

严格遵守PSR规范
-------------
[PSR](https://www.php-fig.org/psr/)
[PSR中文版本](https://psr.phphub.org/)

所有研发人员，必须通读PSR规范。
提交时使用PHPStorm来对PHP代码格式化。

基本代码规范
-------------
* 变量命名使用下划线分隔式 
```php
$user_id
```
* 类的属性命名小写开头的驼峰式 ($camelCase) 
* 类的方法命名小写开头的驼峰式 ($camelCase) 
* 方法参数命名使用下划线分隔式 ($user_id) 
* 关键字使用顺序
```php
    fina public static function sendUserEmail($userId)
```


接口规范
-------------
* 接口命名使用资源描述方式 。 demo: api/activity/goods/add  wrong: api/activity/goodsAdd
* 接口参数使用下划线“\_“ demo: api/v1/activityGoodsList?user\_id=23123&activity\_id=22222

响应规范
-------------
* api接口默认返回json格式数据，应用框架封装方法
* data数据返回必须一致。有数据返回为关联数组，则无数据要返回空对象，有数据返回索引数组，无数据返回空数组

* 关联数组返回

```
{
    "data": {
        "DataList":[
            {"aa": "this is aa.value"},
            {"aa": "this is aa.value"},
            {"aa": "this is aa.value"},
            {"aa": "this is aa.value"},
        ]
    },
    "code": 1,
    "msg": "ok"
}


```


* 返回关联数组结构时，索引不可变

框架层级调用关系
-------------
![Image](https://shops-1254330646.image.myqcloud.com/su/20180517/2018051774242724.png)



```php

    try {
        $userinfo = $this->session->get('user');
        return $this->ajax_return('data error',-1);
        return $this->ajax_return('type error',-1);
        dump($ret);
    } catch (\Exception $e) {
        $this->write_exception_log($e);
        $this->ajax_return($e->getMessage(), -100, []);
    }
```

状态码返回逻辑
-------------
![Image](https://shops-1254330646.image.myqcloud.com/su/20180529/2018052945671365.png)

```
version: '2'
services:
  mynginx:
    container_name: mynginx
    image: nginx:latest
    restart: always
    ports:
      - "80:80"
    volumes:
      - ../../:/mnt/www/
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./data/nginx:/var/log/nginx/
    #links:
    #  - myphp:myphp
    #外部链接容器方法，用于连接手动创建、别的compose创建
    #mem_limit: 200m
    networks: 
     - code-network
  myphp:
    container_name: myphp
    image: flashexpress/php
    #build:
    #   context: .
    #   dockerfile: Dockerfile-flash
    restart: always
    volumes:
      - ../../:/mnt/www/
    networks:
      - code-network
networks:
  code-network:
    driver: bridge
```

项目部署步骤
-------------

```bash
#克隆并检出代码
git clone && git checkout trunk/training/master

#安装依赖包

composer config -g repo.packagist composer https://mirrors.aliyun.com/composer

#安装指定版本
1 composer require mpdf/mpdf ^7.1
2 #提交 composer.json composer.lock文件
  #上线安装扩展
3 composer install && composer dumpautoload

#修改目录权限
chmod -R 777 cache && chmod -R 777 app/runtime

#生成翻译文件
php bin/cli translation gen
```