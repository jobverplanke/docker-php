PHP_VERSIONS=(7.4 8.0)
XDEBUG_VERSION=3.0.0
REDIS_VERSION=5.3.2

for version in "${PHP_VERSIONS[@]}"; do
  if [[ ! -e "${version}" ]]; then
    mkdir -p "${version}"
  fi

  cp template.Dockerfile "./${version}/fpm/Dockerfile"
  sed -i '' 's/{{ XDEBUG_VERSION }}/'"${XDEBUG_VERSION}"'/' "${version}/fpm/Dockerfile"
  sed -i '' 's/{{ REDIS_VERSION }}/'"${REDIS_VERSION}"'/' "${version}/fpm/Dockerfile"
done
