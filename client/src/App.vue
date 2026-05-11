<template>
  <div id="app" :class="['app-container', { 'light-theme': isLightTheme }]">
    <router-view />
  </div>
</template>

<script setup>
import { ref, onMounted, provide } from 'vue'

const isLightTheme = ref(false)

const toggleTheme = () => {
  isLightTheme.value = !isLightTheme.value
  localStorage.setItem('theme', isLightTheme.value ? 'light' : 'dark')
}

provide('toggleTheme', toggleTheme)
provide('isLightTheme', isLightTheme)

onMounted(() => {
  const savedTheme = localStorage.getItem('theme')
  if (savedTheme === 'light') {
    isLightTheme.value = true
  }
  console.log('MC Admin loaded')
})
</script>

<style lang="scss">
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body {
  width: 100%;
  height: 100%;
}

#app {
  width: 100%;
  height: 100%;
}

.app-container {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  overflow-x: hidden;
  transition: all 0.3s ease;

  &.light-theme {
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  }
}
</style>
