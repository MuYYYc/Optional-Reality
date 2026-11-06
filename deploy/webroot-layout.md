# 当前服务器目录隔离

2026-11-06 实查，连接使用 `ssh -o BatchMode=yes -o User=root muuyyy`。

| 用途 | 目录 |
| --- | --- |
| Muu Tech 官网 | `/var/www/muu-tech/current` → `/var/www/muu-tech/releases/20261022-hero` |
| 游戏前端 | `/var/www/games/current` → `/var/www/games/releases/20261025T121313Z-dccbd5d-physics-ui-optional-reality-game` |
| 游戏后端 | `/opt/optional-reality/current`，Apache 代理回环 3005 |
| 共用 ACME 验证 | `/var/www/acme` |

游戏发布/回滚只操作 games/current，使用 `switch-site.sh --check` 先验证。禁止将官网 release 当作游戏回滚目标。旧 muu-tech/releases 下游戏路径只是兼容链接，新部署不要使用。company-current 是官网 current 的兼容别名。

迁移前备份在 `/var/backups/webroot-layout-20261106`；历史配置不可直接恢复到现网，以免重新混用目录。摄像头和 result 路由属于官网，不随游戏发布修改。私钥、后端 .env 和备份均不得上传到公开目录。
