#!/usr/bin/env python3
"""
Homelab Discord Bot - Interactive commands with buttons
Requires: discord.py, docker
"""
import discord
from discord.ext import commands
from discord import app_commands
import docker
import os
import asyncio

# Bot setup
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='!', intents=intents)
docker_client = docker.from_env()

@bot.event
async def on_ready():
    print(f'✅ {bot.user} is connected to Discord!')
    await bot.tree.sync()
    print('✅ Slash commands synced!')

# Slash command: /status
@bot.tree.command(name="status", description="Show homelab service status")
async def status(interaction: discord.Interaction):
    try:
        containers = docker_client.containers.list()
        
        embed = discord.Embed(
            title="🏠 Homelab Status",
            color=discord.Color.green()
        )
        
        # Group by type
        media = []
        monitoring = []
        other = []
        
        for container in containers:
            name = container.name
            status = container.status
            emoji = "✅" if status == "running" else "❌"
            
            if name in ['sonarr', 'radarr', 'prowlarr', 'lidarr', 'readarr', 'overseerr', 'tautulli', 'qbittorrent', 'plex']:
                media.append(f"{emoji} {name}")
            elif name in ['grafana', 'netdata']:
                monitoring.append(f"{emoji} {name}")
            else:
                other.append(f"{emoji} {name}")
        
        if media:
            embed.add_field(name="📺 Media Services", value="\n".join(media), inline=False)
        if monitoring:
            embed.add_field(name="📊 Monitoring", value="\n".join(monitoring), inline=False)
        if other:
            embed.add_field(name="🔧 Other", value="\n".join(other[:10]), inline=False)
        
        await interaction.response.send_message(embed=embed)
    except Exception as e:
        await interaction.response.send_message(f"❌ Error: {str(e)}", ephemeral=True)

# Slash command: /restart
@bot.tree.command(name="restart", description="Restart a service")
@app_commands.describe(service="Service name to restart")
async def restart(interaction: discord.Interaction, service: str):
    try:
        await interaction.response.defer()
        
        container = docker_client.containers.get(service)
        container.restart()
        
        embed = discord.Embed(
            title="🔄 Service Restarted",
            description=f"Successfully restarted **{service}**",
            color=discord.Color.blue()
        )
        await interaction.followup.send(embed=embed)
    except docker.errors.NotFound:
        await interaction.followup.send(f"❌ Service '{service}' not found", ephemeral=True)
    except Exception as e:
        await interaction.followup.send(f"❌ Error: {str(e)}", ephemeral=True)

# Slash command: /resources
@bot.tree.command(name="resources", description="Show system resource usage")
async def resources(interaction: discord.Interaction):
    try:
        import psutil
        
        cpu = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        embed = discord.Embed(
            title="💻 System Resources",
            color=discord.Color.blue()
        )
        
        embed.add_field(
            name="🔥 CPU Usage",
            value=f"{cpu}%",
            inline=True
        )
        embed.add_field(
            name="🧠 Memory",
            value=f"{memory.percent}% ({memory.used // (1024**3)}GB / {memory.total // (1024**3)}GB)",
            inline=True
        )
        embed.add_field(
            name="💾 Disk",
            value=f"{disk.percent}% ({disk.used // (1024**3)}GB / {disk.total // (1024**3)}GB)",
            inline=True
        )
        
        await interaction.response.send_message(embed=embed)
    except Exception as e:
        await interaction.response.send_message(f"❌ Error: {str(e)}", ephemeral=True)

# Slash command: /services - Interactive buttons
class ServiceButtons(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=60)
    
    @discord.ui.button(label="📺 Media", style=discord.ButtonStyle.primary)
    async def media(self, interaction: discord.Interaction, button: discord.ui.Button):
        services = ['sonarr', 'radarr', 'prowlarr', 'lidarr', 'readarr', 'overseerr', 'tautulli', 'qbittorrent']
        status_list = []
        for service in services:
            try:
                container = docker_client.containers.get(service)
                emoji = "✅" if container.status == "running" else "❌"
                status_list.append(f"{emoji} {service}")
            except:
                status_list.append(f"❓ {service}")
        
        embed = discord.Embed(title="📺 Media Services", description="\n".join(status_list), color=discord.Color.blue())
        await interaction.response.send_message(embed=embed, ephemeral=True)
    
    @discord.ui.button(label="📊 Monitoring", style=discord.ButtonStyle.secondary)
    async def monitoring(self, interaction: discord.Interaction, button: discord.ui.Button):
        services = ['grafana', 'netdata']
        status_list = []
        for service in services:
            try:
                container = docker_client.containers.get(service)
                emoji = "✅" if container.status == "running" else "❌"
                status_list.append(f"{emoji} {service}")
            except:
                status_list.append(f"❓ {service}")
        
        embed = discord.Embed(title="📊 Monitoring Services", description="\n".join(status_list), color=discord.Color.green())
        await interaction.response.send_message(embed=embed, ephemeral=True)

@bot.tree.command(name="services", description="Interactive service management")
async def services(interaction: discord.Interaction):
    view = ServiceButtons()
    embed = discord.Embed(
        title="🏠 Homelab Services",
        description="Click a button to view service groups",
        color=discord.Color.blue()
    )
    await interaction.response.send_message(embed=embed, view=view)

# Run bot
TOKEN = os.getenv('DISCORD_BOT_TOKEN')
if not TOKEN:
    print("❌ Error: DISCORD_BOT_TOKEN environment variable not set!")
    print("Create a bot at: https://discord.com/developers/applications")
    exit(1)

bot.run(TOKEN)
