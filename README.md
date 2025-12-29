# Docker Images Pusher

> 更新README，添加修改后的说明    
## 项目结构

```
text
├── .github/workflows/docker.yaml   # GitHub Action 工作流文件
├── doc/                            # 图片说明 
├── data.txt                        # 镜像脚本数据源
├── images.txt                      # 镜像列表（GitHub Action 使用）
├── index.html                      # 主页面文件
├── LICENSE                         # 许可证
├── pull_image.sh                   # 镜像拉取脚本
├── README.md                       # 项目说明文档
└── result.txt                      # Github Action 结果展示
```

## 使用方法

### 1. Fork 项目并配置参数
- 点击项目页面右上角的 **Fork** 按钮，将此项目复制到您的 GitHub 账户下
- 参考原项目的 README 文档，在您 Fork 后的仓库中配置阿里云相关参数（如访问密钥、镜像仓库地址等）

### 2. 克隆项目到本地
```bash
git clone https://github.com/qqqqqq2023/docker_image_pusher.git
cd docker_image_pusher
```

### 3. 执行镜像拉取脚本
```bash
# 运行脚本并指定要拉取的镜像名称
sh pull_image.sh <image_name>

# 示例：拉取 nginx 镜像
sh pull_image.sh nginx:latest

# 示例：拉取 python:3.9-alpin 镜像
# 默认架构: sh pull_images.sh python:3.9-alpine
# 指定架构: sh pull_image.sh "--platform linux/arm64 python:3.9-alpine"
```

### 4. 查看执行结果
- 脚本会自动触发 GitHub Action 工作流，执行镜像拉取和推送操作
- 执行结果将被写入到指定文件中，同时显示镜像拉取命令

