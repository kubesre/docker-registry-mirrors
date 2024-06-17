#!/usr/bin/env bash
#===============================================================================
#
#          FILE: DockerProxy_Install.sh
# 
#         USAGE: ./DockerProxy_Install.sh
#
#   DESCRIPTION: 自建Docker镜像加速服务，基于crproxy项目 一键部署Docker、K8s、ghcr镜像加速\管理服务.
#   GITHUB: https://github.com/kubesre/docker-registry-mirrors
# 
#  ORGANIZATION: 参考项目：https://github.com/dqzboy/Docker-Proxy/
#===============================================================================

echo
cat << EOF

    ██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗     ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
    ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
    ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝    ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝ 
    ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗    ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝  
    ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║    ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║   
    ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   
                                                                                               
EOF

echo "----------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------"
echo
echo

GREEN="\033[0;32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"

INFO="[${GREEN}INFO${RESET}]"
ERROR="[${RED}ERROR${RESET}]"
WARN="[${YELLOW}WARN${RESET}]"
function INFO() {
    echo -e "${INFO} ${1}"
}
function ERROR() {
    echo -e "${ERROR} ${1}"
}
function WARN() {
    echo -e "${WARN} ${1}"
}

# 服务部署和配置持久华存储路径
PROXY_DIR="/data/registry-proxy"
mkdir -p ${PROXY_DIR}
cd "${PROXY_DIR}"

# 项目RAW地址
GITRAW="https://raw.githubusercontent.com/kubesre/docker-registry-mirrors/main/dockerproxy"

# 部署的容器名称和镜像版本
CONTAINER_NAME_LIST=("gateway" "crproxy")
IMAGE_NAME="ghcr.io/wzshiming/nginx-certbot"
CRPROXY_IMAGE_NAME="ghcr.io/wzshiming/crproxy/crproxy"
DOCKER_COMPOSE_FILE="docker-compose.yaml"
# 定义常用仓库别名数组
ALIASES=(
    "l5d cr.l5d.io"
    "elastic docker.elastic.co"
    "docker docker.io"
    "gcr gcr.io"
    "ghcr ghcr.io"
    "k8s-gcr k8s.gcr.io"
    "k8s registry.k8s.io"
    "mcr mcr.microsoft.com"
    "nvcr nvcr.io"
    "quay quay.io"
    "jujucharms registry.jujucharms.com"
    "rocks-canonical rocks.canonical.com"
)
DEFAULT_GATEWAY="crproxy:8080"
# 定义安装重试次数
attempts=0
maxAttempts=3

function CHECK_OS() {
INFO "======================= 检查环境 ======================="
# OS version
OSVER=$(cat /etc/os-release | grep -o '[0-9]' | head -n 1)

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "无法确定发行版"
    exit 1
fi

# 根据发行版选择存储库类型
case "$ID" in
    "centos")
        repo_type="centos"
        ;;
    "debian")
        repo_type="debian"
        ;;
    "rhel")
        repo_type="rhel"
        ;;
    "ubuntu")
        repo_type="ubuntu"
        ;;
    "opencloudos")
        repo_type="centos"
        ;;
    "rocky")
        repo_type="centos"
        ;;
    *)
        WARN "此脚本目前不支持您的系统: $ID"
        exit 1
        ;;
esac

INFO "System release:: $NAME"
INFO "System version: $VERSION"
INFO "System ID: $ID"
INFO "System ID Like: $ID_LIKE"
}

function CHECK_PACKAGE_MANAGER() {
    if command -v dnf &> /dev/null; then
        package_manager="dnf"
    elif command -v yum &> /dev/null; then
        package_manager="yum"
    elif command -v apt-get &> /dev/null; then
        package_manager="apt-get"
    elif command -v apt &> /dev/null; then
        package_manager="apt"
    else
        ERROR "不受支持的软件包管理器."
        exit 1
    fi
}

