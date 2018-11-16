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
from jaeger_client import Config
import datetime
import time
from opentracing.ext import tags
from opentracing.propagation import Format

# This is for Prometheus metrics
REQUEST_LATENCY = prometheus_client.Histogram(
    'router_request_latency_seconds',
    'Time it took to process incoming HTTP requests, in seconds.')


class Day(http.server.BaseHTTPRequestHandler):

    @REQUEST_LATENCY.time()
    def do_GET(s):
        try:
            span_ctx = s.server.tracer.extract(Format.HTTP_HEADERS, s.headers)
            span_tags = {tags.SPAN_KIND: tags.SPAN_KIND_RPC_SERVER}
        except:
            # We're probably getting liveness/readiness checks
            span_ctx = None
            span_tags = None
        with s.server.tracer.start_active_span('handle_request', child_of=span_ctx, tags=span_tags) as scope:
            scope.span.log_kv({'event': 'request-response', 'path': s.path})
            if s.path == '/healthz/live':
                s.liveness_check()
            elif s.path == '/healthz/ready':
                s.readiness_check()
            else:
                s.default_response()

    def default_response(s):
        with s.server.tracer.start_active_span('default_response') as scope:
            now = None
            now = datetime.datetime.now()
            s.send_response(200)
            s.send_header('Content-Type', 'text/plain')
            s.end_headers()
            time.sleep(0.1)
        with s.server.tracer.start_active_span('format_response') as scope:
            scope.span.log_kv({'event': 'format-response', 'day': str(now.day)})
            s.wfile.write(str.encode(str(now.day)))

    def liveness_check(s):
        with s.server.tracer.start_active_span('liveness_check') as scope:
            s.send_response(200)
            s.send_header('Content-Type', 'text/html')
            s.end_headers()
            s.wfile.write(b'''Ok.''')

    def readiness_check(s):
        with s.server.tracer.start_active_span('readiness_check') as scope:
            s.send_response(200)
            s.send_header('Content-Type', 'text/plain')
            s.end_headers()
            s.wfile.write(b'''Ok.''')

    def log_message(self, format, *args):
        with self.server.tracer.start_active_span('log') as scope:
            log = { 'day':
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

    # Set up the tracer
    config = Config(
        config={
            'sampler': {
                'type': 'const',
                'param': 1,
            },
            'logging': True,
            'local_agent': {
                'reporting_host': jaeger_agent_host,
            },
        },
        service_name='day',
    )

    # this call also sets opentracing.tracer
    tracer = config.initialize_tracer()

    httpd = http.server.HTTPServer(('0.0.0.0', listen_port), Day)
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
