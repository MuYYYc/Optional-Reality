# Optional Reality 部署

游戏前端与 Muu Tech 官网已于 **2026-11-06** 分开。游戏发版只操作 `/var/www/games`，不再切换 `/var/www/muu-tech/current`。当前拓扑与迁移前备份见 [目录隔离记录](./webroot-layout.md)，游戏版本和历次验收见 [线上记录](./live-game.md)。

## 当前目录

| 用途 | 路径／服务 |
| --- | --- |
| 游戏前端 | `/var/www/games/releases/<版本>`，入口 `/var/www/games/current` |
| Muu Tech 官网 | `/var/www/muu-tech/current`，由官网任务维护 |
| 游戏后端 | `/opt/optional-reality/current`，生产 API 为回环 `127.0.0.1:3005` |
| 生产 API unit | `optional-reality-20261025T121313Z-dccbd5d-physics-ui.service` |
| 共用 HTTP-01 验证目录 | `/var/www/acme`，不依附任何站点 current |

`optionalreality.site` 和 `www.optionalreality.site` 的根目录是游戏，`/intro` 为介绍；`muuyyy.cfd` 根目录现为 Muu Tech，旧 `/intro`、`/demo`、`/showcase`、`/api` 路径以 307 转向专用游戏域名。原官网的 camera/result 路由保留。

## 前端发版

1. 检查工作区与远端，在固定源码快照完成本次必要验证和 `npm run build`。
2. 只读核对游戏／官网 current、游戏后端 current、3005 健康与实际 Apache 路由。备份游戏静态和本次涉及的配置，校验归档；不要打包真实 `.env` 或私钥。
3. 将构建后的 `site/` 内容上传到新的 `/var/www/games/releases/<版本>/`。保留线上旧哈希资源、介绍媒体与演示文件，不覆盖原 release。目录 755、文件 644。
4. 先执行下面的 `--check`，再去掉 `--check` 执行同一条命令。`<新版本>` 和 `<当前版本>` 必须替换为实际核实的目录名。

```sh
ssh -o BatchMode=yes -o User=root muuyyy \
  'bash -s -- --check /var/www/games/releases/<新版本> /var/www/games/releases/<当前版本>' \
  < deploy/switch-site.sh
```

脚本检查新目录同时包含介绍页 `index.html` 和游戏 `demo/index.html`，验证真实路径、预期 current 与 Apache 配置，再原子切换游戏链接。它拒绝官网目录和解析后越出 games/releases 的路径；`--check` 不创建或替换链接。只发布静态文件无需重载 Apache，也无需重启任何 API。

5. 验证两个游戏域名的根目录、关卡、选关、`/intro`、旧 `/demo/`、公开资源哈希、API 和 TLS；另外确认官网首页、camera/result 路由保持原状。需要真实模型验收时使用合成消息，不记录密钥。

## 回退与后端

静态回退仍用同一脚本：将实际旧版本作为第一个参数，将核实的当前游戏版本作为第二个参数，先 `--check` 再切换。旧 release 位于 games/releases；muu-tech/releases 下的同名路径仅为兼容软链接，不再作为发版目标。

后端代码发布沿用独立预检服务／端口和已有进程保留约定，见 [最近一次前后端发布](./physics-ui.md)。静态脚本不修改应用 current 或 API 代理；前后端需要配套回退时，单独核对并切换应用与 API 路由。**不要从迁移前备份整份恢复 Apache 或 Certbot 配置**，以免恢复旧 webroot 或覆盖官网路由；只更新本次需要的指令，并先备份、检查后 graceful。

## 证书与历史

共用一张 `muuyyy.cfd` SAN 证书，三个域名的续期都使用 `/var/www/acme`。后续部署不更改证书、私钥、密钥环境文件或续期目录，见 [域名与路由](./domains-and-routing.md)。

2026-10-24 的介绍页、早期切换流程与备份原文保存在 [历史介绍页记录](./intro-history.md)。历史发布文档的游戏前端路径和命令已映射到 games；版本、端口和服务状态仍是历史记录，回退前须按当前目录映射核对。
