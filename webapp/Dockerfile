FROM docker

# Install python3
RUN apk update
RUN apk add python3 python3-dev build-base linux-headers pcre-dev shadow

# Install dependencies
COPY requirements.txt /
RUN pip3 install --no-cache-dir -r requirements.txt

RUN mkdir /var/www
WORKDIR /var/www

CMD ["uwsgi", "--ini", "/var/www/uwsgi.ini"]
