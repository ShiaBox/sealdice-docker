# sealdice-docker
海豹骰非官方Docker镜像，补全运行库，允许使用内置Lagrange登录.

[Docker Hub](https://hub.docker.com/r/shiaworkshop/sealdice)

镜像会自动根据上游发布而构建，支持amd64/arm64

## 标签说明

本镜像的构建分为三种大类构成

- 最新发布版本(latest) -> 对应所有通道中最新的版本
- 正式发布版本(release) -> 对应有版本号的正式发布版本
- 抢先体验版本(pre-release) -> 对应预发布通道的版本

正式发布版本(release)标签会推送为： `latest` / `v1.x.x` / `stable`

抢先体验版本(pre-release)标签会推送为： `latest` / `10aa805`(commit hash) / `pre`

