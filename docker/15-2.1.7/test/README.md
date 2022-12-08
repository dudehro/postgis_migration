# container starten, shell öffnen

docker-compose up -d
docker exec -it postgis217 bash

# kompilieren

Hostvzerzeichnis ../build/source/postgis ist als /download/postgis-2.1.7 in Container gemountet

cd /download/postgis-2.1.7
./configure
make

Ich habe bereits 2 Anpassungen vorgenommen, zu finden mit
/download/postgis-2.1.7# grep -rl "gkae" *
