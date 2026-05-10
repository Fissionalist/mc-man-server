<template>
  <div class="game-settings">
    <el-row :gutter="20">
      <el-col :span="12">
        <el-card class="settings-card">
          <template #header>
            <span>⚔️ 游戏难度</span>
          </template>

          <div class="setting-content">
            <div class="current-setting">
              <span class="label">当前难度:</span>
              <el-tag :type="getDifficultyType(currentDifficulty)" size="large">
                {{ getDifficultyText(currentDifficulty) }}
              </el-tag>
            </div>

            <el-divider />

            <div class="setting-actions">
              <el-button
                v-for="diff in difficulties"
                :key="diff.value"
                :type="currentDifficulty === diff.value ? 'primary' : 'default'"
                size="large"
                @click="setDifficulty(diff.value)"
              >
                {{ diff.label }}
              </el-button>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card class="settings-card">
          <template #header>
            <span>🎮 游戏模式</span>
          </template>

          <div class="setting-content">
            <div class="current-setting">
              <span class="label">默认模式:</span>
              <el-tag type="success" size="large">
                {{ getGamemodeText(currentGamemode) }}
              </el-tag>
            </div>

            <el-divider />

            <div class="setting-actions">
              <el-button
                v-for="mode in gamemodes"
                :key="mode.value"
                :type="currentGamemode === mode.value ? 'primary' : 'default'"
                size="large"
                @click="setGamemode(mode.value)"
              >
                {{ mode.label }}
              </el-button>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="12">
        <el-card class="settings-card">
          <template #header>
            <span>🌤️ 天气控制</span>
          </template>

          <div class="setting-content">
            <div class="weather-options">
              <div
                v-for="weather in weatherOptions"
                :key="weather.value"
                class="weather-item"
                :class="{ active: selectedWeather === weather.value }"
                @click="setWeather(weather.value)"
              >
                <div class="weather-icon">{{ weather.icon }}</div>
                <div class="weather-label">{{ weather.label }}</div>
              </div>
            </div>

            <el-divider />

            <div class="weather-duration">
              <span>持续时间 (秒):</span>
              <el-input-number v-model="weatherDuration" :min="0" :max="10000" size="default" />
              <el-button type="primary" @click="setWeatherWithDuration">
                应用
              </el-button>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card class="settings-card">
          <template #header>
            <span>⏰ 时间控制</span>
          </template>

          <div class="setting-content">
            <div class="time-display">
              <span class="label">当前时间:</span>
              <el-tag type="info" size="large">{{ currentTime }}</el-tag>
            </div>

            <el-divider />

            <div class="time-actions">
              <el-button type="primary" size="large" @click="setTimeOfDay('day')">
                ☀️ 白天
              </el-button>
              <el-button type="info" size="large" @click="setTimeOfDay('night')">
                🌙 夜晚
              </el-button>
              <el-button type="success" size="large" @click="addTime(1000)">
                ➕ 增加时间
              </el-button>
            </div>

            <el-divider />

            <div class="time-custom">
              <el-input v-model="customTime" placeholder="自定义时间 (0-24000)" size="default" style="width: 200px;" />
              <el-button type="warning" @click="setCustomTime">
                设置时间
              </el-button>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import api from '../api'

const currentDifficulty = ref('normal')
const currentGamemode = ref('survival')
const currentTime = ref('0')
const selectedWeather = ref('clear')
const weatherDuration = ref(0)

const difficulties = [
  { value: 'peaceful', label: '🕊️ 和平' },
  { value: 'easy', label: '😊 简单' },
  { value: 'normal', label: '⚔️ 普通' },
  { value: 'hard', label: '💀 困难' }
]

const gamemodes = [
  { value: 'survival', label: '生存' },
  { value: 'creative', label: '创造' },
  { value: 'adventure', label: '冒险' },
  { value: 'spectator', label: '旁观' }
]

const weatherOptions = [
  { value: 'clear', label: '晴天', icon: '☀️' },
  { value: 'rain', label: '雨天', icon: '🌧️' },
  { value: 'thunder', label: '雷暴', icon: '⛈️' }
]

const customTime = ref('')

onMounted(() => {
  loadSettings()
})

const loadSettings = async () => {
  try {
    const [diffResult, modeResult, timeResult] = await Promise.all([
      api.getDifficulty(),
      api.getGamemode(),
      api.getTime()
    ])

    currentDifficulty.value = diffResult.difficulty?.toLowerCase() || 'normal'
    currentGamemode.value = modeResult.defaultGamemode?.toLowerCase() || 'survival'
    currentTime.value = timeResult.time || '0'
  } catch (error) {
    console.error('Failed to load settings:', error)
  }
}

