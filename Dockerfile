FROM python:3.12.0rc2-alpine
LABEL designer="AJC-groupe2"
RUN pip install flask
VOLUME /data
COPY . /data
EXPOSE 80
CMD [ "python", "./data/app.py" ]
