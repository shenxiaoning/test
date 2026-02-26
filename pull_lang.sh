#!/bin/bash

function echo_log(){
   echo -e "\033[0;31m $1 \033[0m"
}
function echo_blue {
   echo -e "\033[47;34m $1 \033[0m"
}

#备份代码库
function backup {
  br=`git branch | grep "*"`
  local_branch=${br/* /}
  #建立备份分支名字
  branch_name=bak`date +%Y%m%d%H%M%S`
  #echo_log $branch_name
  #建立备份分支名
  git checkout -b $branch_name
  echo_blue "${local_branch} 备份成功为 ${branch_name}"
  #切换回使用分支
  git checkout $local_branch
  echo_blue "切换到${local_branch}本地完成"
}

#运行生成语言包文件
function build_translation {
    #php bin/cli translation gen
    php app/cli.php translation main
}

echo_log "请选择 1 备份代码 2 升级代码 3 更新语言包 :"
read -p "请输入: " number

case $number in
    1)
       echo_log "你要做的操作是备份代码"
       backup
    ;;
    2)
       echo_log "更新代码中"
       git pull origin
       echo_blue "代码更新完毕"
    ;;
    3)
       echo_blue "语言包开始更新"
       build_translation
       echo_blue "语言包更新完毕"
    ;;
    *)
       echo_log "输入错误"
    ;;
esac