function CHECK_PKG_MANAGER() {
    if command -v rpm &> /dev/null; then
        pkg_manager="rpm"
    elif command -v dpkg &> /dev/null; then
        pkg_manager="dpkg"
    elif command -v apt &> /dev/null; then
        pkg_manager="apt"
    else
        ERROR "无法确定包管理系统."
        exit 1
    fi
}

function CHECKMEM() {
# 获取内存使用率，并保留两位小数
memory_usage=$(free | awk '/^Mem:/ {printf "%.2f", $3/$2 * 100}')

# 将内存使用率转为整数（去掉小数部分）
memory_usage=${memory_usage%.*}

if [[ $memory_usage -gt 90 ]]; then  # 判断是否超过 90%
    read -e -p "$(WARN '内存占用率高于 70%($memory_usage%). 是否继续安装?: ')" continu
    if [ "$continu" == "n" ] || [ "$continu" == "N" ]; then
        exit 1
    fi
else
    INFO "内存资源充足。请继续.($memory_usage%)"
fi
}

function CHECKFIRE() {
systemctl stop firewalld &> /dev/null
systemctl disable firewalld &> /dev/null
systemctl stop iptables &> /dev/null
systemctl disable iptables &> /dev/null
ufw disable &> /dev/null
INFO "防火墙已被禁用."

if [[ "$repo_type" == "centos" || "$repo_type" == "rhel" ]]; then
    if sestatus | grep "SELinux status" | grep -q "enabled"; then
        WARN "SELinux 已启用。禁用 SELinux..."
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        INFO "SELinux 已被禁用."
    else
        INFO "SELinux 已被禁用."
    fi
fi
}

function INSTALL_PACKAGE(){
INFO "======================= 安装依赖 ======================="
# 每个软件包的安装超时时间（秒）
TIMEOUT=300
PACKAGES_APT=(
    lsof jq wget tar mailutils
)
PACKAGES_YUM=(
    epel-release lsof jq wget tar yum-utils
)

if [ "$package_manager" = "dnf" ] || [ "$package_manager" = "yum" ]; then
    for package in "${PACKAGES_YUM[@]}"; do
        if $pkg_manager -q "$package" &>/dev/null; then
            INFO "已经安装 $package ..."
        else
            INFO "正在安装 $package ..."

            # 记录开始时间
            start_time=$(date +%s)

            # 安装软件包并等待完成
            $package_manager -y install "$package" --skip-broken > /dev/null 2>&1 &
            install_pid=$!

            # 检查安装是否超时
            while [[ $(($(date +%s) - $start_time)) -lt $TIMEOUT ]] && kill -0 $install_pid &>/dev/null; do
                sleep 1
            done

            # 如果安装仍在运行，提示用户
            if kill -0 $install_pid &>/dev/null; then
                WARN "$package 的安装时间超过 $TIMEOUT 秒。是否继续？ (y/n)"
                read -r continue_install
                if [ "$continue_install" != "y" ]; then
                    ERROR "$package 的安装超时。退出脚本。"
                    exit 1
                else
                    # 直接跳过等待，继续下一个软件包的安装
                    continue
                fi
            fi

            # 检查安装结果
            wait $install_pid
            if [ $? -ne 0 ]; then
                ERROR "$package 安装失败。请检查系统安装源，然后再次运行此脚本！请尝试手动执行安装：$package_manager -y install $package"
                exit 1
            fi
        fi
    done
elif [ "$package_manager" = "apt-get" ] || [ "$package_manager" = "apt" ];then
    dpkg --configure -a &>/dev/null
    $package_manager update &>/dev/null
    for package in "${PACKAGES_APT[@]}"; do
        if $pkg_manager -s "$package" &>/dev/null; then
            INFO "$package 已安装，跳过..."
        else
            INFO "安装 $package ..."
            $package_manager install -y $package > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                ERROR "安装 $package 失败,请检查系统安装源之后再次运行此脚本！请尝试手动执行安装：$package_manager -y install $package"
                exit 1
            fi
        fi
    done
else
    WARN "无法确定包管理系统."
    exit 1
fi
}

