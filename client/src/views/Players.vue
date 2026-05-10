<template>
  <div class="players">
    <el-row :gutter="20">
      <el-col :span="8">
        <el-card class="player-card">
          <template #header>
            <span>👥 在线玩家</span>
          </template>

          <div class="player-list">
            <div v-for="player in onlinePlayers" :key="player" class="player-item">
              <el-avatar :size="40" style="background: linear-gradient(135deg, #4CAF50, #8BC34A);">
                {{ player.charAt(0).toUpperCase() }}
              </el-avatar>
              <div class="player-details">
                <span class="player-name">{{ player }}</span>
                <span class="player-status">在线</span>
              </div>
              <el-dropdown @command="(cmd) => handlePlayerAction(cmd, player)">
                <el-button type="primary" size="small">
                  操作<el-icon class="el-icon--right"><ArrowDown /></el-icon>
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item command="op">赐予OP</el-dropdown-item>
                    <el-dropdown-item command="deop">移除OP</el-dropdown-item>
                    <el-dropdown-item command="kick">踢出玩家</el-dropdown-item>
                    <el-dropdown-item command="ban">封禁玩家</el-dropdown-item>
                    <el-dropdown-item command="gamemode">修改游戏模式</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
            <el-empty v-if="onlinePlayers.length === 0" description="当前没有玩家在线" />
          </div>

          <el-button type="primary" size="default" style="width: 100%; margin-top: 16px;" @click="refreshPlayers">
            <el-icon><Refresh /></el-icon>
            刷新列表
          </el-button>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="player-card">
          <template #header>
            <span>✅ 白名单玩家</span>
          </template>

          <div class="player-list">
            <div v-for="player in whitelistPlayers" :key="player" class="player-item">
              <el-avatar :size="40" style="background: linear-gradient(135deg, #2196F3, #03A9F4);">
                {{ player.charAt(0).toUpperCase() }}
              </el-avatar>
              <div class="player-details">
                <span class="player-name">{{ player }}</span>
                <span class="player-status">白名单</span>
              </div>
              <el-button type="danger" size="small" @click="handleWhitelistRemove(player)">
                移除
              </el-button>
            </div>
            <el-empty v-if="whitelistPlayers.length === 0" description="白名单为空" />
          </div>

          <el-input
            v-model="whitelistInput"
            placeholder="输入玩家名称"
            size="default"
            style="margin-top: 16px;"
          >
            <template #append>
              <el-button @click="handleWhitelistAdd">添加</el-button>
            </template>
          </el-input>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="player-card">
          <template #header>
            <span>🚫 封禁玩家</span>
          </template>

          <div class="player-list">
            <div v-for="player in bannedPlayers" :key="player" class="player-item">
              <el-avatar :size="40" style="background: linear-gradient(135deg, #f44336, #e91e63);">
                {{ player.charAt(0).toUpperCase() }}
              </el-avatar>
              <div class="player-details">
                <span class="player-name">{{ player }}</span>
                <span class="player-status">已封禁</span>
              </div>
              <el-button type="success" size="small" @click="handlePardon(player)">
                解封
              </el-button>
            </div>
            <el-empty v-if="bannedPlayers.length === 0" description="没有封禁玩家" />
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog v-model="kickDialogVisible" title="踢出玩家" width="400px">
      <el-form>
        <el-form-item label="玩家">
          <el-input v-model="currentPlayer" disabled />
        </el-form-item>
        <el-form-item label="原因(可选)">
          <el-input v-model="kickReason" placeholder="输入踢出原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="kickDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmKick">确认踢出</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="banDialogVisible" title="封禁玩家" width="400px">
      <el-form>
        <el-form-item label="玩家">
          <el-input v-model="currentPlayer" disabled />
        </el-form-item>
        <el-form-item label="原因(可选)">
          <el-input v-model="banReason" placeholder="输入封禁原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="banDialogVisible = false">取消</el-button>
        <el-button type="danger" @click="confirmBan">确认封禁</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="gamemodeDialogVisible" title="修改游戏模式" width="400px">
      <el-form>
        <el-form-item label="玩家">
          <el-input v-model="currentPlayer" disabled />
        </el-form-item>
        <el-form-item label="游戏模式">
          <el-select v-model="selectedGamemode" style="width: 100%;">
            <el-option label="生存模式 (Survival)" value="survival" />
            <el-option label="创造模式 (Creative)" value="creative" />
            <el-option label="冒险模式 (Adventure)" value="adventure" />
            <el-option label="旁观模式 (Spectator)" value="spectator" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="gamemodeDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmGamemode">确认修改</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh, ArrowDown } from '@element-plus/icons-vue'
import api from '../api'

const onlinePlayers = ref([])
const whitelistPlayers = ref([])
const bannedPlayers = ref([])

const kickDialogVisible = ref(false)
const banDialogVisible = ref(false)
const gamemodeDialogVisible = ref(false)

const currentPlayer = ref('')
const kickReason = ref('')
const banReason = ref('')
const whitelistInput = ref('')
const selectedGamemode = ref('survival')

onMounted(() => {
  loadAllLists()
})

const loadAllLists = async () => {
  await Promise.all([
    loadOnlinePlayers(),
    loadWhitelist(),
    loadBanlist()
  ])
}

