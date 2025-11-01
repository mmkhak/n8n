#!/bin/bash

# رنگ‌ها برای output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🧪 Testing n8n Docker build...${NC}\n"

# بررسی وجود Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed!${NC}"
    exit 1
fi

# بررسی وجود Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed!${NC}"
    exit 1
fi

# بررسی فایل .env.production
if [ ! -f .env.production ]; then
    echo -e "${YELLOW}⚠️  .env.production not found. Creating from example...${NC}"
    cp .env.production.example .env.production
    echo -e "${YELLOW}⚠️  Please edit .env.production with your settings!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites checked${NC}\n"

# Build image
echo -e "${GREEN}🔨 Building Docker image...${NC}"
docker compose -f docker-compose.production.yml build

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ Build successful!${NC}\n"
else
    echo -e "\n${RED}❌ Build failed!${NC}\n"
    exit 1
fi

# پرسیدن برای اجرا
read -p "Do you want to start the containers? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${GREEN}🚀 Starting containers...${NC}"
    docker compose -f docker-compose.production.yml up -d

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✅ Containers started successfully!${NC}"
        echo -e "${GREEN}📍 n8n is available at: http://localhost:5678${NC}\n"

        # نمایش لاگ‌ها
        echo -e "${YELLOW}📋 Container logs:${NC}"
        docker compose -f docker-compose.production.yml logs -f
    else
        echo -e "\n${RED}❌ Failed to start containers!${NC}\n"
        exit 1
    fi
fi
