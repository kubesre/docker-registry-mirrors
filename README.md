<div align="center">

# docker-registry-mirrors

[![Auth](https://img.shields.io/badge/Auth-kubesre-ff69b4)](https://github.com/kubesre)
[![GitHub contributors](https://img.shields.io/github/contributors/kubesre/docker-registry-mirrors)](https://github.com/kubesre/docker-registry-mirrors/graphs/contributors)
[![GitHub Issues](https://img.shields.io/github/issues/kubesre/docker-registry-mirrors.svg)](https://github.com/kubesre/docker-registry-mirrors/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/kubesre/docker-registry-mirrors)](https://github.com/kubesre/docker-registry-mirrors/pulls)
[![GitHub Pull Requests](https://img.shields.io/github/stars/kubesre/docker-registry-mirrors)](https://github.com/kubesre/docker-registry-mirrors/stargazers)
[![HitCount](https://views.whatilearened.today/views/github/kubesre/docker-registry-mirrors.svg)](https://github.com/kubesre/docker-registry-mirrors)
[![GitHub license](https://img.shields.io/github/license/kubesre/docker-registry-mirrors)](https://github.com/kubesre/docker-registry-mirrors/blob/main/LICENSE)

<p> 多平台容器镜像代理服务,支持 Docker Hub, GitHub, Google, k8s, Quay, Microsoft 等镜像仓库. </p>

<img src="https://cdn.jsdelivr.net/gh/kubesre/tu@main/img/image_20240420_214408.gif" width="800"  height="3">
</div><br>

本项目灵感来自：[Thanks-Mirror](https://github.com/eryajf/Thanks-Mirror)，该项目分享的是docker镜像直接可用，质量好，速度快的镜像

在此，对那些提供公共仓库镜像的企业或组织，致以感谢🫡！

📢 注意：今日一些提供公有镜像仓库的组织,宣布因监管要求被下架,需要自行核实镜像加速地址的有效性,如果失效了,或者发现了新的镜像也欢迎告诉我们。目前已知提供公有镜像服务比较好的项目：[public-image-mirror](https://github.com/DaoCloud/public-image-mirror)


<table border="1">
  <tr>
    <th>仓库地址</th>
    <th>镜像地址</th>
    <th>备注</th>
  </tr>
  <tr>
    <td rowspan="3">ghcr.io</td>
    <td>ghcr.nju.edu.cn</td>
    <td>南京大学开源镜像站, nexus3</td>
  </tr>
    <tr>
    <td>ghcr.m.daocloud.io</td>
    <td>daocloud</td>
  </tr>
  <tr>
    <td style="color: red;">ghcr.tencentcloudcr.com</td>
    <td>仅腾讯云vpc内部访问，registry2 proxy</td>
  </tr>
  <tr>
    <td rowspan="3" >registry.k8s.io</td>
    <td>registry-k8s-io.mirrors.sjtug.sjtu.edu.cn</td>
    <td>上海交通大学, registry2 proxy</td>
  </tr>
      <tr>
    <td>k8s.m.daocloud.io</td>
    <td>daocloud</td>
  </tr>
  <tr>
    <td>k8s.nju.edu.cn</td>
    <td>南京大学开源镜像站, nexus3</td>
  </tr>
  <tr>
   <td rowspan="4">k8s.gcr.io</td>
    <td>gcr.nju.edu.cn</td>
    <td>南京大学开源镜像站, nexus3</td>
  </tr>
  <tr>
    <td>k8s-gcr-io.mirrors.sjtug.sjtu.edu.cn</td>
    <td>上海交通大学</td>
  </tr>
      <tr>
    <td>k8s-gcr.m.daocloud.io</td>
    <td>daocloud</td>
  </tr>
  <tr>
    <td style="color: red;">k8s.tencentcloudcr.com</td>
    <td>仅腾讯, 云vpc内部访问, registry2 proxy</td>
  </tr>
  <tr>
    <td rowspan="4">quay.io</td>
    <td>quay.nju.edu.cn</td>
    <td>南京大学开源镜像站, nexus3</td>
  </tr>
  <tr>
    <td>quay.m.daocloud.io</td>
    <td>daocloud</td>
  </tr>
  <tr>
    <td style="color: red;">quay.tencentcloudcr.com</td>
    <td>仅腾讯云vpc内部访问, registry2 proxy</td>
  </tr>
  <tr>
    <td>quay.mirrors.ustc.edu.cn</td>
    <td>中科大</td>
  </tr>
  <tr>
  <td rowspan="3">nvcr.io</td>
    <td>nvcr.nju.edu.cn</td>
    <td>南京大学开源镜像站, nexus3</td>
  </tr>
    <tr>
    <td>nvcr.m.daocloud.io</td>
    <td>daocloud</td>
  </tr>
  <tr>
    <td style="color: red;">nvcr.tencentcloudcr.com</td>
    <td>仅腾讯云vpc内部访问, registry2 proxy</td>
  </tr>
  <tr>
  <td rowspan="7">docker.io</td>
   <td style="color: red;">mirror.ccs.tencentyun.com</td>
    <td>仅腾讯云vpc内部访问, registry2 proxy</td>
  </tr>
  <tr>
    <td>docker.nju.edu.cn</td>
    <td>南京大学开源镜像站, nexus3</td>
  </tr>
  <tr>
    <td>docker.mirrors.sjtug.sjtu.edu.cn</td>  
    <td>上海交通大学, registry2 proxy</td>
  </tr>
    <tr>
    <td>reg-mirror.qiniu.com</td>
    <td>七牛云</td>
  </tr>
    </tr>
    <tr>
    <td>docker.mirrors.ustc.edu.cn</td>
    <td>中科大</td>
  </tr>
  <tr>
    <td>docker.m.daocloud.io</td>
    <td>国内可用, 带宽低</td>
  </tr>
  <tr>
    <td>hub-mirror.c.163.com</td>
    <td>网易国内可用，更新慢</td>
  </tr>

</table>


# 使用方法
## 前言
### 以argocd 清单文件为例：
```bash
wget https://mirror.ghproxy.com/https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 首先需要确定原始镜像地址仓库
以argocd yaml文件举例：
```bash
grep -n image: install.yaml
21645:        image: quay.io/argoproj/argocd:v2.11.0
21739:        image: ghcr.io/dexidp/dex:v2.38.0
21768:        image: quay.io/argoproj/argocd:v2.11.0
21850:        image: quay.io/argoproj/argocd:v2.11.0
21927:        image: redis:7.0.14-alpine
22162:        image: quay.io/argoproj/argocd:v2.11.0
22214:        image: quay.io/argoproj/argocd:v2.11.0
22531:        image: quay.io/argoproj/argocd:v2.11.0
22825:        image: quay.io/argoproj/argocd:v2.11.0
```

### 在表格中找到仓库地址对应的镜像地址
如 **quay.io**在表格中的镜像地址可选择**quay.nju.edu.cn** **ghcr.io** 在表格中的镜像地址可选择 **ghcr.nju.edu.cn**

## 方案一
**使用方式：**

使用方式都是替换原来镜像的前缀域名即可实现加速效果，比如：
```bash
#docker.io
原来地址： redis:7.0.14-alpine  # 这个是官方镜像，省略了前边的域名
替换地址： docker.nju.edu.cn/redis:7.0.14-alpine
#quary.io
原来的地址： quay.io/argoproj/argocd:v2.11.0
替换地址： quay.nju.edu.cn/argoproj/argocd:v2.11.0
#ghcr.io
原来的地址： ghcr.io/dexidp/dex:v2.38.0
替换地址： ghcr.nju.edu.cn/dexidp/dex:v2.38.0
```
## 方案二
### 注意事项
通过这种方式只能加速docker hub的镜像，对于其他镜像仓库，比如k8s.gcr.io, quay.io等，需要使用**方案一**替换前缀的方式进行加速。
### 使用方式：
还有一种方案是通过将加速地址写入到docker配置文件当中实现加速。

**Ubuntu14.04、Debian7Wheezy**

对于使用 upstart 的系统而言，编辑 /etc/default/docker 文件，在其中的 DOCKER_OPTS 中配置加速器地址：
```Bash
DOCKER_OPTS="--registry-mirror=https://hub-mirror.c.163.com"

```
**Ubuntu16.04+、Debian8+、CentOS7**


对于使用 systemd 的系统，请在 /etc/docker/daemon.json 中写入如下内容（如果文件不存在请新建该文件）：
```Bash
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```
# 贡献者

<a href="https://github.com/kubesre/docker-registry-mirrors/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=kubesre/docker-registry-mirrors" />
</a>

Made with [contrib.rocks](https://contrib.rocks).