const getDifficultyType = (diff) => {
  const types = {
    peaceful: 'success',
    easy: 'info',
    normal: 'warning',
    hard: 'danger'
  }
  return types[diff] || 'info'
}

const getDifficultyText = (diff) => {
  const texts = {
    peaceful: '和平模式',
    easy: '简单模式',
    normal: '普通模式',
    hard: '困难模式'
  }
  return texts[diff] || diff
}

const getGamemodeText = (mode) => {
  const texts = {
    survival: '生存模式',
    creative: '创造模式',
    adventure: '冒险模式',
    spectator: '旁观模式'
  }
  return texts[mode] || mode
}

const setDifficulty = async (difficulty) => {
  try {
    await api.setDifficulty(difficulty)
    currentDifficulty.value = difficulty
    ElMessage.success(`游戏难度已设置为: ${getDifficultyText(difficulty)}`)
  } catch (error) {
    ElMessage.error(`设置失败: ${error.message}`)
  }
}

const setGamemode = async (mode) => {
  try {
    await api.setGamemode(mode)
    currentGamemode.value = mode
    ElMessage.success(`默认游戏模式已设置为: ${getGamemodeText(mode)}`)
  } catch (error) {
    ElMessage.error(`设置失败: ${error.message}`)
  }
}

const setWeather = async (type) => {
  try {
    await api.setWeather(type)
    selectedWeather.value = type
    ElMessage.success(`天气已设置为: ${weatherOptions.find(w => w.value === type)?.label}`)
  } catch (error) {
    ElMessage.error(`设置失败: ${error.message}`)
  }
}

const setWeatherWithDuration = async () => {
  try {
    await api.setWeather(selectedWeather.value, weatherDuration.value)
    ElMessage.success(`天气已设置为: ${weatherOptions.find(w => w.value === selectedWeather.value)?.label}，持续 ${weatherDuration.value} 秒`)
  } catch (error) {
    ElMessage.error(`设置失败: ${error.message}`)
  }
}

const setTimeOfDay = async (type) => {
  try {
    await api.setTime(0, type)
    const timeValue = type === 'day' ? '1000' : '13000'
    currentTime.value = timeValue
    ElMessage.success(`时间已设置为: ${type === 'day' ? '白天' : '夜晚'}`)
  } catch (error) {
    ElMessage.error(`设置失败: ${error.message}`)
  }
}

const addTime = async (time) => {
  try {
    await api.setTime(time, 'add')
    await refreshTime()
    ElMessage.success(`时间已增加 ${time}`)
  } catch (error) {
    ElMessage.error(`设置失败: ${error.message}`)
  }
}

const setCustomTime = async () => {
  if (!customTime.value) {
    ElMessage.warning('请输入时间值')
    return
  }

  try {
    await api.setTime(parseInt(customTime.value), 'set')
    currentTime.value = customTime.value
    ElMessage.success(`时间已设置为: ${customTime.value}`)
  } catch (error) {
    ElMessage.error(`设置失败: ${error.message}`)
  }
}

const refreshTime = async () => {
  try {
    const result = await api.getTime()
    currentTime.value = result.time || '0'
  } catch (error) {
    console.error('Failed to refresh time:', error)
  }
}
</script>

<style scoped lang="scss">
.game-settings {
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

.setting-content {
  padding: 10px 0;
}

.current-setting {
  display: flex;
  align-items: center;
  gap: 12px;

  .label {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.7);
  }
}

.setting-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.weather-options {
  display: flex;
  gap: 16px;
  margin-bottom: 20px;
}

.weather-item {
  flex: 1;
  padding: 20px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;

  &:hover {
    background: rgba(255, 255, 255, 0.1);
    transform: translateY(-2px);
  }

  &.active {
    border-color: #4CAF50;
    background: rgba(76, 175, 80, 0.1);
  }
}

.weather-icon {
  font-size: 36px;
  margin-bottom: 8px;
}

.weather-label {
  font-size: 14px;
  color: #fff;
}

.weather-duration {
  display: flex;
  align-items: center;
  gap: 12px;

  span {
    color: rgba(255, 255, 255, 0.7);
    font-size: 14px;
  }
}

.time-display {
  display: flex;
  align-items: center;
  gap: 12px;

  .label {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.7);
  }
}

.time-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.time-custom {
  display: flex;
  align-items: center;
  gap: 12px;
}
</style>