### 5. 结果展示
- 若执行成功，GitHub Pages 页面将自动渲染最新的镜像信息
- 您可以访问 [镜像查询页面](https://qqqqqq2023.github.io/docker_image_pusher/) 查看

### 注意事项
- 确保在执行脚本前已正确配置所有必要的环境变量和密钥
- 首次使用 GitHub Pages 可能需要手动在仓库设置中启用
- 镜像名称需要包含 tag（如 `nginx:latest`），否则将使用默认 tag


## GitHub Pages

### 1. 访问页面
[镜像查询页面](https://qqqqqq2023.github.io/docker_image_pusher/)

### 2. 查看镜像
- 页面按镜像名称分组显示所有可用的迁移脚本
- 每个镜像组显示镜像名称和最新版本的脚本
- 点击脚本区域直接复制完整命令到剪贴板

### 3. 切换版本
如果一个镜像有多个版本：
- 使用版本选择下拉菜单切换不同版本
- 下拉菜单显示完整镜像名称和创建日期
- 切换后脚本区域自动更新

### 4. 搜索镜像
- 在搜索框输入镜像名称或脚本内容进行搜索
- 支持实时搜索，输入时自动过滤结果


## GitHub Action 工作流

### 主要功能
1. **自动拉取镜像**：根据 `images.txt` 文件中的镜像列表拉取 Docker 镜像
2. **推送到阿里云**：将拉取的镜像推送到阿里云容器镜像服务
3. **生成迁移脚本**：自动生成用于从阿里云拉取镜像的脚本
4. **更新网页数据**：将生成的脚本保存到 `data.txt`，触发页面更新

### 注意事项
- **重要**：调整运行逻辑时，需要清空 `images.txt` 文件，避免 GitHub Action 执行时导致 Git 冲突
- 每次执行都会在 `data.txt` 中追加新的脚本，不会覆盖已有数据
- 页面会自动解析最新的 `data.txt` 文件并展示所有镜像脚本

## 数据来源

数据来源于 `data.txt` 文件，该文件由 GitHub Action 自动生成，包含以下格式的数据块：

```
DATE: 2025-12-29 23:19:12
==============================================================================
IMAGE: cm2network/steamcmd
==============================================================================
SCRIPT: docker pull crpi-m03vbpitsoz3o2xx.cn-guangzhou.personal.cr.aliyuncs.com/q_docker_images/steamcmd
docker tag crpi-m03vbpitsoz3o2xx.cn-guangzhou.personal.cr.aliyuncs.com/q_docker_images/steamcmd steamcmd
docker rmi crpi-m03vbpitsoz3o2xx.cn-guangzhou.personal.cr.aliyuncs.com/q_docker_images/steamcmd

==============================================================================
```

## 更新日志

### 2025-12-29
- **调整 docker.yaml 逻辑**：优化拉取镜像命令输出
- **调整 pull_image.sh 脚本逻辑**：改进镜像拉取和处理流程
- **实现 GitHub Pages 展示页面**：创建网页界面，点击即复制到剪贴板

### 2025-10-22
- 添加 `pull_image.sh` 脚本，用于处理镜像拉取和结果展示

### 2025-07-21
- `docker.yaml` 在原基础上增加了拉取命令的输出功能



---
> 原README


使用Github Action将国外的Docker镜像转存到阿里云私有仓库，供国内服务器使用，免费易用<br>
- 支持DockerHub, gcr.io, k8s.io, ghcr.io等任意仓库<br>
- 支持最大40GB的大型镜像<br>
- 使用阿里云的官方线路，速度快<br>

视频教程：https://www.bilibili.com/video/BV1Zn4y19743/

作者：**[技术爬爬虾](https://github.com/tech-shrimp/me)**<br>
B站，抖音，Youtube全网同名，转载请注明作者<br>

## 使用方式


### 配置阿里云
登录阿里云容器镜像服务<br>
https://cr.console.aliyun.com/<br>
启用个人实例，创建一个命名空间（**ALIYUN_NAME_SPACE**）
![](/doc/命名空间.png)

访问凭证–>获取环境变量<br>
用户名（**ALIYUN_REGISTRY_USER**)<br>
密码（**ALIYUN_REGISTRY_PASSWORD**)<br>
仓库地址（**ALIYUN_REGISTRY**）<br>

![](/doc/用户名密码.png)


### Fork本项目
Fork本项目<br>
#### 启动Action
进入您自己的项目，点击Action，启用Github Action功能<br>
#### 配置环境变量
进入Settings->Secret and variables->Actions->New Repository secret
![](doc/配置环境变量.png)
将上一步的**四个值**<br>
ALIYUN_NAME_SPACE,ALIYUN_REGISTRY_USER，ALIYUN_REGISTRY_PASSWORD，ALIYUN_REGISTRY<br>
配置成环境变量

### 添加镜像
打开images.txt文件，添加你想要的镜像 
可以加tag，也可以不用(默认latest)<br>
可添加 --platform=xxxxx 的参数指定镜像架构<br>
可使用 k8s.gcr.io/kube-state-metrics/kube-state-metrics 格式指定私库<br>
可使用 #开头作为注释<br>
![](doc/images.png)
文件提交后，自动进入Github Action构建

### 使用镜像
回到阿里云，镜像仓库，点击任意镜像，可查看镜像状态。(可以改成公开，拉取镜像免登录)
![](doc/开始使用.png)

在国内服务器pull镜像, 例如：<br>
```
docker pull registry.cn-hangzhou.aliyuncs.com/shrimp-images/alpine
```
registry.cn-hangzhou.aliyuncs.com 即 ALIYUN_REGISTRY(阿里云仓库地址)<br>
shrimp-images 即 ALIYUN_NAME_SPACE(阿里云命名空间)<br>
alpine 即 阿里云中显示的镜像名<br>

### 多架构
需要在images.txt中用 --platform=xxxxx手动指定镜像架构
指定后的架构会以前缀的形式放在镜像名字前面
![](doc/多架构.png)

### 镜像重名
程序自动判断是否存在名称相同, 但是属于不同命名空间的情况。
如果存在，会把命名空间作为前缀加在镜像名称前。
例如:
```
xhofe/alist
xiaoyaliu/alist
```
![](doc/镜像重名.png)

### 定时执行
修改/.github/workflows/docker.yaml文件
添加 schedule即可定时执行(此处cron使用UTC时区)
![](doc/定时执行.png)
