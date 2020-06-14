FROM python:3.7

COPY ./requirements.txt /code/requirements.txt
WORKDIR /code

RUN pip install -r requirements.txt

COPY ./ /code

EXPOSE 8000

CMD [ "python", "main.py" ]
