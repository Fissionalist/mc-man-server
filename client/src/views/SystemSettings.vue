<template>
  <div class="system-settings">
    <el-row :gutter="20">
      <el-col :span="12">
        <el-card class="settings-card">
          <template #header>
            <span>👤 账户管理</span>
          </template>

          <div class="settings-content">
            <div class="user-info">
              <el-avatar :size="64" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                {{ username?.charAt(0).toUpperCase() }}
              </el-avatar>
              <div class="user-details">
                <h3>{{ username }}</h3>
                <el-tag type="success">{{ role }}</el-tag>
              </div>
            </div>

            <el-divider />

            <el-form :model="passwordForm" label-position="top">
              <el-form-item label="修改密码">
                <el-input v-model="passwordForm.oldPassword" type="password" placeholder="旧密码" />
              </el-form-item>
              <el-form-item>
                <el-input v-model="passwordForm.newPassword" type="password" placeholder="新密码" />
              </el-form-item>
              <el-form-item>
                <el-input v-model="passwordForm.confirmPassword" type="password" placeholder="确认新密码" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="handleChangePassword">修改密码</el-button>
              </el-form-item>
            </el-form>
          </div>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card class="settings-card">
          <template #header>
            <span>➕ 添加管理员</span>
          </template>

          <div class="settings-content">
            <el-form :model="newUserForm" label-position="top">
              <el-form-item label="用户名">
                <el-input v-model="newUserForm.username" placeholder="输入用户名" />
              </el-form-item>
              <el-form-item label="密码">
                <el-input v-model="newUserForm.password" type="password" placeholder="输入密码" />
              </el-form-item>
              <el-form-item label="角色">
                <el-select v-model="newUserForm.role" style="width: 100%;">
                  <el-option label="管理员" value="admin" />
                  <el-option label="操作员" value="operator" />
                </el-select>
              </el-form-item>
              <el-form-item>
                <el-button type="success" @click="handleAddUser">添加用户</el-button>
              </el-form-item>
            </el-form>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="24">
        <el-card class="settings-card">
          <template #header>
            <span>⚙️ 系统信息</span>
          </template>

          <div class="system-info">
            <div class="info-grid">
              <div class="info-item">
                <span class="label">系统版本:</span>
                <span class="value">1.0.0</span>
              </div>
              <div class="info-item">
                <span class="label">Node.js版本:</span>
                <span class="value">{{ nodeVersion }}</span>
              </div>
              <div class="info-item">
                <span class="label">Vue版本:</span>
                <span class="value">3.3.8</span>
              </div>
              <div class="info-item">
                <span class="label">服务器时间:</span>
                <span class="value">{{ currentTime }}</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="24">
        <el-card class="settings-card">
          <template #header>
            <span>📖 使用帮助</span>
          </template>

          <div class="help-content">
            <el-collapse>
              <el-collapse-item title="如何连接Minecraft服务器?" name="1">
                <p>确保Minecraft服务器已启用RCON并在server.properties中配置了以下内容:</p>
                <pre>enable-rcon=true
rcon.port=25575
rcon.password=your_password</pre>
              </el-collapse-item>

              <el-collapse-item title="默认登录密码是什么?" name="2">
                <p>默认管理员账户: <strong>admin</strong> / <strong>admin123</strong></p>
                <p>请在首次登录后立即修改密码!</p>
              </el-collapse-item>

              <el-collapse-item title="如何配置RCON连接?" name="3">
                <p>在服务器上的.env文件中配置:</p>
                <pre>RCON_HOST=127.0.0.1
RCON_PORT=25575
RCON_PASSWORD=your_rcon_password</pre>
              </el-collapse-item>

              <el-collapse-item title="支持哪些Minecraft版本?" name="4">
                <p>本系统支持Minecraft 1.12.2及以上版本,只要服务器启用了RCON即可。</p>
              </el-collapse-item>
            </el-collapse>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '../api'

const username = localStorage.getItem('username') || 'admin'
const role = localStorage.getItem('role') || 'admin'
const nodeVersion = ref('N/A')
const currentTime = ref('')

const passwordForm = ref({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const newUserForm = ref({
  username: '',
  password: '',
  role: 'operator'
})

let timeInterval = null

onMounted(() => {
  updateTime()
  timeInterval = setInterval(updateTime, 1000)

  nodeVersion.value = process.version || 'N/A'
})

onUnmounted(() => {
  if (timeInterval) {
    clearInterval(timeInterval)
  }
})

const updateTime = () => {
  currentTime.value = new Date().toLocaleString('zh-CN')
}

const handleChangePassword = async () => {
  if (!passwordForm.value.oldPassword || !passwordForm.value.newPassword) {
    ElMessage.warning('请填写所有字段')
    return
  }

  if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
    ElMessage.error('两次输入的密码不一致')
    return
  }

  try {
    await ElMessageBox.confirm('确定要修改密码吗?', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    ElMessage.success('密码修改成功')
    passwordForm.value = {
      oldPassword: '',
      newPassword: '',
      confirmPassword: ''
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(`修改失败: ${error.message}`)
    }
  }
}

const handleAddUser = async () => {
  if (!newUserForm.value.username || !newUserForm.value.password) {
    ElMessage.warning('请填写所有字段')
    return
  }

  try {
    await api.register(newUserForm.value)
    ElMessage.success(`用户 ${newUserForm.value.username} 创建成功`)
    newUserForm.value = {
      username: '',
      password: '',
      role: 'operator'
    }
  } catch (error) {
    ElMessage.error(`创建失败: ${error.message}`)
  }
}
</script>

<style scoped lang="scss">
.system-settings {
  padding: 0;
}

.settings-card {
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

.settings-content {
  padding: 10px 0;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
}

.user-details {
  flex: 1;

  h3 {
    color: #fff;
    font-size: 24px;
    margin-bottom: 8px;
  }
}

.system-info {
  padding: 10px 0;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 16px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;

  .label {
    font-size: 13px;
    color: rgba(255, 255, 255, 0.6);
  }

  .value {
    font-size: 15px;
    color: #fff;
    font-weight: 500;
  }
}

.help-content {
  :deep(.el-collapse) {
    border: none;
    background: transparent;

    .el-collapse-item__header {
      background: rgba(255, 255, 255, 0.05);
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
      color: #fff;
      font-size: 14px;

      &:hover {
        background: rgba(255, 255, 255, 0.1);
      }
    }

    .el-collapse-item__wrap {
      background: transparent;
      border-bottom: none;
    }

    .el-collapse-item__content {
      color: rgba(255, 255, 255, 0.7);
      padding: 16px;

      p {
        margin-bottom: 12px;
        line-height: 1.6;
      }

      pre {
        background: rgba(0, 0, 0, 0.3);
        padding: 12px;
        border-radius: 6px;
        font-size: 13px;
        overflow-x: auto;
        margin: 12px 0;
      }
    }
  }
}
</style>
