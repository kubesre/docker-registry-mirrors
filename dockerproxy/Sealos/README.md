<div align="center">

# docker-proxy

[![Auth](https://img.shields.io/badge/Auth-kubesre-ff69b4)](https://github.com/kubesre)
[![GitHub contributors](https://img.shields.io/github/contributors/kubesre/docker-registry-mirrors)](https://github.com/kubesre/docker-registry-mirrors/graphs/contributors)
[![GitHub Issues](https://img.shields.io/github/issues/kubesre/docker-registry-mirrors.svg)](https://github.com/kubesre/docker-registry-mirrors/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/kubesre/docker-registry-mirrors)](https://github.com/kubesre/docker-registry-mirrors/pulls)
[![GitHub Pull Requests](https://img.shields.io/github/stars/kubesre/docker-registry-mirrors)](https://github.com/kubesre/docker-registry-mirrors/stargazers)
[![HitCount](https://views.whatilearened.today/views/github/kubesre/docker-registry-mirrors.svg)](https://github.com/kubesre/docker-registry-mirrors)
[![GitHub license](https://img.shields.io/github/license/kubesre/docker-registry-mirrors)](https://github.com/kubesre/docker-registry-mirrors/blob/main/LICENSE)

<p> 使用 sealos 快速部署自建的Docker镜像加速服务.</p>

</div>


## 📦 部署
**1. 登入 [Sealos](https://cloud.sealos.io/)**

**2. 区域选择(新加坡),然后点击`应用管理`>`新建应用`**
<table>
    <tr>
        <td width="50%" align="center"><img src="images/image1.png"></td>
    </tr>
</table>
<table>
    <tr>
        <td width="50%" align="center"><img src="images/image2.png"></td>
    </tr>
</table>

**3. 填写要给应用名称（随意填写），输入镜像源`gebangfeng/dockerproxy:0.7` cpu和内存拉到最低**
  

<table>
    <tr>
        <td width="50%" align="center"><img src="images/image3.png"></td>
    </tr>
</table>

**4. 网络配置这块，选择公开，并复制好随机分配的域名,后面拉取镜像用的**

<table>
    <tr>
        <td width="50%" align="center"><img src="images/image4.png"></td>
    </tr>
</table>

**5. 其他不用管，点部署应用即可**
<table>
    <tr>
        <td width="50%" align="center"><img src="images/image5.png"></td>
    </tr>
</table>
<table>
    <tr>
        <td width="50%" align="center"><img src="images/image6.png"></td>
    </tr>
</table>

**6. 等待服务`running`，并观察下日志，有日志输出一般就可以了**
<table>
    <tr>
        <td width="50%" align="center"><img src="images/image7.png"></td>
    </tr>
</table>
<table>
    <tr>
        <td width="50%" align="center"><img src="images/image8.png"></td>
    </tr>
</table>

## ✨ 使用

**1. 使用Sealos分配的服务地址，增加前缀的方式拉取镜像(以下只是举例，实际支持所有常用仓库)**

```shell
# docker hub Registry
## 源：nginx:alpine
## 替换
docker pull your_render_url/docker.io/nginx:alpine

# quay.io
## 源：quay.io/argoproj/argocd:v2.11.0
## 替换
docker pull your_render_url/quay.io/argoproj/argocd:v2.11.0
```

**3. 拉取速度测试，效果还是可以的，主要是免费**
![image](images/image9.png)


## ⚠️ 费用方面
**1.** cpu和内存费用，0.21(每天)*30(天)=6.3元/月

![image](images/image10.png)

**2.** 网络费用，0.78元/GB，按流量计费
![image](images/image11.png)


## 感谢以下项目的付出

- [crproxy](https://github.com/wzshiming/crproxy/tree/master/examples/default)
- [Docker-Proxy](https://github.com/dqzboy/Docker-Proxy)