function INSTALL_DOCKER() {
INFO "====================== 安装Docker ======================"
# 定义存储库文件名
repo_file="docker-ce.repo"
# 下载存储库文件
url="https://download.docker.com/linux/$repo_type"
# 定义最多重试次数
MAX_ATTEMPTS=3
# 初始化 attempt和 success变量为0和 false
attempt=0
success=false

if [ "$repo_type" = "centos" ] || [ "$repo_type" = "rhel" ]; then
    if ! command -v docker &> /dev/null;then
      while [[ $attempt -lt $MAX_ATTEMPTS ]]; do
        attempt=$((attempt + 1))
        WARN "docker 未安装，正在进行安装..."
        yum-config-manager --add-repo $url/$repo_file &>/dev/null
        $package_manager -y install docker-ce &>/dev/null
        # 检查命令的返回值
        if [ $? -eq 0 ]; then
            success=true
            break
        fi
        ERROR "docker安装失败，正在尝试重新下载 (尝试次数: $attempt)"
      done

      if $success; then
         INFO "docker 安装版本为：$(docker --version)"
         systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
         systemctl enable docker &>/dev/null
      else
         ERROR "docker安装失败，请尝试手动安装"
         exit 1
      fi
    else
      INFO "docker 已安装，安装版本为：$(docker --version)"
      systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
    fi
elif [ "$repo_type" == "ubuntu" ]; then
    if ! command -v docker &> /dev/null;then
      while [[ $attempt -lt $MAX_ATTEMPTS ]]; do
        attempt=$((attempt + 1))
        WARN "docker 未安装，正在进行安装..."
        curl -fsSL $url/gpg | sudo apt-key add - &>/dev/null
        add-apt-repository "deb [arch=amd64] $url $(lsb_release -cs) stable" <<< $'\n' &>/dev/null
        $package_manager -y install docker-ce docker-ce-cli containerd.io &>/dev/null
        # 检查命令的返回值
        if [ $? -eq 0 ]; then
            success=true
            break
        fi
        ERROR "docker 安装失败，正在尝试重新下载 (尝试次数: $attempt)"
      done

      if $success; then
         INFO "docker 安装版本为：$(docker --version)"
         systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
         systemctl enable docker &>/dev/null
      else
         ERROR "docker 安装失败，请尝试手动安装"
         exit 1
      fi
    else
      INFO "docker 已安装，安装版本为：$(docker --version)"
      systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
    fi
elif [ "$repo_type" == "debian" ]; then
    if ! command -v docker &> /dev/null;then
      while [[ $attempt -lt $MAX_ATTEMPTS ]]; do
        attempt=$((attempt + 1))

        WARN "docker 未安装，正在进行安装..."
        curl -fsSL $url/gpg | sudo apt-key add - &>/dev/null
        add-apt-repository "deb [arch=amd64] $url $(lsb_release -cs) stable" <<< $'\n' &>/dev/null
        $package_manager -y install docker-ce docker-ce-cli containerd.io &>/dev/null
        # 检查命令的返回值
        if [ $? -eq 0 ]; then
            success=true
            break
        fi
        ERROR "docker 安装失败，正在尝试重新下载 (尝试次数: $attempt)"
      done

      if $success; then
         INFO "docker 安装版本为：$(docker --version)"
         systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
         systemctl enable docker &>/dev/null
      else
         ERROR "docker 安装失败，请尝试手动安装"
         exit 1
      fi
    else
      INFO "docker 已安装，安装版本为：$(docker --version)"
      systemctl restart docker | grep -E "ERROR|ELIFECYCLE|WARN"
    fi
else
    ERROR "不支持的操作系统."
    exit 1
fi
}

function START_CONTAINER() {
    docker compose up -d --force-recreate
    CHECK_DOCKER_PROXY
    ADD_GATEWAY
    INIT_ALIAS
}

function RESTART_CONTAINER() {
    docker compose restart
}

