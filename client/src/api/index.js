import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

api.interceptors.response.use(
  response => {
    return response.data
  },
  error => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default {
  login: (data) => api.post('/auth/login', data),
  register: (data) => api.post('/auth/register', data),

  getServerStatus: () => api.get('/server/status'),
  getServerInfo: () => api.get('/server/info'),

  getPlayerList: () => api.post('/players/list'),
  opPlayer: (player) => api.post('/players/op', { player }),
  deopPlayer: (player) => api.post('/players/deop', { player }),
  kickPlayer: (player, reason) => api.post('/players/kick', { player, reason }),
  banPlayer: (player, reason) => api.post('/players/ban', { player, reason }),
  pardonPlayer: (player) => api.post('/players/pardon', { player }),
  whitelistAdd: (player) => api.post('/players/whitelist-add', { player }),
  whitelistRemove: (player) => api.post('/players/whitelist-remove', { player }),

  getDifficulty: () => api.get('/game/difficulty'),
  setDifficulty: (difficulty) => api.post('/game/difficulty', { difficulty }),
  getGamemode: () => api.get('/game/gamemode'),
  setGamemode: (mode, player) => api.post('/game/gamemode', { mode, player }),
  setWeather: (type, duration) => api.post('/game/weather', { type, duration }),
  getTime: () => api.get('/game/time'),
  setTime: (time, type) => api.post('/game/time', { time, type }),

  saveOn: () => api.post('/world/save-on'),
  saveOff: () => api.post('/world/save-off'),
  saveAll: () => api.post('/world/save-all'),

  getWhitelist: () => api.get('/whitelist/list'),
  getBanlist: () => api.get('/banlist/list'),

  sendCommand: (command) => api.post('/command/execute', { command })
}
