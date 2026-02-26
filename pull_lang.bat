@echo off

choice /C 123 /M "请选择 1 备份代码 2 升级代码 3 更新语言包 :"

if errorlevel 3 goto build_translation

if errorlevel 2 goto update

if errotlevel 1 goto backup

:backup
goto end
  

:update
echo 更新代码中
git pull origin
echo 代码更新完毕
goto end

  

:build_translation
echo 语言包开始更新
php bin/cli translation gen
echo 语言包更新完毕
goto end


:end



