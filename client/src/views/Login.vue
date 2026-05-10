<template>
  <div class="login-container">
    <div class="login-box">
      <div class="login-header">
        <h1>🎮 MC Admin</h1>
        <p>Minecraft服务器管理后台</p>
      </div>

      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="rules"
        class="login-form"
        @submit.prevent="handleLogin"
      >
        <el-form-item prop="username">
          <el-input
            v-model="loginForm.username"
            placeholder="用户名"
            size="large"
            :prefix-icon="User"
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="密码"
            size="large"
            :prefix-icon="Lock"
            show-password
            @keyup.enter="handleLogin"
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            :loading="loading"
            class="login-button"
            @click="handleLogin"
          >
            {{ loading ? '登录中...' : '登 录' }}
          </el-button>
        </el-form-item>
      </el-form>

      <div class="login-tips">
        <p>默认账号: admin / admin123</p>
      </div>
    </div>

    <div class="login-background">
      <div class="block" v-for="n in 20" :key="n" :style="getBlockStyle(n)"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import api from '../api'

const router = useRouter()
const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: ''
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ]
}

const getBlockStyle = (n) => {
  const colors = ['#4CAF50', '#8BC34A', '#CDDC39', '#009688', '#00BCD4']
  return {
    left: `${Math.random() * 100}%`,
    top: `${Math.random() * 100}%`,
    backgroundColor: colors[n % colors.length],
    animationDelay: `${Math.random() * 5}s`,
    opacity: Math.random() * 0.3 + 0.1
  }
}

const handleLogin = async () => {
  if (!loginFormRef.value) return

  await loginFormRef.value.validate(async (valid) => {
    if (!valid) return

    loading.value = true
    try {
      const { data: res } = await import('axios').then(m => m.default.post('/api/auth/login', loginForm))

      localStorage.setItem('token', res.token)
      localStorage.setItem('username', res.username)
      localStorage.setItem('role', res.role)

      ElMessage.success('登录成功')
      router.push('/dashboard')
    } catch (error) {
      console.error('Login failed:', error)
      ElMessage.error(error.response?.data?.error || '登录失败')
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped lang="scss">
.login-container {
  width: 100%;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  overflow: hidden;
}

.login-box {
  width: 420px;
  padding: 40px;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  position: relative;
  z-index: 10;
}

.login-header {
  text-align: center;
  margin-bottom: 40px;

  h1 {
    font-size: 42px;
    color: #fff;
    margin-bottom: 10px;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
  }

  p {
    color: rgba(255, 255, 255, 0.7);
    font-size: 14px;
  }
}

.login-form {
  :deep(.el-form-item) {
    margin-bottom: 24px;
  }

  :deep(.el-input) {
    --el-input-bg-color: rgba(255, 255, 255, 0.1);
    --el-input-text-color: #fff;
    --el-input-border-color: rgba(255, 255, 255, 0.3);
    --el-input-hover-border-color: #4CAF50;
    --el-input-focus-border-color: #4CAF50;

    .el-input__wrapper {
      background: rgba(255, 255, 255, 0.1);
      box-shadow: none;
      border-radius: 10px;
      padding: 12px 16px;

      &:hover, &.is-focus {
        background: rgba(255, 255, 255, 0.15);
      }
    }

    .el-input__inner {
      color: #fff;

      &::placeholder {
        color: rgba(255, 255, 255, 0.5);
      }
    }
  }
}

.login-button {
  width: 100%;
  height: 50px;
  border-radius: 10px;
  font-size: 18px;
  background: linear-gradient(135deg, #4CAF50 0%, #8BC34A 100%);
  border: none;
  transition: all 0.3s;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(76, 175, 80, 0.4);
  }
}

.login-tips {
  text-align: center;
  margin-top: 20px;

  p {
    color: rgba(255, 255, 255, 0.5);
    font-size: 12px;
  }
}

.login-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;

  .block {
    position: absolute;
    width: 40px;
    height: 40px;
    border-radius: 4px;
    animation: float 10s infinite ease-in-out;

    &:nth-child(odd) {
      animation-direction: reverse;
    }
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0) rotate(0deg);
  }
  50% {
    transform: translateY(-20px) rotate(180deg);
  }
}
</style>
