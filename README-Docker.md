# Pokemon Showdown Docker Setup

This repository has been dockerized for easy deployment and development. The setup includes the Pokemon Showdown server with optional database services (PostgreSQL, MySQL, Redis) and nginx reverse proxy.

## Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+

### Basic Setup

1. **Clone the repository** (if not already done):
   ```bash
   git clone https://github.com/smogon/pokemon-showdown.git
   cd pokemon-showdown
   ```

2. **Copy the environment template**:
   ```bash
   cp env.example .env
   ```

3. **Edit the environment file**:
   ```bash
   # Edit .env file with your preferred settings
   # Make sure to change default passwords for production!
   ```

4. **Start the services**:
   ```bash
   # For production
   docker-compose up -d

   # For development (with live reloading)
   docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
   ```

5. **Access the server**:
   - Pokemon Showdown: http://localhost:8000
   - Database access (development only):
     - PostgreSQL: localhost:5432
     - MySQL: localhost:3306
     - Redis: localhost:6379

## Architecture

The Docker setup consists of:

### Core Services

- **pokemon-showdown**: The main application server
- **postgres**: PostgreSQL database for persistent data
- **mysql**: MySQL database (alternative to PostgreSQL)
- **redis**: Redis for caching and session management

### Optional Services

- **nginx**: Reverse proxy for production (use `--profile production`)

## Configuration

### Environment Variables

All configuration is done through environment variables. Copy `env.example` to `.env` and modify:

```bash
# Basic server configuration
NODE_ENV=production
PS_PORT=8000
PS_BINDADDR=0.0.0.0
PS_WORKERS=1

# Database URLs
DATABASE_URL=postgres://postgres:password@postgres:5432/pokemonshowdown
MYSQL_URL=mysql://root:password@mysql:3306/pokemonshowdown
REDIS_URL=redis://redis:6379

# Security (change these!)
POSTGRES_PASSWORD=your-secure-password
MYSQL_ROOT_PASSWORD=your-secure-password
SECRET_KEY=your-secret-key
```

### Configuration Files

- Mount your custom `config/config.js` to `/app/config/config.js` in the container
- Logs are stored in the `./logs` directory (mounted as volume)
- Data persistence is handled through Docker volumes

## Development

### Development Mode

The `docker-compose.override.yml` file provides development-specific settings:

```bash
# Start in development mode with live reloading
docker-compose up -d

# View logs
docker-compose logs -f pokemon-showdown

# Access container shell
docker-compose exec pokemon-showdown sh
```

### Features in Development Mode

- Source code mounting for live reloading
- Exposed database ports for external access
- Debug mode enabled
- No automatic restarts

## Production Deployment

### With nginx (Recommended)

```bash
# Start with nginx reverse proxy
docker-compose --profile production up -d

# This will start nginx on ports 80 and 443
# Configure SSL certificates in ./nginx/ssl/
```

### Production Checklist

1. **Security**:
   - [ ] Change all default passwords
   - [ ] Configure SSL certificates
   - [ ] Set up proper firewall rules
   - [ ] Use strong secrets

2. **Performance**:
   - [ ] Adjust `PS_WORKERS` based on CPU cores
   - [ ] Configure database connection pooling
   - [ ] Set up log rotation

3. **Monitoring**:
   - [ ] Set up health checks
   - [ ] Configure log aggregation
   - [ ] Monitor resource usage

## Docker Commands

### Common Operations

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart a service
docker-compose restart pokemon-showdown

# View logs
docker-compose logs -f pokemon-showdown

# Update images
docker-compose pull
docker-compose up -d --build

# Clean up
docker-compose down -v --rmi all
```

### Database Management

```bash
# PostgreSQL backup
docker-compose exec postgres pg_dump -U postgres pokemonshowdown > backup.sql

# MySQL backup
docker-compose exec mysql mysqldump -u root -p pokemonshowdown > backup.sql

# Restore database
docker-compose exec -T postgres psql -U postgres pokemonshowdown < backup.sql
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Change ports in `docker-compose.yml` if 8000 is already used
2. **Permission issues**: Ensure the `logs` directory is writable
3. **Database connection errors**: Check if databases are healthy with `docker-compose ps`
4. **Build failures**: Clear Docker cache with `docker system prune`

### Debugging

```bash
# Check service status
docker-compose ps

# Check service logs
docker-compose logs pokemon-showdown

# Access container shell
docker-compose exec pokemon-showdown sh

# Check database connectivity
docker-compose exec pokemon-showdown ping postgres
```

### Performance Issues

- Monitor resource usage: `docker stats`
- Increase memory limits in `docker-compose.yml`
- Optimize database queries and indexes
- Consider using a CDN for static assets

## Security Considerations

- Change all default passwords
- Use Docker secrets for sensitive data
- Regularly update base images
- Configure proper network policies
- Enable SSL/TLS in production
- Set up log monitoring and alerting

## Volumes and Data Persistence

- **postgres-data**: PostgreSQL data
- **mysql-data**: MySQL data  
- **redis-data**: Redis data
- **pokemon-showdown-data**: Application data
- **./logs**: Application logs (host-mounted)
- **./config**: Configuration files (host-mounted)

## Networking

The setup uses a custom bridge network `pokemon-showdown-network` with subnet `172.20.0.0/16` for internal communication between services.

## Support

For issues specific to the Docker setup, check:
1. Docker and Docker Compose versions
2. Available system resources
3. Network port availability
4. Log files for error messages

For Pokemon Showdown specific issues, refer to the main project documentation. 