function CHECK_DOCKER_PROXY(){
    INFO "======================= 检测DOCKER PROXY部署状态 ======================="
    # 获取所有正在运行的容器名称
    running_containers=$(docker ps --format "{{.Names}}")

    # 标记是否有服务未运行
    all_running=true

    for service in "${CONTAINER_NAME_LIST[@]}"
    do
    if ! echo "$running_containers" | grep -q "$service"; then
        ERROR " $service 服务没有在运行，部署失败"
        all_running=false
    fi
    done

    if [ "$all_running" = true ]; then
    INFO "DOCKER PROXY 服务部署成功！"
    else
    exit 1
    fi

}

function INSTALL_DOCKER_PROXY() {
INFO "======================= 开始安装DOCKER PROXY ======================="
wget -P ${PROXY_DIR}/ ${GITRAW}/docker-compose.yaml &>/dev/null

# 创建index.html文件
mkdir -p ${PROXY_DIR}/html
cat <<EOL > ${PROXY_DIR}/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Container Registry Proxy</title>
    <meta http-equiv="refresh" content="0; url=https://github.com/kubesre/docker-registry-mirrors">
</head>
<body>
 <div style="text-align: center;">
     <p>
        Prefixes the image used with 'cr.zsm.io'
     </p>
     <p>
         <b> Source: </b> <a href="https://github.com/kubesre/docker-registry-mirrors">https://github.com/kubesre/docker-registry-mirrors</a>
     </p>
 </div>
</body>
<script>
var _hmt = _hmt || [];
(function() {
  var hm = document.createElement("script");
  hm.src = "https://hm.baidu.com/hm.js?24a74e1829c29d7bd728482105e6f638";
  var s = document.getElementsByTagName("script")[0]; 
  s.parentNode.insertBefore(hm, s);
})();
</script>
</html>
EOL

# 安装服务
START_CONTAINER
}

function STOP_REMOVE_CONTAINER() {
    if [[ -f "${PROXY_DIR}/${DOCKER_COMPOSE_FILE}" ]]; then
        INFO "停止和移除所有容器"
        docker compose -f "${PROXY_DIR}/${DOCKER_COMPOSE_FILE}" down --remove-orphans
    else 
        WARN "容器未运行，无需删除"
        exit 1
    fi
}

function REMOVE_NONE_TAG() {
    docker images | grep "^${IMAGE_NAME}.*<none>" | awk '{print $3}' | xargs -r docker rmi
    images=$(docker images ${IMAGE_NAME} --format '{{.Repository}}:{{.Tag}}')
    latest=$(echo "$images" | sort -V | tail -n1)
    for image in $images
    do
      if [ "$image" != "$latest" ];then
        docker rmi $image
      fi
    done
}

function PACKAGE() {
while true; do
    read -e -p "$(INFO '是否执行软件包安装? [y/n]: ')" choice_package
    case "$choice_package" in
        y|Y )
            INSTALL_PACKAGE
            break;;
        n|N )
            WARN "跳过软件包安装步骤。"
            break;;
        * )
            INFO "请输入 'y' 表示是，或者 'n' 表示否。";;
    esac
done
}

