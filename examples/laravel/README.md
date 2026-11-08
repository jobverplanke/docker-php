# Laravel example

Example setup for running a Laravel app with the `ghcr.io/jobverplanke/php` images:
one fpm container for web requests behind nginx, and separate containers
(same cli image, different command) for Laravel Horizon (queue workers),
the scheduler and one-off artisan commands.

## Usage

1. Copy `docker-compose.yml` and `docker/nginx.conf` into the root of your
   Laravel project.
2. Set in your Laravel `.env`:

   ```dotenv
   DB_HOST=mysql
   DB_DATABASE=laravel
   DB_USERNAME=laravel
   DB_PASSWORD=secret
   REDIS_HOST=redis
   QUEUE_CONNECTION=redis
   CACHE_STORE=redis
   ```

3. Start the stack and run the migrations:

   ```sh
   docker compose up -d
   docker compose run --rm artisan migrate
   ```

The app is served on <http://localhost:8080>.

## Notes

- The images are production builds: no xdebug, errors not displayed and
  `opcache.validate_timestamps=0`. The app service overrides that last
  setting so edits to the bind-mounted code show up; in production, bake the
  code into an image instead of bind-mounting it and drop the override.
- Horizon supervises its own worker processes: scale by raising
  `maxProcesses` in `config/horizon.php`, not by adding container replicas.
  Keep both the horizon and scheduler services at exactly one replica, and
  size the horizon container's memory to `maxProcesses x memory_limit`.
  The Horizon dashboard is served by the app container at `/horizon`.
