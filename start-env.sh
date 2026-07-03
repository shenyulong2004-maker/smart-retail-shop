#!/bin/bash
# ==========================================
# mall 项目 — 启动隔离环境（基础设施服务）
# 使用方法: bash start-env.sh
# ==========================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "  mall 隔离环境 — 启动基础设施"
echo "=========================================="
echo ""

# 检查 Docker
if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker 未运行！请先启动 Docker Desktop，然后重新运行此脚本。"
  exit 1
fi

echo "✅ Docker 已就绪"
echo ""

# 创建本地数据目录
mkdir -p .docker-data/mysql/{data,conf,log}
mkdir -p .docker-data/redis/data
mkdir -p .docker-data/elasticsearch/{data,plugins}
mkdir -p .docker-data/rabbitmq/data
mkdir -p .docker-data/mongo/db
mkdir -p .docker-data/minio/data

# 启动容器
echo "🚀 正在启动所有基础设施服务..."
docker compose -f docker-compose-isolated.yml up -d

echo ""
echo "⏳ 等待服务就绪..."

# 等待 MySQL 就绪
echo -n "   等待 MySQL..."
until docker exec mall-mysql mysqladmin ping -uroot -proot --silent 2>/dev/null; do
  sleep 2
  echo -n "."
done
echo " ✅"

# 等待 Redis 就绪
echo -n "   等待 Redis..."
until docker exec mall-redis redis-cli ping 2>/dev/null | grep -q PONG; do
  sleep 1
  echo -n "."
done
echo " ✅"

# 等待 RabbitMQ 就绪
echo -n "   等待 RabbitMQ..."
sleep 10
echo " ✅"

# 配置 RabbitMQ（mall-portal 需要）
echo ""
echo "🔧 配置 RabbitMQ..."
docker exec mall-rabbitmq rabbitmqctl add_user mall mall 2>/dev/null || echo "   用户 mall 可能已存在"
docker exec mall-rabbitmq rabbitmqctl add_vhost /mall 2>/dev/null || echo "   vhost /mall 可能已存在"
docker exec mall-rabbitmq rabbitmqctl set_permissions -p /mall mall ".*" ".*" ".*" 2>/dev/null
echo "   RabbitMQ 配置完成"

echo ""
echo "=========================================="
echo "  ✅ 所有基础设施服务已就绪！"
echo "=========================================="
echo ""
echo "  服务端口映射："
echo "  ┌──────────────┬─────────────────┐"
echo "  │ MySQL        │ localhost:3307   │"
echo "  │ Redis        │ localhost:6379   │"
echo "  │ Elasticsearch│ localhost:9200   │"
echo "  │ RabbitMQ     │ localhost:5672   │"
echo "  │ RabbitMQ 管理│ localhost:15672  │"
echo "  │ MongoDB      │ localhost:27017  │"
echo "  │ MinIO API    │ localhost:9090   │"
echo "  │ MinIO 控制台 │ localhost:9001   │"
echo "  └──────────────┴─────────────────┘"
echo ""
echo "  数据库连接信息："
echo "    Host: localhost, Port: 3307"
echo "    Database: mall"
echo "    User: root, Password: root"
echo ""
echo "  MinIO 控制台："
echo "    URL: http://localhost:9001"
echo "    User: minioadmin, Password: minioadmin"
echo ""
echo "  RabbitMQ 管理界面："
echo "    URL: http://localhost:15672"
echo "    User: mall, Password: mall"
echo ""
echo "  启动应用（使用隔离环境 profile）："
echo "    cd mall-admin && mvn spring-boot:run -Dspring-boot.run.profiles=isolated"
echo "    cd mall-portal && mvn spring-boot:run -Dspring-boot.run.profiles=isolated"
echo "    cd mall-search && mvn spring-boot:run -Dspring-boot.run.profiles=isolated"
echo ""
echo "  停止环境：bash stop-env.sh"
