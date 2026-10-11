"""Stands in for the edge check: GET /jobsearch/* with the valid key gets a file; all else gets 403."""

import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT, VALID, LOG = int(sys.argv[1]), sys.argv[2], sys.argv[3]
REDIRECT = sys.argv[4] if len(sys.argv) > 4 else ""
BODY = b"PK\x03\x04 test file"


class Handler(BaseHTTPRequestHandler):
    def answer(self, send_body):
        key = self.headers.get("X-Jobsearch-Key")
        ok = (
            self.command == "GET"
            and self.path.startswith("/jobsearch/")
            and key == VALID
        )
        with open(LOG, "a", encoding="utf-8") as log:
            log.write(
                f"{self.command} {self.path} {'valid' if key == VALID else 'refused'}\n"
            )
        if ok and REDIRECT and "redirect" in self.path:  # a redirect to another host
            self.send_response(302)
            self.send_header("Location", REDIRECT)
            self.send_header("Content-Length", "0")
            self.end_headers()
            return
        status = (500 if "broken" in self.path else 200) if ok else 403
        payload = BODY if status == 200 else b"Error"
        self.send_response(status)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        if send_body:
            self.wfile.write(payload)

    def do_GET(self):
        self.answer(True)

    def do_HEAD(self):
        self.answer(False)

    def log_message(self, *args):
        pass


HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
