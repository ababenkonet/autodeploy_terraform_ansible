#!/bin/bash

# Получение хеша текущего образа
CURRENT_IMAGE_HASH="$(sudo docker inspect --format='{{.Id}}' alexbabenkodunice/posts:latest)"

# Проверка наличия новых образов
sudo docker pull alexbabenkodunice/goods:latest

# Получение хеша последней версии образа
LATEST_IMAGE_HASH="$(sudo docker inspect --format='{{.Id}}' alexbabenkodunice/posts:latest)"

# Если образ обновился, перезапустить контейнеры из docker-compose.yml
if [ "$CURRENT_IMAGE_HASH" != "$LATEST_IMAGE_HASH" ]; then
  sudo docker-compose down
  sudo docker-compose pull
  sudo docker-compose up -d
fi
