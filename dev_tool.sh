#!/bin/bash

function echo_log(){
   echo -e "\033[0;31m $1 \033[0m"
}
function echo_blue {
   echo -e "\033[47;34m $1 \033[0m"
}



#运行生成语言包文件
function build_translation {
    #php bin/cli translation gen
    php app/cli.php translation main
}


function count_code {
  # 开发者列表
  developers=("huhelong" "wangtongfang" "shenxn" "luyao" "liuchunhua" "gjf" "wangyutao" "wangdongbing" "yujiaxing")

  # 获取日期范围
  echo ""
  echo_blue "════════════════════════════════════════════════════════════════"
  echo_blue "                    代码统计工具                                "
  echo_blue "════════════════════════════════════════════════════════════════"
  echo ""
  read -p "请输入开始日期 (格式: YYYY-MM-DD，默认: 30天前): " start_date
  read -p "请输入结束日期 (格式: YYYY-MM-DD，默认: 今天): " end_date

  # 设置默认日期
  if [ -z "$start_date" ]; then
    start_date=$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d "30 days ago" +%Y-%m-%d)
  fi

  if [ -z "$end_date" ]; then
    end_date=$(date +%Y-%m-%d)
  fi

  echo ""
  echo_blue "📅 统计时间范围: ${start_date} 至 ${end_date}"
  echo ""

  # 打印美化的表格
  echo -e "\033[1;36m╔════════════════════╦═══════════╦═══════════╦═══════════╦═══════════╦═══════════╦═══════════╗\033[0m"
  echo -e "\033[1;36m║\033[0m \033[1;33m开发者            \033[0m \033[1;36m║\033[0m \033[1;33m提交次数 \033[0m \033[1;36m║\033[0m \033[1;33m增加行数 \033[0m \033[1;36m║\033[0m \033[1;33m删除行数 \033[0m \033[1;36m║\033[0m \033[1;33m净增行数 \033[0m \033[1;36m║\033[0m \033[1;33m修改文件 \033[0m \033[1;36m║\033[0m \033[1;33m总变化   \033[0m \033[1;36m║\033[0m"
  echo -e "\033[1;36m╠════════════════════╬═══════════╬═══════════╬═══════════╬═══════════╬═══════════╬═══════════╣\033[0m"

  # 用于统计总计
  total_commits=0
  total_added=0
  total_deleted=0
  total_net=0
  total_files=0
  total_changes=0
  active_devs=0

  # 统计每个开发者的代码量
  for dev in "${developers[@]}"; do
    # 获取提交次数
    commit_count=$(git log --author="$dev" --since="$start_date" --until="$end_date" --oneline 2>/dev/null | wc -l | tr -d ' ')

    # 如果没有提交记录，跳过
    if [ "$commit_count" -eq 0 ]; then
      continue
    fi

    # 获取代码统计信息
    stats=$(git log --author="$dev" --since="$start_date" --until="$end_date" --pretty=tformat: --numstat 2>/dev/null | \
      awk '{
        add += $1;
        subs += $2;
        files += ($1 != "" && $2 != "") ? 1 : 0
      } END {
        printf "%d %d %d %d %d", add, subs, add - subs, files, add + subs
      }')

    # 解析统计数据
    read added deleted net_change file_count total_change <<< "$stats"

    # 累加总计
    total_commits=$((total_commits + commit_count))
    total_added=$((total_added + added))
    total_deleted=$((total_deleted + deleted))
    total_net=$((total_net + net_change))
    total_files=$((total_files + file_count))
    total_changes=$((total_changes + total_change))
    active_devs=$((active_devs + 1))

    # 输出统计结果（带颜色）
    printf "\033[1;36m║\033[0m \033[1;32m%-18s\033[0m \033[1;36m║\033[0m \033[0;37m%9s\033[0m \033[1;36m║\033[0m \033[0;32m%9s\033[0m \033[1;36m║\033[0m \033[0;31m%9s\033[0m \033[1;36m║\033[0m \033[0;34m%9s\033[0m \033[1;36m║\033[0m \033[0;35m%9s\033[0m \033[1;36m║\033[0m \033[0;33m%9s\033[0m \033[1;36m║\033[0m\n" \
      "$dev" \
      "$commit_count" \
      "$added" \
      "$deleted" \
      "$net_change" \
      "$file_count" \
      "$total_change"
  done

  # 打印分隔线和总计
  echo -e "\033[1;36m╠════════════════════╬═══════════╬═══════════╬═══════════╬═══════════╬═══════════╬═══════════╣\033[0m"
  printf "\033[1;36m║\033[0m \033[1;35m%-18s\033[0m \033[1;36m║\033[0m \033[1;37m%9s\033[0m \033[1;36m║\033[0m \033[1;32m%9s\033[0m \033[1;36m║\033[0m \033[1;31m%9s\033[0m \033[1;36m║\033[0m \033[1;34m%9s\033[0m \033[1;36m║\033[0m \033[1;35m%9s\033[0m \033[1;36m║\033[0m \033[1;33m%9s\033[0m \033[1;36m║\033[0m\n" \
    "总计 (${active_devs}人)" \
    "$total_commits" \
    "$total_added" \
    "$total_deleted" \
    "$total_net" \
    "$total_files" \
    "$total_changes"
  echo -e "\033[1;36m╚════════════════════╩═══════════╩═══════════╩═══════════╩═══════════╩═══════════╩═══════════╝\033[0m"

  echo ""
  echo_blue "✅ 统计完成！"
  echo ""

  # 显示统计摘要
  echo_log "📊 统计摘要:"
  echo -e "  • 活跃开发者: \033[1;32m${active_devs}\033[0m 人"
  echo -e "  • 总提交次数: \033[1;33m${total_commits}\033[0m 次"
  echo -e "  • 代码净增量: \033[1;34m${total_net}\033[0m 行"
  echo -e "  • 平均每人提交: \033[1;35m$((total_commits / active_devs))\033[0m 次"
  if [ $active_devs -gt 0 ]; then
    echo -e "  • 平均每人净增: \033[1;36m$((total_net / active_devs))\033[0m 行"
  fi
  echo ""

  # 询问是否查看详细信息
  read -p "是否查看某个开发者的详细提交记录？(y/n): " show_detail
  if [ "$show_detail" = "y" ] || [ "$show_detail" = "Y" ]; then
    read -p "请输入开发者名称: " dev_name
    echo ""
    echo_blue "════════════════════════════════════════════════════════════════"
    echo_blue "  开发者 ${dev_name} 的详细提交记录"
    echo_blue "════════════════════════════════════════════════════════════════"
    echo ""
    git log --author="$dev_name" --since="$start_date" --until="$end_date" --pretty=format:"%C(yellow)%h%Creset - %C(cyan)%an%Creset, %C(green)%ar%Creset : %s" --stat
    echo ""
  fi
}


echo_log "请选择 1更新语言包 2统计代码 :"
read -p "请输入: " number

case $number in
    1)
       echo_blue "语言包开始更新"
       build_translation
       echo_blue "语言包更新完毕"
    ;;
    2)
       echo_log "统计代码开始"
       count_code
       echo_log "统计代码结束"
    ;;
    *)
         echo_log "输入错误"
      ;;
esac