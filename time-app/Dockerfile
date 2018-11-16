FROM python:3.6

ENV PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt /app
RUN pip install -r requirements.txt
COPY router.py /app
COPY year.py /app
COPY month.py /app
COPY day.py /app
COPY hour.py /app
COPY minute.py /app
COPY second.py /app
