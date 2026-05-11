const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const { RCON } = require('rcon-client');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CLIENT_URL || 'http://localhost:8080',
    methods: ['GET', 'POST']
  }
});

app.use(cors());
app.use(express.json());

// Serve static files from public directory (built frontend)
const publicPath = path.join(__dirname, '../public');
if (fs.existsSync(publicPath)) {
  app.use(express.static(publicPath));
  
  // SPA fallback: serve index.html for all non-API routes
  app.get('*', (req, res) => {
    if (!req.path.startsWith('/api')) {
      res.sendFile(path.join(publicPath, 'index.html'));
    }
  });
}

const RCON_HOST = process.env.RCON_HOST || '127.0.0.1';
const RCON_PORT = parseInt(process.env.RCON_PORT || '25575');
const RCON_PASSWORD = process.env.RCON_PASSWORD || '';
const JWT_SECRET = process.env.JWT_SECRET || 'mc-admin-secret-key-change-in-production';
const PORT = process.env.PORT || 3000;

let rcon = null;

async function connectRCON() {
  try {
    rcon = new RCON({ host: RCON_HOST, port: RCON_PORT, password: RCON_PASSWORD });
    await rcon.connect();
    console.log('RCON connected successfully');
    return true;
  } catch (error) {
    console.error('RCON connection failed:', error.message);
    return false;
  }
}

async function sendRconCommand(command) {
  if (!rcon) {
    const connected = await connectRCON();
    if (!connected) throw new Error('RCON not connected');
  }
  try {
    const response = await rcon.execute(command);
    return response;
  } catch (error) {
    console.error('RCON command failed:', error.message);
    throw error;
  }
}

let adminUsers = [];
const usersFile = path.join(__dirname, 'users.json');

function loadUsers() {
  try {
    if (fs.existsSync(usersFile)) {
      const data = fs.readFileSync(usersFile, 'utf8');
      adminUsers = JSON.parse(data);
    } else {
      const hashedPassword = bcrypt.hashSync('admin123', 10);
      adminUsers = [{ username: 'admin', password: hashedPassword, role: 'admin' }];
      saveUsers();
    }
  } catch (error) {
    console.error('Failed to load users:', error);
  }
}

function saveUsers() {
  try {
    fs.writeFileSync(usersFile, JSON.stringify(adminUsers, null, 2));
  } catch (error) {
    console.error('Failed to save users:', error);
  }
}

loadUsers();

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
};

app.post('/api/auth/login', async (req, res) => {
  const { username, password } = req.body;
  const user = adminUsers.find(u => u.username === username);

  if (!user || !bcrypt.compareSync(password, user.password)) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  const token = jwt.sign({ username: user.username, role: user.role }, JWT_SECRET, { expiresIn: '24h' });
  res.json({ token, username: user.username, role: user.role });
});

app.post('/api/auth/register', authenticateToken, async (req, res) => {
  const { username, password, role } = req.body;

  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Only admins can create users' });
  }

  if (adminUsers.find(u => u.username === username)) {
    return res.status(400).json({ error: 'Username already exists' });
  }

  const hashedPassword = bcrypt.hashSync(password, 10);
  adminUsers.push({ username, password: hashedPassword, role: role || 'operator' });
  saveUsers();

  res.json({ message: 'User created successfully' });
});