function PROMPT(){
# # 获取公网IP
# PUBLIC_IP=$(curl -s https://ifconfig.me)

# # 获取所有网络接口的IP地址
# ALL_IPS=$(hostname -I)

# # 排除不需要的地址（127.0.0.1和docker0）
# INTERNAL_IP=$(echo "$ALL_IPS" | awk '$1!="127.0.0.1" && $1!="::1" && $1!="docker0" {print $1}')

echo
INFO "=================感谢您的耐心等待，安装已经完成=================="
INFO
INFO "请用增加前缀 ${gateway_domain} 的方式拉取镜像 "
INFO "源镜像拉取地址: docker pull quay.io/argoproj/argocd:v2.11.0"
INFO "增加前缀拉取地址：docker pull ${gateway_domain}/quay.io/argoproj/argocd:v2.11.0"
INFO
INFO
if [[ ${common_alias_domain} -eq 1 ]]; then
    INFO "你已经添加常用别名仓库，也可以使用替换前缀方式拉取镜像: "
    INFO "源镜像拉取地址: docker pull quay.io/argoproj/argocd:v2.11.0"
    INFO "替换前缀拉取地址：docker pull quay.${gateway_domain}/argoproj/argocd:v2.11.0"
    INFO 
    INFO 
    INFO "别名仓库列表如下:"
    GETEWAY="${gateway_domain}"
    for alias in "${ALIASES[@]}"; do
        local name=$(echo $alias | cut -d' ' -f1)
        local original=$(echo $alias | cut -d' ' -f2)
        INFO "原仓库: ${original} 别名仓库:${name}.${gateway_domain}"
    done
fi
INFO  
INFO "代码仓库: https://github.com/kubesre/docker-registry-mirrors"
INFO  
INFO "如果使用的是云服务器，请在安全组中开放80,443端口"
INFO
INFO "================================================================"
}
function SELECT_GATEWAY() {
GATEWAY_FILES=$(ls ${PROXY_DIR}/nginx/gateway-*.conf)
if [ -z "$GATEWAY_FILES" ]; then
  ERROR "没有找到任何网关域名配置文件,请先添加网关"
  exit 1
fi

GATEWAYS=()
for file in $GATEWAY_FILES; do
  domain=$(basename $file | sed 's/gateway-//; s/.conf//')
  GATEWAYS+=($domain)
done

if [ ${#GATEWAYS[@]} -eq 1 ]; then
  GETEWAY=${GATEWAYS[0]}
  INFO "找到一个网关域名：$GETEWAY"
else
  INFO "找到多个网关域名："
  select domain in "${GATEWAYS[@]}"; do
    if [[ " ${GATEWAYS[@]} " =~ " ${domain} " ]]; then
      GETEWAY=$domain
      INFO "选择的网关域名是：$GETEWAY"
      break
    else
      ERROR "无效选择，请重试。"
    fi
  done
fi
}
function SETUP_GATEWAY() {
    domain=${1:-}

    if [[ -z "${domain}" ]]; then
        ERROR "domain is required"
        ADD_GATEWAY
    fi

    endpoint=${2:-}

    if [[ -z "${endpoint}" ]]; then
        ERROR "endpoint is required"
        exit 1
    fi

    function gen() {
        local domain=$1
        local endpoint=$2
        cat <<EOF
server {
    listen 80;
    server_name ${domain};
    server_tokens off;

    access_log  /var/log/nginx/${domain}.access.log  main;

    proxy_set_header  Host              \$http_host;   # required for docker client's sake
    proxy_set_header  X-Real-IP         \$remote_addr; # pass on real client's IP
    proxy_set_header  X-Forwarded-For   \$proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Proto \$scheme;
    proxy_read_timeout                  900;
    proxy_send_timeout                  300;

    proxy_request_buffering             off; # (see issue #2292 - https://github.com/moby/moby/issues/2292)

    # disable any limits to avoid HTTP 413 for large image uploads
    client_max_body_size 0;

    # required to avoid HTTP 411: see Issue #1486 (https://github.com/moby/moby/issues/1486)
    chunked_transfer_encoding on;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    if (\$request_method !~* GET|HEAD) {
        return 403;
    }

    location /v2/ {
        proxy_pass http://${endpoint};
    }
}
EOF
    }

    conf="${PROXY_DIR}/nginx/gateway-${domain}.conf"

    if [[ ! -f "${conf}" ]]; then
        mkdir -p ${PROXY_DIR}/nginx
        gen "${domain}" "${endpoint}" >"${conf}"
    fi
}

function SETUP_ALIAS() {
    domain=${1:-}

    if [[ -z "${domain}" ]]; then
        ERROR "domain is required"
        ADD_ALIAS
    fi

    origin=${2:-}

    if [[ -z "${origin}" ]]; then
        ERROR "origin is required"
        exit 1
    fi

    gateway=${3:-}

    if [[ -z "${gateway}" ]]; then
        ERROR "gateway is required"
        exit 1
    fi

    function gen() {
        local domain=$1
        local origin=$2
        local gateway=$3
        cat <<EOF
server {
    listen 80;
    server_name ${domain};
    server_tokens off;

    access_log  /var/log/nginx/${domain}.access.log  main;

    location = /v2/ {
        default_type "application/json; charset=utf-8";
        return 200 "{}";
    }

    location ~ ^/v2/(.+)\$ {
        return 301 https://${gateway}/v2/${origin}/\$1;
    }
}
EOF
    }

    conf="${PROXY_DIR}/nginx/alias-${domain}.conf"

    if [ ! -f "${conf}" ]; then
        mkdir -p ${PROXY_DIR}/nginx
        gen "${domain}" "${origin}" "${gateway}" >"${conf}"
    fi
}
function ADD_GATEWAY(){
        CHECK_DOCKER_PROXY
        INFO "======================= 配置域名 ======================="
        WARN "网关域名是可以让你以增加前缀的方式拉取源仓库的镜像，配置前请确认域名的[@记录和*记录]已经解析到该服务器！"
        
        read -e -p "$(INFO '请输入域名(如:kubesre.xyz): ')" gateway_domain
        #read -e -p "$(INFO '请输入网关端点: '${DEFAULT_GATEWAY})" gateway_endpoint
        gateway_endpoint=${gateway_endpoint:-$DEFAULT_GATEWAY}
        SETUP_GATEWAY "$gateway_domain" "$gateway_endpoint"
        UPDATE_TLS "$gateway_domain"
        INFO "${gateway_domain} 域名配置成功！"
}
function ADD_COMMON_ALIAS() {
        CHECK_DOCKER_PROXY
        INFO "======================= 增加常用别名仓库 ======================="
        if [[ ! -z ${gateway_domain} ]];then
            GETEWAY="${gateway_domain}"
        else 
            SELECT_GATEWAY
        fi
        
        for alias in "${ALIASES[@]}"; do
            local name=$(echo $alias | cut -d' ' -f1)
            local original=$(echo $alias | cut -d' ' -f2)
            ADD_ALIAS "${name}.${GETEWAY}" "${original}" "${GETEWAY}"
        done
        #常用别名仓库已经添加的标志
        common_alias_domain=1
}
function INIT_ALIAS(){
    while true; do
    read -e -p "$(INFO '是否配置常用仓库别名? [y/n]: ')" configure_alias_domain
    case "$configure_alias_domain" in
        y|Y )

                ADD_COMMON_ALIAS
                break;;
        n|N )
            break;;
        * )
            INFO "请输入 'y' 表示是，或者 'n' 表示否。";;
        esac
