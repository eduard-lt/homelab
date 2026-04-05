# Tunnel Container - DISABLED

## Issue
The SideJITServer tunnel container was constantly restarting due to missing Python dependency:
```
ModuleNotFoundError: No module named 'ipsw_parser.img4'
```

## Action Taken
- Container stopped and restart policy disabled (2026-04-05)
- Container preserved but not running

## To Fix (if needed)
1. Rebuild the image with missing dependencies:
   ```bash
   docker exec -it tunnel pip install ipsw-parser
   ```
2. Or rebuild from source with updated dependencies
3. Re-enable restart: `docker update --restart=unless-stopped tunnel`

## To Remove (if not needed)
```bash
docker rm tunnel
docker rmi sidejitserver-142-tunnel:latest
```
