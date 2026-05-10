<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <el-col :span="6">
        <div class="stat-card">
          <div class="stat-icon" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
            <el-icon><User /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ onlinePlayers }}</div>
            <div class="stat-label">在线玩家</div>
          </div>
        </div>
      </el-col>

      <el-col :span="6">
        <div class="stat-card">
          <div class="stat-icon" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
            <el-icon><Timer /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ tps || 'N/A' }}</div>
            <div class="stat-label">服务器TPS</div>
          </div>
        </div>
      </el-col>

      <el-col :span="6">
        <div class="stat-card">
          <div class="stat-icon" :class="serverOnline ? 'online' : 'offline'">
            <el-icon><CircleCheck v-if="serverOnline" /><CircleClose v-else /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ serverOnline ? '在线' : '离线' }}</div>
            <div class="stat-label">服务器状态</div>
          </div>
        </div>
      </el-col>

      <el-col :span="6">
        <div class="stat-card">
          <div class="stat-icon" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
            <el-icon><Cpu /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ uptime }}</div>
            <div class="stat-label">运行时间</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="12">
        <el-card class="info-card">
          <template #header>
            <div class="card-header">
              <span>📋 在线玩家</span>
              <el-button type="primary" size="small" @click="refreshPlayers">
                <el-icon><Refresh /></el-icon>
                刷新
              </el-button>
            </div>
          </template>

          <div v-if="playerList.length > 0" class="player-list">
            <div v-for="player in playerList" :key="player" class="player-item">
              <el-avatar :size="32" style="background: #4CAF50;">
                {{ player.charAt(0).toUpperCase() }}
              </el-avatar>
              <span class="player-name">{{ player }}</span>
              <el-tag size="small" type="success">在线</el-tag>
            </div>
          </div>
          <el-empty v-else description="当前没有玩家在线" />
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card class="info-card">
          <template #header>
            <span>⚙️ 服务器信息</span>
          </template>

          <div class="server-info">
            <div class="info-item">
              <span class="info-label">服务器地址:</span>
              <span class="info-value">{{ serverInfo.host }}:{{ serverInfo.port }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">RCON状态:</span>
              <el-tag :type="serverOnline ? 'success' : 'danger'">
                {{ serverOnline ? '已连接' : '未连接' }}
              </el-tag>
            </div>
            <div class="info-item">
              <span class="info-label">Minecraft版本:</span>
              <span class="info-value">1.12.2</span>
            </div>
            <div class="info-item">
              <span class="info-label">管理面板版本:</span>
              <span class="info-value">1.0.0</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="24">
        <el-card class="info-card">
          <template #header>
            <span>📊 快速操作</span>
          </template>

          <div class="quick-actions">
            <el-button type="primary" @click="$router.push('/players')">
              <el-icon><User /></el-icon>
              玩家管理
            </el-button>
            <el-button type="success" @click="$router.push('/gamesettings')">
              <el-icon><Setting /></el-icon>
              游戏设置
            </el-button>
            <el-button type="warning" @click="$router.push('/world')">
              <el-icon><Folder /></el-icon>
              世界管理
            </el-button>
            <el-button type="info" @click="refreshAll">
              <el-icon><Refresh /></el-icon>
              刷新全部
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'
import { io } from 'socket.io-client'
import api from '../api'
import {
  User,
  Timer,
  CircleCheck,
  CircleClose,
  Cpu,
  Refresh,
  Setting,
  Folder
} from '@element-plus/icons-vue'

const serverOnline = ref(false)
const playerList = ref([])
const tps = ref(null)
const uptime = ref('0:00:00')
const serverInfo = ref({ host: '127.0.0.1', port: 25575 })
const startTime = Date.now()
let socket = null
let uptimeInterval = null

const onlinePlayers = computed(() => playerList.value.length)

onMounted(() => {
  socket = io('/', {
    transports: ['websocket', 'polling']
  })

  socket.on('connect', () => {
    console.log('Socket connected')
  })

  socket.on('serverStatus', (status) => {
    serverOnline.value = status.online
    if (status.players) {
      const match = status.players.match(/players online:\s*(.*)/i)
      if (match) {
        playerList.value = match[1].trim().split(',').filter(p => p.trim())
      }
    }
    if (status.tps) {
      tps.value = status.tps
    }
  })

  socket.on('disconnect', () => {
    console.log('Socket disconnected')
  })

  uptimeInterval = setInterval(() => {
    const diff = Date.now() - startTime
    const hours = Math.floor(diff / 3600000)
    const minutes = Math.floor((diff % 3600000) / 60000)
    const seconds = Math.floor((diff % 60000) / 1000)
    uptime.value = `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  }, 1000)

  loadServerStatus()
})

onUnmounted(() => {
  if (socket) {
    socket.disconnect()
  }
  if (uptimeInterval) {
    clearInterval(uptimeInterval)
  }
})

const loadServerStatus = async () => {
  try {
    const status = await api.getServerStatus()
    serverOnline.value = status.online
    serverInfo.value = { host: status.host, port: status.port }
  } catch (error) {
    console.error('Failed to load server status:', error)
  }
}

const refreshPlayers = async () => {
  try {
    const result = await api.getPlayerList()
    const match = result.result.match(/players online:\s*(.*)/i)
    if (match) {
      playerList.value = match[1].trim().split(',').filter(p => p.trim())
    }
    ElMessage.success('玩家列表已刷新')
  } catch (error) {
    ElMessage.error('刷新失败: ' + error.message)
  }
}

const refreshAll = async () => {
  await loadServerStatus()
  await refreshPlayers()
  ElMessage.success('全部刷新完成')
}
</script>

<style scoped lang="scss">
.dashboard {
  padding: 0;
}

.stat-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  transition: all 0.3s;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
  }
}

.stat-icon {
  width: 64px;
  height: 64px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: #fff;

  &.online {
    background: linear-gradient(135deg, #4CAF50 0%, #8BC34A 100%);
  }

  &.offline {
    background: linear-gradient(135deg, #f44336 0%, #e91e63 100%);
  }
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #fff;
  line-height: 1;
}

.stat-label {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.6);
  margin-top: 8px;
}

.info-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.1);

  :deep(.el-card__header) {
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    color: #fff;
    font-size: 16px;
    font-weight: 600;
  }

  :deep(.el-card__body) {
    color: rgba(255, 255, 255, 0.8);
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #fff;
}

.player-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.player-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  transition: all 0.3s;

  &:hover {
    background: rgba(255, 255, 255, 0.1);
  }
}

.player-name {
  flex: 1;
  font-size: 14px;
  color: #fff;
}

.server-info {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);

  &:last-child {
    border-bottom: none;
  }
}

.info-label {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.6);
  min-width: 120px;
}

.info-value {
  font-size: 14px;
  color: #fff;
  font-weight: 500;
}

.quick-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}
</style>