done
}
function ADD_ALIAS(){
            CHECK_DOCKER_PROXY
            if [ $# -eq 3 ]; then
                alias_domain=$1
                alias_origin=$2
                gateway_domain=$3
                SETUP_ALIAS "$alias_domain" "$alias_origin" "$gateway_domain"
                UPDATE_TLS "$alias_domain"
            else
            INFO "======================= 增加别名仓库 ======================="
            WARN "别名仓库是可以让你以替换前缀的方式拉取源仓库的镜像，配置前请确认域名的[*记录]已经解析到该服务器！"
            read -e -p "$(INFO '请输入别名域名(如:docker.kubesre.xyz): ')" alias_domain
            read -e -p "$(INFO '请输入别名源(如:docker.io): ')" alias_origin
            read -e -p "$(INFO '请输入网关域名(默认: '${DEFAULT_GATEWAY}'): ')" gateway_domain
            gateway_domain=${gateway_domain:-$DEFAULT_GATEWAY}
            SETUP_ALIAS "$alias_domain" "$alias_origin" "$gateway_domain"
            UPDATE_TLS "$alias_domain"
            INFO "${alias_domain} 别名仓库增加成功！"
            fi
}
function UPDATE_TLS() {
    domain=${1:-}

    if [[ -z "${domain}" ]]; then
        ERROR "domain is required"
        exit 1
    fi

    function cert_renew() {
        local domain=$1
        docker compose exec gateway certbot --nginx -n --rsa-key-size 4096 --agree-tos --register-unsafely-without-email --domains "${domain}"
    }
    INFO "正在为 ${domain} 申请ssl证书..."
    cert_renew "${domain}" &>/tmp/cert_renew.log
    is_error=`grep 'failed' /tmp/cert_renew.log|wc -l`

    # 检查安装结果
    if [ ${is_error} -ne 0 ]; then
        ERROR "${domain} 申请ssl证书失败！请确认域名是否正确，并将域名解析到该服务器！"
        ERROR "错误日志如下："
        cat /tmp/cert_renew.log
        exit 1
    fi
}

function main() {

INFO "====================== 请选择操作 ======================"
echo "1) 新装服务"
echo "2) 重启服务"
echo "3) 更新服务"
# echo "4) 更新配置"
echo "5) 卸载服务"
echo "6) 增加网关"
echo "7) 增加别名"
echo "8) 增加常用仓库别名"
read -e -p "$(INFO '输入对应数字并按 Enter 键: ')" user_choice
case $user_choice in
    1)
        CHECK_OS
        CHECK_PACKAGE_MANAGER
        CHECK_PKG_MANAGER
        CHECKMEM
        CHECKFIRE
        PACKAGE
        INSTALL_DOCKER
        INSTALL_DOCKER_PROXY
        PROMPT
        ;;
    2)
        INFO "======================= 重启服务 ======================="
        docker compose restart
        INFO "======================= 重启完成 ======================="
        ;;
    3)
        INFO "======================= 更新服务 ======================="
        docker compose pull
        docker compose up -d --force-recreate
        INFO "======================= 更新完成 ======================="
        ;;
    4)
        INFO "======================= 更新配置 ======================="
        docker compose restart
        INFO "======================= 更新完成 ======================="
        ;;
    5)
        INFO "======================= 卸载服务 ======================="
        WARN "注意: 卸载服务会一同将项目本地的镜像缓存删除，请执行卸载之前确定是否需要备份本地的镜像缓存文件"
        while true; do
            read -e -p "$(INFO '本人已知晓后果,确认卸载服务? [y/n]: ')" uninstall
            case "$uninstall" in
                y|Y )
                    STOP_REMOVE_CONTAINER
                    REMOVE_NONE_TAG
                    docker rmi --force $(docker images -q ${IMAGE_NAME}) &>/dev/null
                    docker rmi --force $(docker images -q ${CRPROXY_IMAGE_NAME}) &>/dev/null
                    rm -rf ${PROXY_DIR} &>/dev/null
                    INFO "服务已经卸载,感谢你的使用!"
                    INFO "========================================================"
                    break;;
                n|N )
                    WARN "退出卸载服务."
                    break;;
                * )
                    INFO "请输入 'y' 表示是，或者 'n' 表示否。";;
            esac
        done
        ;;
    6)
        ADD_GATEWAY
        ;;
    7)
        ADD_ALIAS
        ;;
    8)
        ADD_COMMON_ALIAS
    
    INFO 
    INFO 
    if [[ ${common_alias_domain} -eq 1 ]]; then
    INFO "=================常用别名仓库添加已经完成=================="
    INFO "你已经添加常用别名仓库，也可以使用替换前缀方式拉取镜像: "
    INFO "源镜像拉取地址: docker pull quay.io/argoproj/argocd:v2.11.0"
    INFO "替换前缀拉取地址：docker pull quay.${gateway_domain}/argoproj/argocd:v2.11.0"
    INFO 
    INFO 
    INFO "别名仓库列表如下:"
    GETEWAY="${gateway_domain}"
    for alias in "${ALIASES[@]}"; do
        local name=$(echo $alias | cut -d' ' -f1)
        local original=$(echo $alias | cut -d' ' -f2)
        INFO "原仓库: ${original} 别名仓库:${name}.${gateway_domain}"
    done
  INFO "===================================================="
  fi
        ;;
    *)
        WARN "输入了无效的选择。请重新运行脚本并选择1-7的选项。"
        ;;
esac
}
main