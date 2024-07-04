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

📢 注意：近日一些提供公有镜像仓库的组织,宣布因监管要求被下架,需要自行核实镜像加速地址的有效性,如果失效了,或者发现了新的镜像也欢迎告诉我们。目前已知提供公有镜像服务比较好的项目：[public-image-mirror](https://github.com/DaoCloud/public-image-mirror)

# 赞助商

## [永久免费的gpt](https://chat.gbfeng.com/)

# 强烈推荐 🚀单镜像加速通道
📢 注意：目前仅支持同步AMD架构的镜像

您可以根据 [镜像同步 Issue 模板](https://github.com/kubesre/docker-registry-mirrors/issues/new?assignees=&labels=sync+image&projects=&template=sync-image.yml) 创建一个 Issue, 将会有机器人帮您优先主动同步指定的镜像
同步结果会在 Issue 中更新,为了节约资源[这里可以查询已经同步过的镜像](https://dockerimage.gbfeng.com)
<details>
<summary><strong>查看同步截图案例</strong></summary>
<div>
  
![](https://images.gbfeng.com/images/202406201502643.png)
  
![](https://images.gbfeng.com/images/202406201459614.png)

</details>



# 快速搭建自己的镜像加速仓库

[搭建自己的镜像加速仓库](dockerproxy/README.md)



# 公益仓库
由于很多仓库都失效了，所以我们搭建了公益的镜像仓库，供大家下载使用。
镜像仓库的带宽有限，所以，推荐自行搭建
- 当前 IP 限流 20r/m (每分钟20个请求)

[搭建自己的镜像加速仓库](dockerproxy/README.md)
```
kubesre.xyz
```
## 使用方法
**增加前缀 (推荐方式)。比如：**
```
k8s.gcr.io/coredns/coredns => kubesre.xyz/k8s.gcr.io/coredns/coredns
```
**或者 支持的镜像仓库 的 前缀替换 就可以使用。比如：**

```
k8s.gcr.io/coredns/coredns => k8s-gcr.kubesre.xyz/coredns/coredns
```


## 支持前缀替换的 Registry

前缀替换的 Registry 的规则, 这是人工配置的, 有需求提 Issue.**

📢 注意： dockerhub仓库的别名：`docker.kubesre.xyz`被墙，更换成：`dhub.kubesre.xyz`

| 源站	                 | 替换为              |
|--------------------------|------------------------------|
| cr.l5d.io                | l5d.kubesre.xyz               |
| docker.elastic.co        | elastic.kubesre.xyz           |
| docker.io                | dhub.kubesre.xyz         |
| gcr.io                   | gcr.kubesre.xyz               |
| ghcr.io                  | ghcr.kubesre.xyz              |
| k8s.gcr.io               | k8s-gcr.kubesre.xyz           |
| registry.k8s.io          | k8s.kubesre.xyz               |
| mcr.microsoft.com        | mcr.kubesre.xyz               |
| nvcr.io                  | nvcr.kubesre.xyz              |
| quay.io                  | quay.kubesre.xyz              |
| registry.jujucharms.com   | jujucharms.kubesre.xyz        |

## 支持这个项目
### 用爱发电
我们提供的服务是免费的，但是为了维护这个项目，我们也需要花费一些精力和服务器带宽和存储费用。如果您觉得这个项目对你有帮助，欢迎您通过以下方式支持我们：

- Star 并分享 [docker-registry-mirrors](https://github.com/kubesre/docker-registry-mirrors)🚀

- 通过以下二维码 一次性捐款，打赏作者一杯茶。🍵
非常感谢！ ❤️


| 微信 | 支付宝 |
|:--------:|:-------:|
| <img src="https://images.gbfeng.com/images/202406191002106.png" width="200" /> | <img src="https://images.gbfeng.com/images/202406191005107.png" width="200" /> |

**提示**

如有赞助行为，请务必添加备注，以便统一感谢！
## 捐赠列表
感谢给予支持的朋友，您的支持是我前进的动力 🎉

如不慎遗漏，请多多包涵 🤝

| 日期       | 用户名          | 金额   | 用户留言                                             |
|------------|-----------------|--------|----------------------------------------------------|
|2024-07-02 |* |     ￥1   |未留言|
|2024-07-02 |*鸿 |     ￥10   |感谢，搭建，希望能一直坚持！|
|2024-06-29 |**辰 |     ￥10   |感谢！|
|2024-06-27 |*舟 |     ￥10   |愿世界更美好|
|2024-06-27 |*白 |     ￥1   |路小白|
|2024-06-23 |*朋 |     ￥100   |妙法莲华，自利利他，佛菩萨也，功德无量。|
|2024-06-18 |1*u |     ￥10   |未留言|
|2024-06-18 |**昕 |     ￥30   |未留言|
|2024-06-18 |*信 |     ￥20   |兄弟加油，买杯奶茶继续润！|
|2024-06-18 |*z |     ￥1   |未留言|
|2024-06-15 |*康 |     ￥100   |希望你们走的远一些，坚持住！|
|2024-06-13 |王磊*站 |     ￥120   |感谢你们提供的镜像服务，极大地方便|
|2024-06-13 |李娜的编程*         |￥85    |镜像站太棒了，解决了我多个项目的依赖问题，支持！|
|2024-06-13 |张强*工作室       |￥200 |  镜像站的稳定性和速度都让我印象深刻，会持续关注和支持！|
| 2024-06-12 | *圳市罗湖区犄落信息咨询工作室    | ￥99   | [xterminal.cn](https://xterminal.cn) 前来支持！         |
| 2024-06-12 | mingjian123     | ￥45   | 服务很好，解决了我拉取Docker镜像的大问题！         |
| 2024-06-12 | codemaster88    | ￥76   | 镜像代理服务稳定，对开发帮助很大，感谢！         |
| 2024-06-12 | sailfishLiu     | ￥65   | 之前拉镜像总是失败，现在轻松多了，非常感谢！     |
| 2024-06-12 | dev_girl_power  | ￥30   | 服务响应快，体验不错，会继续关注和支持！         |
| 2024-06-12 | docker_lover    | ￥70   | 镜像下载速度快，服务稳定，对项目很有帮助！       |
| 2024-06-12 | geek4tech       | ￥23   | 捐赠一点心意，希望你们的服务能惠及更多人！       |
| 2024-06-12 | opensource_fan  | ￥58   | 镜像代理服务让我的开发流程更加顺畅，非常感谢！   |
| 2024-06-12 | linuxguru42     | ￥90   | 服务专业，解决了我在国内拉取Docker镜像的难题！   |
| 2024-06-12 | donate_4_freedom | ￥12   | 虽然只是小额，但希望支持你们继续提供自由的服务！ |
| 2024-06-12 | tech_enthusiast | ￥48   | 服务体验很好，希望你们能继续提供高质量的服务！   |




# 贡献者

<a href="https://github.com/kubesre/docker-registry-mirrors/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=kubesre/docker-registry-mirrors" />
</a>

Made with [contrib.rocks](https://contrib.rocks).
