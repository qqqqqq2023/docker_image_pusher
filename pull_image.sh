#!/bin/bash

# 脚本名称: pull_image.sh
# 功能: 封装Git操作，处理镜像更新流程
# 使用方法: sh pull_image.sh [镜像名称]
# 默认架构: sh pull_images.sh python:3.9-alpine
# 指定架构: sh pull_image.sh "--platform linux/arm64 python:3.9-alpine"

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印彩色信息函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查参数
if [ $# -eq 0 ]; then
    print_error "请指定镜像名称！"
    echo "使用方法: $0 [镜像名称]"
    echo "示例(默认架构): sh $0 nginx"
    echo "示例(指定架构): sh $0 \"--platform linux/arm64 nginx\""
    exit 1
fi

IMAGE_NAME=$1
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
TIMESTAMP=$(date '+%Y-%m-%d')

# 检查必要文件是否存在
check_files() {
    if [ ! -f "images.txt" ]; then
        print_warning "images.txt 文件不存在，正在创建..."
        touch images.txt
    fi
    
    if [ ! -f "result.txt" ]; then
        print_warning "result.txt 文件不存在，正在创建..."
        touch result.txt
    fi
    
    if [ ! -f "data.txt" ]; then
        print_warning "data.txt 文件不存在，正在创建..."
        touch data.txt
    fi
}


# 清空当前文件
clear_files() {
    print_info "正在清空当前 images.txt & result.txt 文件..."
    > images.txt
    > result.txt
    print_success " images.txt & result.txt 文件已清空"
}

# 写入新的镜像信息
write_image_info() {
    print_info "正在写入新的镜像信息 $IMAGE_NAME ..."
    # 第一行写入注释：yyyy-MM-dd 的时间 + 镜像名称
    echo "# $TIMESTAMP $IMAGE_NAME" > images.txt
    echo "$IMAGE_NAME" >> images.txt
    print_success "镜像信息 $IMAGE_NAME 已写入 images.txt"
}

# Git操作
git_operations() {
    print_info "开始Git操作..."
    
    # 添加文件到暂存区
    git add .
    if [ $? -ne 0 ]; then
        print_error "Git add 操作失败"
        exit 1
    fi
    
    # 提交更改
    COMMIT_MSG="Update: $IMAGE_NAME image at $CURRENT_DATE"
    git commit -m "$COMMIT_MSG"
    if [ $? -ne 0 ]; then
        print_error "Git commit 操作失败"
        exit 1
    fi
    
    # 推送到远程仓库
    print_info "正在推送到远程仓库..."
    git push origin main
    if [ $? -ne 0 ]; then
        print_error "Git push 操作失败"
        exit 1
    fi

    sleep 20
    
    print_success "Git操作完成，已推送到远程仓库"
}

# 等待GitHub Action完成
wait_for_action_completion() {
    print_info "等待GitHub Action执行..."
    print_warning "这可能需要几分钟时间，请耐心等待..."
    print_warning "您可以前往GitHub仓库的Actions页面查看执行进度"
    
    local max_attempts=12  # 增加尝试次数（12 * 20秒 = 4分钟）
    local attempt=1
    local wait_seconds=20
    local action_completed=false
    
    while [ $attempt -le $max_attempts ]; do
        print_info "第 $attempt 次检查... (已等待 $(( (attempt-1) * wait_seconds )) 秒)"
        print_info "正在拉取最新代码以获取GitHub Action执行结果..."
        
        # 拉取最新更改
        git pull origin main --quiet 2>/dev/null
        
        # 检查result.txt是否有内容（GitHub Action写入的结果）
        if [ -f "result.txt" ] && [ -s "result.txt" ]; then
            print_success "✅ GitHub Action 执行完成！"
            action_completed=true
            break
        fi
        
        print_warning "GitHub Action 仍在执行中，等待 ${wait_seconds} 秒后再次检查..."
        echo "----------------------------------------"
        sleep $wait_seconds
        ((attempt++))
    done
    
    if [ "$action_completed" = false ]; then
        print_error "❌ 等待超时，GitHub Action 可能执行失败"
        print_warning "建议："
        print_warning "1. 请前往GitHub仓库的Actions页面查看执行状态"
        print_warning "2. 检查网络连接是否正常"
        print_warning "3. 稍后手动执行 git pull 查看结果"
        return 1
    fi
    
    return 0
}

# 显示最终结果
show_result() {
    print_info "=== 最终结果 ==="
    if [ -f "result.txt" ] && [ -s "result.txt" ]; then
        echo "📋 result.txt 内容:"
        echo "----------------------------------------"
        cat result.txt
        echo "----------------------------------------"
        print_success "🎉 操作完成！镜像已成功处理。"
    else
        print_warning "⚠️  result.txt 为空或不存在"
    fi
}

# 主函数
main() {
    print_info "🚀 开始处理镜像: $IMAGE_NAME"
    print_info "📅 当前时间: $CURRENT_DATE"
    echo "========================================"
    
    # 检查Git仓库状态
    if [ ! -d ".git" ]; then
        print_error "❌ 当前目录不是Git仓库！"
        exit 1
    fi
    
    # 执行各个步骤
    check_files
    clear_files
    write_image_info
    git_operations
    
    # 等待GitHub Action完成
    if wait_for_action_completion; then
        echo "========================================"
        print_success "✅ GitHub Action 已成功完成"
        show_result
    else
        echo "========================================"
        print_error "❌ GitHub Action 未完成，无法获取结果"
        print_warning "⚠️  跳过 show_result 步骤"
    fi
    
    print_info "📊 脚本执行完成"
}

# 异常处理
trap 'print_error "脚本执行被中断"; exit 1' INT TERM

# 执行主函数
main "$@"