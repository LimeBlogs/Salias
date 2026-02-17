#!/bin/bash

# 1. 定义选项列表 (使用换行符 \n 分隔)
# 建议格式： "ID) 描述文本" 这样方便后续提取 ID
shopt -s expand_aliases
CONFIG_FILE="$HOME/.bashrc"
S_ALIAS="alias salias='cd $HOME/Salias/ && ./main.sh'"
GCLI_ALIAS="alias gcli='python3 $HOME/Salias/gcli2api/web.py'"

if [ ! -d "$HOME/Salias/" ]; then
    cd $HOME
    mkdir Salias
fi

clear

if [ -f "$HOME/Salias/main.sh" ]; then
    echo "Welcome 2 Salias"
      if grep -q "alias salias='cd $HOME/Salias/ && ./main.sh" $HOME/.bashrc; then
        echo "别名存在于bashrc"
        echo "输入关键词查找选项 回车键确认选项 方向键选择选项"
        echo ""
      else
        echo "已添加别名至bashrc"
        echo "输入关键词查找选项 回车键确认选项 方向键选择选项"
        echo ""
        echo "$S_ALIAS" >> "$CONFIG_FILE"
      fi
    else
    cp $HOME/Install.sh $HOME/Salias/main.sh
    bash $HOME/Salias/main.sh
fi

MENU="1) 搭建SillyTavern(全新部署)
2) 搭建GCLI2API(全新部署)
3) 更新SillyTavern
4) 更新GCLI2API
5) 清除一切
6) 卸载SillyTavern
7) 卸载GCLI2API
8) 编辑SillyTavern配置文件
9) 设置Git代理端口为7890
10) 简易插件目录管理器
11) 清除SillyTavern第三方插件目录
"

# 2. 调用 fzf
# --height 40%: 占用屏幕 40% 高度 (像个弹窗)
# --layout reverse: 列表从上往下排
# --border: 显示边框
# --prompt: 提示符
SELECTED=$(echo -e "$MENU" | fzf --height 40% --layout=reverse --border --prompt="SALIAS > ")

# 3. 如果用户按 ESC 取消，变量为空，直接退出
if [ -z "$SELECTED" ]; then
    echo "未选择，退出。"
    exit 0
fi

# 4. 提取选项的第一个字符 (数字 ID)
# 这里的 awk '{print $1}' 会打印 "1)"， cut -d')' -f1 去掉括号拿到 "1"
ID=$(echo "$SELECTED" | awk '{print $1}' | cut -d')' -f1)

# 5. 根据 ID 执行逻辑
case $ID in
    1)
        # 不用动—————————————————————————————
        echo "正在换源"
        sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.aliyun.com/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
        echo "已换源"
        echo "更新本地apt索引与本地软件包"
        apt update -y
        apt-get -y upgrade
        apt update -y
        echo "基础项配置完毕"
        apt install vim git nodejs -y
        # 不用动—————————————————————————————
        rm -rf $HOME/Salias/SillyTavern
        cd $HOME/Salias
        echo "拉取ST源码"
        git clone https://github.com/SillyTavern/SillyTavern.git
        echo "拉取完毕"
        npm config set registry https://registry.npmmirror.com
        cd $HOME/Salias/SillyTavern
        echo "安装nodejs依赖"
        npm install
        cd $HOME
        echo "写入别名"
        ST_ALIAS="alias 9g='cd $HOME/Salias/SillyTavern && ./start.sh'"
        echo "$ST_ALIAS" >> "$CONFIG_FILE"
        echo "请重启终端"
        echo "你现在可以通过9g来快速启动酒馆"
        echo "此外，也可以通过salias来快速启动管理面板"
        cd $HOME
        ;;
    2)
        echo "安装Python"
        apt update -y
        apt install python -y
        pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
        echo "拉取源码"
        cd $HOME
        rm -rf $HOME/Salias/gcli2api
        cd $HOME/Salias/
        git clone https://github.com/su-kaka/gcli2api.git
        cd $HOME/Salias/gcli2api
        echo "安装Python依赖"
        pip install -r requirements-termux.txt
        echo "$GCLI_ALIAS" >> "$CONFIG_FILE"
        echo "请重启Termux"
        echo "你现在可以通过gcli来快速启动GCLI2API"
        cd $HOME
        ;;
    3)
        # 检测流
        if [ ! -d "$HOME/Salias/SillyTavern" ]; then
          echo "你可能未安装SillyTavern"
          bash $HOME/Salias/main.sh
        else
          cd $HOME/Salias/SillyTavern/
          git pull
          echo "更新完毕"
        fi
        cd $HOME
        ;;
    4)
        if [ ! -d "$HOME/Salias/gcli2api" ]; then
          echo "你可能未安装gcli2api"
          bash $HOME/Salias/main.sh
        else
          cd $HOME/Salias/gcli2api/
          git pull
          echo "更新完毕"
        fi
        cd $HOME
        ;;
    5)
        rm -rf $HOME/Salias
        echo "已清除所有项目，但是所安装过的软件包不会去除！"
        cd $HOME
        ;;
    6)
        rm -rf $HOME/Salias/SillyTavern
        echo "已删除酒馆及其数据"
        cd $HOME
        ;;
    7)
        rm -rf $HOME/Salias/gcli2api
        echo "已删除gcli2api及其数据"
        cd $HOME
        ;;
    8)
        vim $HOME/Salias/SillyTavern/config.yaml
        cd $HOME
        ;;
    9)
        git config --global http.proxy http://127.0.0.1:7890
        git config --global https.proxy http://127.0.0.1:7890
        echo "已设置代理为127.0.0.1:7890"
        cd $HOME
        ;;
    10)
        BASE_DIR="$HOME/Salias/SillyTavern/public/scripts/extensions/third-party/"
        cd "$BASE_DIR" || exit
        SELECTED_DIR=$(find . -maxdepth 1 -mindepth 1 -type d | sed 's|^\./||' | fzf \
            --prompt="请选择要删除的目录 > " \
            --height=40% \
            --layout=reverse \
            --border \
            --preview "ls -A --color=always {}")
        if [ -z "$SELECTED_DIR" ]; then
            echo "已取消选择。"
     .       exit 0
        fi
        ACTION=$(echo -e "🚫 取消 (Cancel)\n🗑️ 确认删除 (Delete '$SELECTED_DIR')" | fzf \
            --prompt="⚠️ 危险操作确认 > " \
            --height=20% \
            --layout=reverse \
            --border \
            --header="确定要永久删除 '$SELECTED_DIR' 吗？")
        if [[ "$ACTION" == *"确认删除"* ]]; then
            # 再次构建完整路径以确保安全
            FULL_PATH="$BASE_DIR/$SELECTED_DIR"
            if [ -d "$FULL_PATH" ] && [ "$FULL_PATH" != "$HOME" ] && [ "$FULL_PATH" != "/" ]; then
                rm -rf "$FULL_PATH"
                echo "✅ 已删除: $FULL_PATH"
            else
                echo "❌ 错误: 路径无效或受保护，未执行删除。"
            fi
        else
            echo "操作已取消。"
        fi
        ;;
    11)
        rm -rf $HOME/Salias/SillyTavern/public/scripts/extensions/third-party/*
        echo "已清除所有插件"
    *)
        echo "未知选项"
        ;;
esac