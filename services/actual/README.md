# Actual Budget

Personal finance and budgeting application.

## Access
- URL: http://your-server:5006
- Auth: Configured on first use

## Data Location
- Local: `./data` (relative to this directory)
- Container: `/data`
- Original: `/home/eduard/actual/actual-data` (migrate from here)

## Migration from Old Setup

If you have existing Actual Budget data:
```bash
# Copy old data to new location
cp -r /home/eduard/actual/actual-data/* /home/eduard/homelab/services/actual/data/
```

## Deployment

```bash
cd /home/eduard/homelab/services/actual
docker-compose up -d
docker logs -f actual-budget
```

## Documentation
- Official: https://actualbudget.github.io/docs/
- Configuration: https://actualbudget.github.io/docs/Installing/Configuration
