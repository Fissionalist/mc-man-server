<template>
  <div class="main-layout">
    <aside class="sidebar">
      <div class="logo">
        <h2>🎮 MC Admin</h2>
      </div>

      <nav class="nav-menu">
        <router-link to="/dashboard" class="nav-item" active-class="active">
          <el-icon><Monitor /></el-icon>
          <span>控制台</span>
        </router-link>

        <router-link to="/players" class="nav-item" active-class="active">
          <el-icon><User /></el-icon>
          <span>玩家管理</span>
        </router-link>

        <router-link to="/gamesettings" class="nav-item" active-class="active">
          <el-icon><Setting /></el-icon>
          <span>游戏设置</span>
        </router-link>

        <router-link to="/world" class="nav-item" active-class="active">
          <el-icon><Grid /></el-icon>
          <span>世界管理</span>
        </router-link>

        <router-link to="/system" class="nav-item" active-class="active">
          <el-icon><Tools /></el-icon>
          <span>系统设置</span>
        </router-link>

        <router-link to="/console" class="nav-item" active-class="active">
          <el-icon><Tools /></el-icon>
          <span>命令控制台</span>
        </router-link>
      </nav>

      <div class="sidebar-footer">
        <div class="server-status" v-if="serverStatus">
          <span :class="['status-dot', serverStatus.online ? 'online' : 'offline']"></span>
          <span>{{ serverStatus.online ? '服务器在线' : '服务器离线' }}</span>
        </div>
      </div>
    </aside>

    <div class="main-content">
      <header class="header">
        <div class="header-left">
          <h1>{{ pageTitle }}</h1>
        </div>

        <div class="header-right">
          <div class="user-info">
            <el-icon><UserFilled /></el-icon>
            <span>{{ username }}</span>
          </div>

          <el-button 
            type="primary" 
            plain 
            @click="toggleTheme"
            :title="isLightTheme ? '切换到深色主题' : '切换到浅色主题'"
          >
            <el-icon><Sun v-if="isLightTheme" /><Moon v-else /></el-icon>
          </el-button>

          <el-dropdown @command="handleCommand">
            <el-button type="primary" plain>
              <el-icon><ArrowDown /></el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>

      <main class="content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, inject } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { io } from 'socket.io-client'
import {
  Monitor,
  User,
  Setting,
  Grid,
  Tools,
  UserFilled,
  ArrowDown,
  SwitchButton,
  Sun,
  Moon
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const serverStatus = ref(null)
const username = localStorage.getItem('username') || 'Admin'
const toggleTheme = inject('toggleTheme')
const isLightTheme = inject('isLightTheme')
let socket = null

const pageTitle = computed(() => {
  const titles = {
    Dashboard: '控制台',
    Players: '玩家管理',
    GameSettings: '游戏设置',
    WorldManagement: '世界管理',
    SystemSettings: '系统设置',
    CommandConsole: '命令控制台'
  }
  return titles[route.name] || '控制台'
})

onMounted(() => {
  socket = io('/', {
    transports: ['websocket', 'polling']
  })

  socket.on('connect', () => {
    console.log('Socket connected')
  })

  socket.on('serverStatus', (status) => {
    serverStatus.value = status
  })

  socket.on('disconnect', () => {
    console.log('Socket disconnected')
  })
})

onUnmounted(() => {
  if (socket) {
    socket.disconnect()
  }
})

const handleCommand = (command) => {
  if (command === 'logout') {
    ElMessageBox.confirm('确定要退出登录吗?', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }).then(() => {
      localStorage.clear()
      router.push('/login')
    }).catch(() => {})
  }
}
</script>

<style scoped lang="scss">
.main-layout {
  display: flex;
  width: 100%;
  height: 100vh;
}

.sidebar {
  width: 240px;
  background: rgba(0, 0, 0, 0.3);
  display: flex;
  flex-direction: column;
  border-right: 1px solid rgba(255, 255, 255, 0.1);
}

.logo {
  padding: 24px 20px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);

  h2 {
    color: #fff;
    font-size: 20px;
    text-align: center;
  }
}

.nav-menu {
  flex: 1;
  padding: 20px 0;
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 14px 24px;
  color: rgba(255, 255, 255, 0.7);
  text-decoration: none;
  transition: all 0.3s;
  gap: 12px;

  &:hover {
    background: rgba(255, 255, 255, 0.1);
    color: #fff;
  }

  &.active {
    background: linear-gradient(90deg, rgba(76, 175, 80, 0.3) 0%, transparent 100%);
    color: #4CAF50;
    border-left: 3px solid #4CAF50;
  }

  span {
    font-size: 15px;
  }
}

.sidebar-footer {
  padding: 20px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.server-status {
  display: flex;
  align-items: center;
  gap: 8px;
  color: rgba(255, 255, 255, 0.7);
  font-size: 13px;

  .status-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    animation: pulse 2s infinite;

    &.online {
      background: #4CAF50;
      box-shadow: 0 0 8px rgba(76, 175, 80, 0.6);
    }

    &.offline {
      background: #f44336;
      box-shadow: 0 0 8px rgba(244, 67, 54, 0.6);
    }
  }
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.header {
  height: 64px;
  background: rgba(255, 255, 255, 0.05);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
}

.header-left h1 {
  color: #fff;
  font-size: 20px;
  font-weight: 500;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  color: rgba(255, 255, 255, 0.8);
  font-size: 14px;
}

.content {
  flex: 1;
  padding: 24px;
  overflow-y: auto;
}
</style>
