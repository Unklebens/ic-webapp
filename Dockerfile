FROM python:3.6-alpine
LABEL designer="AJC-groupe2"
RUN pip install flask==1.1.2 flask_httpauth==4.1.0 python-dotenv==0.14.0
VOLUME /data
COPY . /data
EXPOSE 80
CMD [ "python", "./data/app.py" ]