app.get('/api/server/status', authenticateToken, async (req, res) => {
  try {
    const connected = rcon ? true : await connectRCON();
    res.json({ online: connected, host: RCON_HOST, port: RCON_PORT });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/server/info', authenticateToken, async (req, res) => {
  try {
    const list = await sendRconCommand('list');
    const motd = await sendRconCommand('motd');
    const version = await sendRconCommand('version');

    res.json({
      players: list,
      motd: motd,
      version: version
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/players/list', authenticateToken, async (req, res) => {
  try {
    const list = await sendRconCommand('list');
    res.json({ result: list });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/players/op', authenticateToken, async (req, res) => {
  const { player } = req.body;
  if (!player) {
    return res.status(400).json({ error: 'Player name required' });
  }
  try {
    const result = await sendRconCommand(`op ${player}`);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/players/deop', authenticateToken, async (req, res) => {
  const { player } = req.body;
  if (!player) {
    return res.status(400).json({ error: 'Player name required' });
  }
  try {
    const result = await sendRconCommand(`deop ${player}`);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/players/kick', authenticateToken, async (req, res) => {
  const { player, reason } = req.body;
  if (!player) {
    return res.status(400).json({ error: 'Player name required' });
  }
  try {
    const command = reason ? `kick ${player} ${reason}` : `kick ${player}`;
    const result = await sendRconCommand(command);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/players/ban', authenticateToken, async (req, res) => {
  const { player, reason } = req.body;
  if (!player) {
    return res.status(400).json({ error: 'Player name required' });
  }
  try {
    const command = reason ? `ban ${player} ${reason}` : `ban ${player}`;
    const result = await sendRconCommand(command);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/players/pardon', authenticateToken, async (req, res) => {
  const { player } = req.body;
  if (!player) {
    return res.status(400).json({ error: 'Player name required' });
  }
  try {
    const result = await sendRconCommand(`pardon ${player}`);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/players/whitelist-add', authenticateToken, async (req, res) => {
  const { player } = req.body;
  if (!player) {
    return res.status(400).json({ error: 'Player name required' });
  }
  try {
    const result = await sendRconCommand(`whitelist add ${player}`);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/players/whitelist-remove', authenticateToken, async (req, res) => {
  const { player } = req.body;
  if (!player) {
    return res.status(400).json({ error: 'Player name required' });
  }
  try {
    const result = await sendRconCommand(`whitelist remove ${player}`);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/game/difficulty', authenticateToken, async (req, res) => {
  try {
    const difficulty = await sendRconCommand('difficulty');
    res.json({ difficulty });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/game/difficulty', authenticateToken, async (req, res) => {
  const { difficulty } = req.body;
  const validDifficulties = ['peaceful', 'easy', 'normal', 'hard'];
  if (!validDifficulties.includes(difficulty.toLowerCase())) {
    return res.status(400).json({ error: 'Invalid difficulty. Valid: peaceful, easy, normal, hard' });
  }
  try {
    const result = await sendRconCommand(`difficulty ${difficulty.toLowerCase()}`);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/game/gamemode', authenticateToken, async (req, res) => {
  try {
    const defaultGamemode = await sendRconCommand('defaultgamemode');
    res.json({ defaultGamemode });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/game/gamemode', authenticateToken, async (req, res) => {
  const { mode, player } = req.body;
  const validModes = ['survival', 'creative', 'adventure', 'spectator'];
  if (!validModes.includes(mode.toLowerCase())) {
    return res.status(400).json({ error: 'Invalid gamemode. Valid: survival, creative, adventure, spectator' });
  }
  try {
    const command = player ? `gamemode ${mode.toLowerCase()} ${player}` : `defaultgamemode ${mode.toLowerCase()}`;
    const result = await sendRconCommand(command);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/game/weather', authenticateToken, async (req, res) => {
  res.json({ message: 'Use /weather command through console' });
});

app.post('/api/game/weather', authenticateToken, async (req, res) => {
  const { type, duration } = req.body;
  const validTypes = ['clear', 'rain', 'thunder'];
  if (!validTypes.includes(type.toLowerCase())) {
    return res.status(400).json({ error: 'Invalid weather type. Valid: clear, rain, thunder' });
  }
  try {
    const command = duration ? `weather ${type.toLowerCase()} ${duration}` : `weather ${type.toLowerCase()}`;
    const result = await sendRconCommand(command);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/game/time', authenticateToken, async (req, res) => {
  try {
    const time = await sendRconCommand('time query daytime');
    res.json({ time });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/game/time', authenticateToken, async (req, res) => {
  const { time, type } = req.body;
  if (!time) {
    return res.status(400).json({ error: 'Time value required' });
  }
  try {
    const validTypes = ['day', 'night', 'set', 'add'];
    if (type && !validTypes.includes(type.toLowerCase())) {
      return res.status(400).json({ error: 'Invalid time type. Valid: day, night, set, add' });
    }
    const command = type ? `time ${type.toLowerCase()} ${time}` : `time set ${time}`;
    const result = await sendRconCommand(command);
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/world/save-on', authenticateToken, async (req, res) => {
  try {
    const result = await sendRconCommand('save-on');
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/world/save-off', authenticateToken, async (req, res) => {
  try {
    const result = await sendRconCommand('save-off');
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/world/save-all', authenticateToken, async (req, res) => {
  try {
    const result = await sendRconCommand('save-all');
    res.json({ success: true, result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/whitelist/list', authenticateToken, async (req, res) => {
  try {
    const whitelist = await sendRconCommand('whitelist list');
    res.json({ whitelist });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/banlist/list', authenticateToken, async (req, res) => {
  try {
    const banlist = await sendRconCommand('banlist players');
    res.json({ banlist });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

io.on('connection', (socket) => {
  console.log('Client connected');

  const statusInterval = setInterval(async () => {
    try {
      if (rcon) {
        const list = await sendRconCommand('list');
        const tps = await sendRconCommand('tps').catch(() => 'N/A');
        socket.emit('serverStatus', { online: true, players: list, tps });
      } else {
        socket.emit('serverStatus', { online: false });
      }
    } catch (error) {
      socket.emit('serverStatus', { online: false, error: error.message });
    }
  }, 5000);

  socket.on('disconnect', () => {
    console.log('Client disconnected');
    clearInterval(statusInterval);
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

server.listen(PORT, async () => {
  console.log(`Server running on port ${PORT}`);
  await connectRCON();
});
