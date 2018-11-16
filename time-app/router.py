#!/usr/bin/env python3
#
# A lot of this code is based on one of these two projects:
# https://github.com/kumina/python_container_demo_app
# https://github.com/yurishkuro/opentracing-tutorial/tree/master/python

import os
import sys
import http.server
import prometheus_client
import json
import signal
import threading
import logging
import requests
from jaeger_client import Config
from opentracing.ext import tags
from opentracing.propagation import Format

# This is for Prometheus metrics
REQUEST_LATENCY = prometheus_client.Histogram(
    'router_request_latency_seconds',
    'Time it took to process incoming HTTP requests, in seconds.')
BACKEND_LATENCY = prometheus_client.Histogram(
    'router_backend_latency_seconds',
    'Time spent waiting on backends to respond to requests, in seconds.')


class Router(http.server.BaseHTTPRequestHandler):

    @REQUEST_LATENCY.time()
    def do_GET(s):
        try:
            span_ctx = s.server.tracer.extract(Format.HTTP_HEADERS, dict(s.headers))
        except:
            span_ctx = None
        with s.server.tracer.start_active_span('handle_request', child_of=span_ctx) as scope:
            scope.span.log_kv({'event': 'request-response', 'path': s.path})
            if s.path == '/healthz/live':
                s.liveness_check()
            elif s.path == '/healthz/ready':
                s.readiness_check()
            else:
                s.default_response()

    def get_remote(s, service):
        url = 'http://%s/' % (service)

        span = s.server.tracer.active_span
        span.set_tag(tags.HTTP_METHOD, 'GET')
        span.set_tag(tags.HTTP_URL, url)
        span.set_tag(tags.SPAN_KIND, tags.SPAN_KIND_RPC_CLIENT)
        headers = {}
        tracer.inject(span, Format.HTTP_HEADERS, headers)

        r = requests.get(url, headers=headers)
        assert r.status_code == 200
        return r.text

    def default_response(s):
        with s.server.tracer.start_active_span('prepare_headers') as scope:
            s.send_response(200)
            s.send_header('Content-Type', 'text/html')
            s.end_headers()
        with s.server.tracer.start_active_span('get_backend_data') as scope:
            year = s.get_remote('year')
            scope.span.log_kv({'event': 'get-year', 'year': str(year)})
            month = s.get_remote('month')
            scope.span.log_kv({'event': 'get-month', 'month': str(month)})
            day = s.get_remote('day')
            scope.span.log_kv({'event': 'get-day', 'day': str(day)})
            hour = s.get_remote('hour')
            scope.span.log_kv({'event': 'get-hour', 'hour': str(hour)})
            minute = s.get_remote('minute')
            scope.span.log_kv({'event': 'get-minute', 'minute': str(minute)})
            second = s.get_remote('second')
            scope.span.log_kv({'event': 'get-second', 'second': str(second)})
            cur_date = '%s-%s-%s' % (day, month, year)
            cur_time = '%s:%s:%s' % (hour, minute, second)
            scope.span.log_kv({'event': 'format-timestamps', 'date': cur_date, 'time': cur_time})
        with s.server.tracer.start_active_span('write_response') as scope:
            s.wfile.write(b'''
                <!DOCTYPE html>
                <html>
                    <head>
                        <title>Distributed Time</title>
                    </head>
                    <body>
                        <h1>Distributed Time</h1>
                        <p>The current date is: %s</p>
                        <p>The current time is: %s</p>
                    </body>
                </html>''' % (str.encode(cur_date), str.encode(cur_time)))

    def liveness_check(s):
        with s.server.tracer.start_active_span('liveness_check') as scope:
            s.send_response(200)
            s.send_header('Content-Type', 'text/html')
            s.end_headers()
            s.wfile.write(b'''Ok.''')

    def readiness_check(s):
        with s.server.tracer.start_active_span('readiness_check') as scope:
            scope.span.log_kv({'event': 'check-if-ready', 'ready.var': str(s.server.ready)})
            if s.server.ready:
                s.send_response(200)
                s.send_header('Content-Type', 'text/plain')
                s.end_headers()
                s.wfile.write(b'''Ok.''')
            else:
                # The actual response does not really matter, as long as it's not
                # a HTTP 200 status.
                s.send_response(503)
                s.send_header('Content-Type', 'text/plain')
                s.end_headers()
                s.wfile.write(b'''Not ready yet.''')

    def log_message(self, format, *args):
        with self.server.tracer.start_active_span('log') as scope:
            log = { 'router':
                    {
                        'client_ip': self.address_string(),
                        'timestamp': self.log_date_time_string(),
                        'message': format%args
                    }
                }
            print(json.dumps(log))

if __name__ == '__main__':
    listen_port = int(os.getenv('LISTEN_PORT', 80))
    prom_listen_port = int(os.getenv('PROM_LISTEN_PORT', 8080))
    prometheus_client.start_http_server(prom_listen_port)
    jaeger_agent_host = os.getenv('JAEGER_AGENT_HOST', 'localhost')
    istio = int(os.getenv('ISTIO', 0))

    logging.getLogger('').handlers = []
    logging.basicConfig(format='%(message)s', level=logging.DEBUG)

    # Set up the tracer
    cfg = {
            'sampler': {
                'type': 'const',
                'param': 1,
            },
            'logging': True,
            'local_agent': {
                'reporting_host': jaeger_agent_host,
            },
        }
    if istio > 0:
        cfg['propagation'] = 'b3'
    config = Config(
        config=cfg,
        service_name='router',
        validate=True,
    )

    # this call also sets opentracing.tracer
    tracer = config.initialize_tracer()

    httpd = http.server.HTTPServer(('0.0.0.0', listen_port), Router)
    httpd.ready = True
    httpd.tracer = tracer

    # Simple handler function to show that we we're handling the SIGTERM
    def do_shutdown(signum, frame):
        global httpd

        log = { 'router': { 'message': 'Graceful shutdown.' } }
        print(json.dumps(log))
        threading.Thread(target = httpd.shutdown).start()
        sys.exit(0)

    signal.signal(signal.SIGTERM, do_shutdown)

    # Forever serve requests. Or at least until we receive the proper signal.
    httpd.serve_forever()
