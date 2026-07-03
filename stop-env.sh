#!/bin/bash
# ==========================================
# mall 项目 — 停止隔离环境
# 使用方法: bash stop-env.sh
# ==========================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "🛑 正在停止 mall 基础设施服务..."
docker compose -f docker-compose-isolated.yml down

echo ""
echo "=========================================="
echo "  ✅ 所有服务已停止"
echo "=========================================="
echo ""
echo "  数据保留在 .docker-data/ 目录中"
echo "  如需彻底清理（删除所有数据）："
echo "    docker compose -f docker-compose-isolated.yml down -v"
echo "    rm -rf .docker-data/"
