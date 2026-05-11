<template>
  <div class="console-page">
    <el-card class="console-card">
      <template #header>
        <div class="card-header">
          <span>⌘ 命令控制台</span>
          <el-button type="success" size="small" @click="clearOutput">
            <el-icon><Trash2 /></el-icon>
            清空
          </el-button>
        </div>
      </template>

      <div class="console-output" ref="outputRef">
        <div v-for="(log, index) in logs" :key="index" :class="['log-item', log.type]">
          <span class="log-time">{{ log.time }}</span>
          <span class="log-content">{{ log.content }}</span>
        </div>
      </div>

      <div class="console-input">
        <el-input
          v-model="command"
          placeholder="输入命令，按 Enter 执行..."
          size="large"
          @keyup.enter="executeCommand"
          :loading="loading"
          clearable
        >
          <template #append>
            <el-button type="primary" @click="executeCommand" :loading="loading">
              <el-icon><Send /></el-icon>
              执行
            </el-button>
          </template>
        </el-input>
      </div>

      <div class="command-history">
        <span class="history-label">快捷命令：</span>
        <el-button
          v-for="cmd in quickCommands"
          :key="cmd.command"
          size="small"
          type="info"
          plain
          @click="runQuickCommand(cmd.command)"
        >
          {{ cmd.label }}
        </el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, nextTick, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Send, Trash2 } from '@element-plus/icons-vue'
import api from '../api'

const command = ref('')
const loading = ref(false)
const logs = ref([])
const outputRef = ref(null)

const quickCommands = [
  { label: '在线列表', command: 'list' },
  { label: '保存世界', command: 'save-all' },
  { label: '查看时间', command: 'time query daytime' },
  { label: '查看难度', command: 'difficulty' },
  { label: '晴天', command: 'weather clear' },
  { label: '雨天', command: 'weather rain' }
]

const addLog = (content, type = 'info') => {
  logs.value.push({
    time: new Date().toLocaleTimeString('zh-CN'),
    content,
    type
  })
  nextTick(() => {
    if (outputRef.value) {
      outputRef.value.scrollTop = outputRef.value.scrollHeight
    }
  })
}

const executeCommand = async () => {
  if (!command.value.trim()) return
  
  const cmd = command.value.trim()
  addLog(`> ${cmd}`, 'command')
  command.value = ''
  
  loading.value = true
  try {
    const result = await api.sendCommand(cmd)
    addLog(result, 'success')
  } catch (error) {
    addLog(`错误: ${error.message}`, 'error')
    ElMessage.error('命令执行失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

const runQuickCommand = (cmd) => {
  command.value = cmd
  executeCommand()
}

const clearOutput = () => {
  logs.value = []
}

onMounted(() => {
  addLog('欢迎使用 MC Admin 命令控制台', 'system')
  addLog('输入命令后按 Enter 或点击执行按钮', 'system')
  addLog('可以使用快捷命令按钮快速执行常用命令', 'system')
  addLog('----------------------------------------', 'system')
})
</script>

<style scoped lang="scss">
.console-page {
  padding: 20px;
}

.console-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  height: calc(100vh - 140px);
  display: flex;
  flex-direction: column;

  :deep(.el-card__header) {
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    color: #fff;
    font-size: 16px;
    font-weight: 600;
  }

  :deep(.el-card__body) {
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 0;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.console-output {
  flex: 1;
  padding: 16px;
  overflow-y: auto;
  background: rgba(0, 0, 0, 0.3);
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 14px;
  line-height: 1.6;
}

.log-item {
  display: flex;
  gap: 12px;
  margin-bottom: 8px;

  &.command {
    color: #4CAF50;
  }

  &.success {
    color: #8BC34A;
  }

  &.error {
    color: #f44336;
  }

  &.system {
    color: #9E9E9E;
  }

  &.info {
    color: #fff;
  }
}

.log-time {
  color: #607D8B;
  font-size: 12px;
  white-space: nowrap;
}

.log-content {
  flex: 1;
  word-break: break-all;
}

.console-input {
  padding: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.command-history {
  padding: 12px 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.history-label {
  color: rgba(255, 255, 255, 0.6);
  font-size: 13px;
}
</style>
