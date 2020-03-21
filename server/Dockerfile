FROM python:3.8


COPY ./requirements.txt /var/www/requirements.txt
WORKDIR /var/www

# Install dependencies
RUN pip install -r requirements.txt

CMD [ "sh", "cmd.sh" ]
