# claude-glm（claudeglm）

一键给智谱 GLM 装一个完全独立的 Claude Code CLI  
原 `claude` 命令丝毫不受影响，新命令 `claudeglm` 专走 GLM-4.6（国内最快端点）

### 优势
- 100% 隔离：配置、缓存、更新全独立
- 国内最优延迟：使用 open.bigmodel.cn 官方 Anthropic 兼容端点
- 模型映射：
  - Opus / Sonnet → GLM-4.6（最新最强）
  - Haiku → GLM-4.5-Air（极速省钱）
- 成本低至原生 Claude 的 1/5~1/10
- Mac M1/M2/M3/M4、Linux 一次成功，无需 sudo

### 一键安装（复制整段运行）

```bash
curl -L https://raw.githubusercontent.com/lohasle/claude-glm/main/install-claude-glm.sh -o install-claude-glm.sh
chmod +x install-claude-glm.sh
./install-claude-glm.sh
