# Discord Bot Setup

This bot provides interactive commands for managing your homelab through Discord with buttons and slash commands!

## Features

### Slash Commands
- `/status` - Show all service statuses grouped by category
- `/restart <service>` - Restart a specific service
- `/resources` - Display system resource usage (CPU, RAM, Disk)
- `/services` - Interactive button-based service viewer

### Interactive Buttons
- 📺 Media - View all media service statuses
- 📊 Monitoring - View monitoring service statuses

## Setup Instructions

### 1. Create Discord Bot Application

1. Go to https://discord.com/developers/applications
2. Click "New Application"
3. Give it a name (e.g., "Homelab Manager")
4. Go to "Bot" section
5. Click "Add Bot"
6. **Save the Token** (you'll need this!)

### 2. Configure Bot Permissions

Under "Bot" section:
- Enable "MESSAGE CONTENT INTENT"
- Enable "SERVER MEMBERS INTENT"

### 3. Generate Invite Link

1. Go to "OAuth2" → "URL Generator"
2. Select scopes:
   - ✅ `bot`
   - ✅ `applications.commands`
3. Select bot permissions:
   - ✅ Send Messages
   - ✅ Embed Links
   - ✅ Read Message History
4. Copy the generated URL and open it to invite bot to your server

### 4. Configure Bot Token

```bash
cd ~/homelab/services/discord-bot
cp .env.template .env
nano .env
# Add your bot token: DISCORD_BOT_TOKEN=your_token_here
```

### 5. Deploy Bot

```bash
cd ~/homelab/services/discord-bot
docker-compose build
docker-compose up -d
```

### 6. Verify Bot is Running

```bash
docker logs discord-bot
# Should see: "✅ <BotName> is connected to Discord!"
# Should see: "✅ Slash commands synced!"
```

## Usage Examples

In Discord, use slash commands:

```
/status          - See all services
/services        - Interactive button menu
/resources       - System resources
/restart sonarr  - Restart Sonarr
```

## Troubleshooting

**Bot doesn't appear online:**
- Check token is correct in .env
- Check bot logs: `docker logs discord-bot`

**Slash commands not working:**
- Wait a few minutes after first deployment
- Kick and re-invite bot
- Check bot has proper permissions

**Can't restart services:**
- Bot needs access to Docker socket (already configured)
- Check container name matches exactly

## Security Notes

- Bot token is sensitive - never share it
- .env file is gitignored for security
- Bot only has read access to Docker socket
- Consider running bot in isolated network

