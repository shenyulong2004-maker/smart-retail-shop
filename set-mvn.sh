#!/bin/bash
# ==========================================
# mall 项目 — Maven 环境别名
# 在 Git Bash 中执行: source set-mvn.sh
# 之后可直接使用 mvn 命令
# ==========================================
MVN_HOME="/c/Program Files/JetBrains/IntelliJ IDEA 2024.3.6/plugins/maven/lib/maven3"
export PATH="$MVN_HOME/bin:$PATH"
echo "✅ Maven $(mvn --version 2>&1 | head -1 | awk '{print $3}') 已就绪"
