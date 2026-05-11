<template>
  <div class="monitor-page">
    <el-row :gutter="20">
      <el-col :span="8">
        <el-card class="stat-card">
          <template #header>
            <span>📊 在线玩家</span>
          </template>
          <div class="stat-value">{{ currentOnline }}</div>
          <div class="stat-label">当前在线人数</div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="stat-card">
          <template #header>
            <span>⚡ TPS</span>
          </template>
          <div class="stat-value">{{ tps }}</div>
          <div class="stat-label">服务器TPS</div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="stat-card">
          <template #header>
            <span>⏱️ 运行时间</span>
          </template>
          <div class="stat-value">{{ uptime }}</div>
          <div class="stat-label">服务器运行时间</div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="14">
        <el-card class="chart-card">
          <template #header>
            <span>📈 在线人数趋势</span>
          </template>
          <div ref="chartRef" class="chart-container"></div>
        </el-card>
      </el-col>

      <el-col :span="10">
        <el-card class="info-card">
          <template #header>
            <span>📋 服务器状态</span>
          </template>
          <div class="status-grid">
            <div class="status-item">
              <span class="status-label">服务器地址</span>
              <span class="status-value">{{ serverInfo.host }}:{{ serverInfo.port }}</span>
            </div>
            <div class="status-item">
              <span class="status-label">RCON状态</span>
              <el-tag :type="serverOnline ? 'success' : 'danger'">
                {{ serverOnline ? '已连接' : '未连接' }}
              </el-tag>
            </div>
            <div class="status-item">
              <span class="status-label">Minecraft版本</span>
              <span class="status-value">1.12.2</span>
            </div>
            <div class="status-item">
              <span class="status-label">管理面板版本</span>
              <span class="status-value">1.0.0</span>
            </div>
          </div>
        </el-card>

        <el-card class="info-card" style="margin-top: 20px;">
          <template #header>
            <span>👥 最近上线记录</span>
          </template>
          <div class="history-list">
            <div v-for="(record, index) in recentPlayers" :key="index" class="history-item">
              <el-avatar :size="32" style="background: #4CAF50;">
                {{ record.name.charAt(0).toUpperCase() }}
              </el-avatar>
              <div class="history-info">
                <div class="history-name">{{ record.name }}</div>
                <div class="history-time">{{ record.time }}</div>
              </div>
              <el-tag type="success" size="small">上线</el-tag>
            </div>
            <div v-if="recentPlayers.length === 0" class="empty-history">
              暂无上线记录
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>import { ref, onMounted, onUnmounted } from 'vue';
import { io } from 'socket.io-client';
import * as echarts from 'echarts';
import api from '../api';
const currentOnline = ref(0);
const tps = ref('N/A');
const uptime = ref('0:00:00');
const serverOnline = ref(false);
const serverInfo = ref({ host: '127.0.0.1', port: 25575 });
const recentPlayers = ref([]);
const chartRef = ref(null);
let chart = null;
let socket = null;
let uptimeInterval = null;
const startTime = Date.now();
const timeData = ref([]);
const playerData = ref([]);
onMounted(() => {
 socket = io('/', {
 transports: ['websocket', 'polling']
 });
 socket.on('serverStatus', (status) => {
 serverOnline.value = status.online;
 if (status.players) {
 const match = status.players.match(/(\d+)/);
 if (match) {
 currentOnline.value = parseInt(match[1]);
 addToChart();
 }
 }
 if (status.tps) {
 tps.value = status.tps;
 }
 });
 uptimeInterval = setInterval(() => {
 const diff = Date.now() - startTime;
 const hours = Math.floor(diff / 3600000);
 const minutes = Math.floor((diff % 3600000) / 60000);
 const seconds = Math.floor((diff % 60000) / 1000);
 uptime.value = `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
 }, 1000);
 initChart();
 loadServerStatus();
});
onUnmounted(() => {
 if (socket) {
 socket.disconnect();
 }
 if (uptimeInterval) {
 clearInterval(uptimeInterval);
 }
 if (chart) {
 chart.dispose();
 }
});
const initChart = () => {
 if (chartRef.value) {
 chart = echarts.init(chartRef.value);
 updateChart();
 }
};
const addToChart = () => {
 const now = new Date();
 const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
 timeData.value.push(timeStr);
 playerData.value.push(currentOnline.value);
 if (timeData.value.length > 60) {
 timeData.value.shift();
 playerData.value.shift();
 }
 updateChart();
};
const updateChart = () => {
 if (!chart)
 return;
 const option = {
 backgroundColor: 'transparent',
 tooltip: {
 trigger: 'axis',
 backgroundColor: 'rgba(0, 0, 0, 0.7)',
 borderColor: 'rgba(255, 255, 255, 0.1)',
 textStyle: {
 color: '#fff'
 }
 },
 grid: {
 left: '3%',
 right: '4%',
 bottom: '3%',
 top: '10%',
 containLabel: true
 },
 xAxis: {
 type: 'category',
 data: timeData.value,
 axisLine: {
 lineStyle: {
 color: 'rgba(255, 255, 255, 0.3)'
 }
 },
 axisLabel: {
 color: 'rgba(255, 255, 255, 0.6)',
 rotate: 45,
 fontSize: 10
 }
 },
 yAxis: {
 type: 'value',
 min: 0,
 axisLine: {
 lineStyle: {
 color: 'rgba(255, 255, 255, 0.3)'
 }
 },
 axisLabel: {
 color: 'rgba(255, 255, 255, 0.6)'
 },
 splitLine: {
 lineStyle: {
 color: 'rgba(255, 255, 255, 0.1)'
 }
 }
 },
 series: [
 {
 name: '在线人数',
 type: 'line',
 smooth: true,
 data: playerData.value,
 lineStyle: {
 color: '#4CAF50',
 width: 3
 },
 areaStyle: {
 color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
 { offset: 0, color: 'rgba(76, 175, 80, 0.4)' },
 { offset: 1, color: 'rgba(76, 175, 80, 0.05)' }
 ])
 },
 itemStyle: {
 color: '#4CAF50'
 },
 symbol: 'circle',
 symbolSize: 6
 }
 ]
 };
 chart.setOption(option);
};
const loadServerStatus = async () => {
 try {
 const status = await api.getServerStatus();
 serverOnline.value = status.online;
 serverInfo.value = { host: status.host, port: status.port };
 }
 catch (error) {
 console.error('Failed to load server status:', error);
 }
};
</script>

<style scoped lang="scss">
.monitor-page {
  padding: 20px;
}

.stat-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  text-align: center;
  padding: 20px;

  :deep(.el-card__header) {
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    color: #fff;
    font-size: 14px;
    font-weight: 500;
  }
}

.stat-value {
  font-size: 48px;
  font-weight: 700;
  color: #4CAF50;
  margin-top: 16px;
}

.stat-label {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.6);
  margin-top: 8px;
}

.chart-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  height: 400px;

  :deep(.el-card__header) {
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    color: #fff;
    font-size: 16px;
    font-weight: 600;
  }
}

.chart-container {
  width: 100%;
  height: calc(100% - 60px);
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
}

.status-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.status-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);

  &:last-child {
    border-bottom: none;
  }
}

.status-label {
  color: rgba(255, 255, 255, 0.6);
  font-size: 14px;
}

.status-value {
  color: #fff;
  font-size: 14px;
  font-weight: 500;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.history-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
}

.history-info {
  flex: 1;
}

.history-name {
  color: #fff;
  font-size: 14px;
}

.history-time {
  color: rgba(255, 255, 255, 0.5);
  font-size: 12px;
  margin-top: 4px;
}

.empty-history {
  text-align: center;
  color: rgba(255, 255, 255, 0.5);
  padding: 20px;
}
</style>
