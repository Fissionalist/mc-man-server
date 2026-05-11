import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import MainLayout from '../views/MainLayout.vue'
import Dashboard from '../views/Dashboard.vue'
import Players from '../views/Players.vue'
import GameSettings from '../views/GameSettings.vue'
import WorldManagement from '../views/WorldManagement.vue'
import SystemSettings from '../views/SystemSettings.vue'
import CommandConsole from '../views/CommandConsole.vue'
import Monitor from '../views/Monitor.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { requiresAuth: false }
  },
  {
    path: '/',
    component: MainLayout,
    redirect: '/dashboard',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: Dashboard
      },
      {
        path: 'players',
        name: 'Players',
        component: Players
      },
      {
        path: 'gamesettings',
        name: 'GameSettings',
        component: GameSettings
      },
      {
        path: 'world',
        name: 'WorldManagement',
        component: WorldManagement
      },
      {
        path: 'system',
        name: 'SystemSettings',
        component: SystemSettings
      },
      {
        path: 'console',
        name: 'CommandConsole',
        component: CommandConsole
      },
      {
        path: 'monitor',
        name: 'Monitor',
        component: Monitor
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')

  if (to.meta.requiresAuth !== false && !token) {
    next('/login')
  } else if (to.path === '/login' && token) {
    next('/dashboard')
  } else {
    next()
  }
})

export default router
