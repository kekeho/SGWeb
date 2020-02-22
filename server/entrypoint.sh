python3 manage.py makemigrations
python3 manage.py migrate

uwsgi --socket :3031 --module server.wsgi
