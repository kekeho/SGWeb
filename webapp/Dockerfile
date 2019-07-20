FROM python:3.7

# Install dependencies
COPY requirements.txt /
RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir /var/www
WORKDIR /var/www

# Create run user
RUN useradd runuser
USER runuser

CMD ["uwsgi", "--ini", "/var/www/uwsgi.ini"]
