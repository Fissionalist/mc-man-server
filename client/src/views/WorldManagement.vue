<template>
  <div class="world-management">
    <el-row :gutter="20">
      <el-col :span="24">
        <el-card class="status-card">
          <template #header>
            <span>💾 世界保存状态</span>
          </template>

          <div class="save-status">
            <div class="status-indicator" :class="saveEnabled ? 'enabled' : 'disabled'">
              <el-icon :size="48">
                <FolderOpened v-if="saveEnabled" />
                <FolderDelete v-else />
              </el-icon>
              <div class="status-text">
                <h3>{{ saveEnabled ? '自动保存已开启' : '自动保存已关闭' }}</h3>
                <p>{{ saveEnabled ? '服务器将自动保存世界数据' : '自动保存已禁用' }}</p>
              </div>
            </div>

            <div class="save-actions">
              <el-button
                type="success"
                size="large"
                :disabled="saveEnabled"
                @click="handleSaveOn"
              >
                <el-icon><FolderOpened /></el-icon>
                开启自动保存
              </el-button>

              <el-button
                type="warning"
                size="large"
                :disabled="!saveEnabled"
                @click="handleSaveOff"
              >
                <el-icon><FolderDelete /></el-icon>
                关闭自动保存
              </el-button>

              <el-button
                type="primary"
                size="large"
                @click="handleSaveAll"
              >
                <el-icon><Refresh /></el-icon>
                立即保存
              </el-button>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="12">
        <el-card class="info-card">
          <template #header>
            <span>📁 世界信息</span>
          </template>

          <div class="world-info">
            <div class="info-item">
              <span class="info-label">世界名称:</span>
              <span class="info-value">world</span>
            </div>
            <div class="info-item">
              <span class="info-label">游戏规则:</span>
              <el-tag size="small">使用中</el-tag>
            </div>
            <div class="info-item">
              <span class="info-label">最后保存:</span>
              <span class="info-value">{{ lastSaveTime }}</span>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card class="info-card">
          <template #header>
            <span>⚙️ 游戏规则</span>
          </template>

          <div class="game-rules">
            <div class="rule-item">
              <span>允许飞行</span>
              <el-switch v-model="gameRules.allowFlight" @change="updateGameRule('allowFlight', gameRules.allowFlight)" />
            </div>
            <div class="rule-item">
              <span>命令方块</span>
              <el-switch v-model="gameRules.commandBlocks" @change="updateGameRule('commandBlocks', gameRules.commandBlocks)" />
            </div>
            <div class="rule-item">
              <span>显示坐标</span>
              <el-switch v-model="gameRules.showCoordinates" @change="updateGameRule('showCoordinates', gameRules.showCoordinates)" />
            </div>
            <div class="rule-item">
              <span>自然生成结构</span>
              <el-switch v-model="gameRules.generateStructures" @change="updateGameRule('generateStructures', gameRules.generateStructures)" />
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="24">
        <el-card class="info-card">
          <template #header>
            <span>🗑️ 服务器维护</span>
          </template>

          <div class="maintenance-actions">
            <el-button type="danger" size="large" @click="restartServer">
              <el-icon><RefreshLeft /></el-icon>
              重启服务器
            </el-button>

            <el-button type="warning" size="large" @click="stopServer">
              <el-icon><VideoPause /></el-icon>
              关闭服务器
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { FolderOpened, FolderDelete, Refresh, RefreshLeft, VideoPause } from '@element-plus/icons-vue'
import api from '../api'

const saveEnabled = ref(true)
const lastSaveTime = ref('未知')
const gameRules = ref({
  allowFlight: false,
  commandBlocks: true,
  showCoordinates: true,
  generateStructures: true
})

onMounted(() => {
  lastSaveTime.value = new Date().toLocaleString('zh-CN')
})

const handleSaveOn = async () => {
  try {
    await api.saveOn()
    saveEnabled.value = true
    ElMessage.success('自动保存已开启')
  } catch (error) {
    ElMessage.error(`操作失败: ${error.message}`)
  }
}

const handleSaveOff = async () => {
  try {
    await ElMessageBox.confirm('关闭自动保存可能会导致未保存的更改丢失,确定要继续吗?', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await api.saveOff()
    saveEnabled.value = false
    ElMessage.success('自动保存已关闭')
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(`操作失败: ${error.message}`)
    }
  }
}

const handleSaveAll = async () => {
  try {
    await api.saveAll()
    lastSaveTime.value = new Date().toLocaleString('zh-CN')
    ElMessage.success('世界保存成功')
  } catch (error) {
    ElMessage.error(`操作失败: ${error.message}`)
  }
}

const updateGameRule = (rule, value) => {
  ElMessage.info(`游戏规则 ${rule} 已${value ? '启用' : '禁用'}`)
}

const restartServer = () => {
  ElMessageBox.alert('重启服务器功能需要在服务器命令行执行,本后台管理系统暂不支持此功能', '提示', {
    confirmButtonText: '知道了'
  })
}

const stopServer = () => {
  ElMessageBox.alert('关闭服务器功能需要在服务器命令行执行,本后台管理系统暂不支持此功能', '提示', {
    confirmButtonText: '知道了'
  })
}
</script>

<style scoped lang="scss">
.world-management {
  padding: 0;
}

.status-card {
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

.save-status {
  padding: 20px 0;
}

.status-indicator {
  display: flex;
  align-items: center;
  gap: 24px;
  padding: 30px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  margin-bottom: 30px;

  &.enabled .el-icon {
    color: #4CAF50;
  }

  &.disabled .el-icon {
    color: #f44336;
  }
}

.status-text {
  flex: 1;

  h3 {
    color: #fff;
    font-size: 24px;
    margin-bottom: 8px;
  }

  p {
    color: rgba(255, 255, 255, 0.6);
    font-size: 14px;
  }
}

.save-actions {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
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

.world-info {
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
  min-width: 100px;
}

.info-value {
  font-size: 14px;
  color: #fff;
  font-weight: 500;
}

.game-rules {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.rule-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  transition: all 0.3s;

  &:hover {
    background: rgba(255, 255, 255, 0.1);
  }

  span {
    font-size: 14px;
    color: #fff;
  }
}

.maintenance-actions {
  display: flex;
  gap: 16px;
}
</style>
