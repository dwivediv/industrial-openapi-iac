# LocalStack Management Commands

Quick reference guide for managing LocalStack container.

## Quick Commands (Using Makefile)

### Start LocalStack
```bash
make localstack-start
```
Starts LocalStack container and waits for services to be ready. Also sets up S3 backend for Terraform state.

### Stop LocalStack
```bash
make localstack-stop
```
Stops and removes LocalStack container. **Note**: This does not remove data volumes.

### View Logs
```bash
make localstack-logs
```
Shows LocalStack container logs in real-time (follow mode).

### Check Health
```bash
make localstack-health
```
Checks LocalStack health status and shows available services.

---

## Docker Compose Commands

### Start LocalStack
```bash
# Start in detached mode (background)
docker-compose up -d localstack

# Start and view logs
docker-compose up localstack
```

### Stop LocalStack
```bash
# Stop container (keeps data)
docker-compose stop localstack

# Stop and remove container (keeps volumes)
docker-compose down

# Stop and remove container + volumes (removes data)
docker-compose down -v
```

### Restart LocalStack
```bash
# Restart container
docker-compose restart localstack

# Stop and start fresh
docker-compose down && docker-compose up -d localstack
```

### View Status
```bash
# Check if running
docker-compose ps

# View logs
docker-compose logs localstack

# Follow logs (real-time)
docker-compose logs -f localstack

# View last 100 lines
docker-compose logs --tail=100 localstack
```

---

## Docker Commands (Direct)

### Start LocalStack
```bash
# Start existing container
docker start localstack

# Or run directly
docker run -d \
  --name localstack \
  -p 4566:4566 \
  -e SERVICES=s3,dynamodb,ec2,ecs,lambda,apigateway,iam,sts \
  -v /var/run/docker.sock:/var/run/docker.sock \
  localstack/localstack:latest
```

### Stop LocalStack
```bash
# Stop container (keeps data)
docker stop localstack

# Stop and remove container
docker stop localstack && docker rm localstack
```

### Restart LocalStack
```bash
# Restart container
docker restart localstack
```

### Pause/Unpause LocalStack
```bash
# Pause container (suspends all processes)
docker pause localstack

# Unpause container (resumes processes)
docker unpause localstack
```

### View Status
```bash
# Check container status
docker ps -a | grep localstack

# View logs
docker logs localstack

# Follow logs (real-time)
docker logs -f localstack

# View last 100 lines
docker logs --tail=100 localstack
```

---

## Service Health Check

### Check LocalStack Health
```bash
# Using curl
curl http://localhost:4566/_localstack/health

# Pretty print with jq
curl -s http://localhost:4566/_localstack/health | jq '.'

# Using AWS CLI
aws --endpoint-url=http://localhost:4566 s3 ls
```

### Expected Response
```json
{
  "services": {
    "s3": "available",
    "dynamodb": "available",
    "ec2": "available",
    ...
  }
}
```

---

## Data Management

### View LocalStack Data
```bash
# Data is stored in localstack-data/ directory
ls -la localstack-data/
```

### Backup LocalStack Data
```bash
# Create backup of data directory
tar -czf localstack-backup-$(date +%Y%m%d).tar.gz localstack-data/
```

### Clear LocalStack Data
```bash
# Stop LocalStack first
docker-compose down

# Remove data directory
rm -rf localstack-data/

# Start fresh
docker-compose up -d localstack
```

### Persistent Storage
Data persists in `localstack-data/` directory even after stopping container. To remove all data:

```bash
docker-compose down -v  # Removes volumes
rm -rf localstack-data/
```

---

## Troubleshooting

### Container Won't Start
```bash
# Check if port 4566 is already in use
lsof -i :4566

# Kill process using port
kill -9 $(lsof -t -i:4566)

# Start LocalStack again
docker-compose up -d localstack
```

### Container Keeps Restarting
```bash
# View logs to identify issue
docker-compose logs localstack

# Check Docker daemon
docker info

# Try removing and recreating
docker-compose down -v
docker-compose up -d localstack
```

### Services Not Available
```bash
# Wait for services to be ready
timeout 60 bash -c 'until curl -s http://localhost:4566/_localstack/health | grep -q "\"s3\": \"available\""; do sleep 2; done'

# Check service-specific logs
docker logs localstack | grep -i "s3\|dynamodb"
```

### Reset Everything
```bash
# Stop and remove everything
docker-compose down -v
rm -rf localstack-data/ moto-data/

# Start fresh
docker-compose up -d localstack

# Wait for services
sleep 10

# Verify
curl http://localhost:4566/_localstack/health | jq '.'
```

---

## Quick Reference Table

| Action | Makefile | Docker Compose | Docker Direct |
|--------|----------|----------------|---------------|
| **Start** | `make localstack-start` | `docker-compose up -d localstack` | `docker start localstack` |
| **Stop** | `make localstack-stop` | `docker-compose stop localstack` | `docker stop localstack` |
| **Restart** | `make localstack-stop && make localstack-start` | `docker-compose restart localstack` | `docker restart localstack` |
| **Pause** | ❌ | ❌ | `docker pause localstack` |
| **Unpause** | ❌ | ❌ | `docker unpause localstack` |
| **View Logs** | `make localstack-logs` | `docker-compose logs -f localstack` | `docker logs -f localstack` |
| **Health Check** | `make localstack-health` | `curl http://localhost:4566/_localstack/health` | `curl http://localhost:4566/_localstack/health` |
| **Remove** | ❌ | `docker-compose down` | `docker rm localstack` |
| **Remove + Data** | ❌ | `docker-compose down -v` | `docker rm -v localstack` |

---

## Common Workflows

### Start Fresh Session
```bash
# Start LocalStack
make localstack-start

# Wait for it to be ready (automated in make command)
# Verify it's running
make localstack-health
```

### Stop for Break
```bash
# Stop LocalStack (data persists)
make localstack-stop

# Or pause to keep in memory
docker pause localstack
```

### Resume After Break
```bash
# Resume paused container
docker unpause localstack

# Or restart stopped container
make localstack-start
```

### Clean Restart
```bash
# Stop and remove container
make localstack-stop

# Remove data (optional)
rm -rf localstack-data/

# Start fresh
make localstack-start
```

### Debug Issues
```bash
# View logs
make localstack-logs

# Check health
make localstack-health

# Inspect container
docker inspect localstack

# Enter container shell
docker exec -it localstack bash
```

---

## Tips

1. **Use Makefile**: Simplest way to manage LocalStack
2. **Check Health**: Always verify services are available before using
3. **View Logs**: Check logs if something isn't working
4. **Persistent Data**: Data persists in `localstack-data/` directory
5. **Clean Start**: Remove data directory for fresh start
6. **Port Conflicts**: Check if port 4566 is in use if container won't start

---

## Additional Resources

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Makefile Documentation](./Makefile)