const loadOnlinePlayers = async () => {
  try {
    const result = await api.getPlayerList()
    const match = result.result.match(/players online:\s*(.*)/i)
    if (match && match[1].trim()) {
      onlinePlayers.value = match[1].trim().split(',').filter(p => p.trim())
    } else {
      onlinePlayers.value = []
    }
  } catch (error) {
    console.error('Failed to load players:', error)
    ElMessage.error('加载玩家列表失败')
  }
}

const loadWhitelist = async () => {
  try {
    const result = await api.getWhitelist()
    if (result.whitelist) {
      const match = result.whitelist.match(/:\s*(.*)/i)
      if (match && match[1].trim()) {
        whitelistPlayers.value = match[1].trim().split(',').map(p => p.trim()).filter(p => p)
      } else {
        whitelistPlayers.value = []
      }
    }
  } catch (error) {
    console.error('Failed to load whitelist:', error)
  }
}

const loadBanlist = async () => {
  try {
    const result = await api.getBanlist()
    if (result.banlist) {
      const match = result.banlist.match(/:\s*(.*)/i)
      if (match && match[1].trim()) {
        bannedPlayers.value = match[1].trim().split(',').map(p => p.trim()).filter(p => p)
      } else {
        bannedPlayers.value = []
      }
    }
  } catch (error) {
    console.error('Failed to load banlist:', error)
  }
}

const refreshPlayers = () => {
  loadAllLists()
  ElMessage.success('列表已刷新')
}

const handlePlayerAction = (command, player) => {
  currentPlayer.value = player

  switch (command) {
    case 'op':
      handleOp(player)
      break
    case 'deop':
      handleDeop(player)
      break
    case 'kick':
      kickDialogVisible.value = true
      break
    case 'ban':
      banDialogVisible.value = true
      break
    case 'gamemode':
      gamemodeDialogVisible.value = true
      break
  }
}

const handleOp = async (player) => {
  try {
    await api.opPlayer(player)
    ElMessage.success(`${player} 已获得OP权限`)
  } catch (error) {
    ElMessage.error(`操作失败: ${error.message}`)
  }
}

const handleDeop = async (player) => {
  try {
    await api.deopPlayer(player)
    ElMessage.success(`${player} 的OP权限已移除`)
  } catch (error) {
    ElMessage.error(`操作失败: ${error.message}`)
  }
}

const confirmKick = async () => {
  try {
    await api.kickPlayer(currentPlayer.value, kickReason.value)
    ElMessage.success(`${currentPlayer.value} 已被踢出`)
    kickDialogVisible.value = false
    kickReason.value = ''
    await loadOnlinePlayers()
  } catch (error) {
    ElMessage.error(`操作失败: ${error.message}`)
  }
}

const confirmBan = async () => {
  try {
    await api.banPlayer(currentPlayer.value, banReason.value)
    ElMessage.success(`${currentPlayer.value} 已被封禁`)
    banDialogVisible.value = false
    banReason.value = ''
    await Promise.all([loadOnlinePlayers(), loadBanlist()])
  } catch (error) {
    ElMessage.error(`操作失败: ${error.message}`)
  }
}

const confirmGamemode = async () => {
  try {
    await api.setGamemode(selectedGamemode.value, currentPlayer.value)
    ElMessage.success(`${currentPlayer.value} 的游戏模式已修改为 ${selectedGamemode.value}`)
    gamemodeDialogVisible.value = false
  } catch (error) {
    ElMessage.error(`操作失败: ${error.message}`)
  }
}

const handleWhitelistAdd = async () => {
  if (!whitelistInput.value.trim()) {
    ElMessage.warning('请输入玩家名称')
    return
  }

  try {
    await api.whitelistAdd(whitelistInput.value.trim())
    ElMessage.success(`${whitelistInput.value} 已添加到白名单`)
    whitelistInput.value = ''
    await loadWhitelist()
  } catch (error) {
    ElMessage.error(`操作失败: ${error.message}`)
  }
}

const handleWhitelistRemove = async (player) => {
  try {
    await ElMessageBox.confirm(`确定要从白名单移除 ${player} 吗?`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await api.whitelistRemove(player)
    ElMessage.success(`${player} 已从白名单移除`)
    await loadWhitelist()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(`操作失败: ${error.message}`)
    }
  }
}

const handlePardon = async (player) => {
  try {
    await ElMessageBox.confirm(`确定要解封 ${player} 吗?`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await api.pardonPlayer(player)
    ElMessage.success(`${player} 已解封`)
    await loadBanlist()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(`操作失败: ${error.message}`)
    }
  }
}
</script>

<style scoped lang="scss">
.players {
  padding: 0;
}

.player-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  height: calc(100vh - 180px);

  :deep(.el-card__header) {
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    color: #fff;
    font-size: 16px;
    font-weight: 600;
  }

  :deep(.el-card__body) {
    height: calc(100% - 60px);
    overflow-y: auto;
  }
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
    transform: translateX(4px);
  }
}

.player-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.player-name {
  font-size: 14px;
  color: #fff;
  font-weight: 500;
}

.player-status {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
}
</style>
