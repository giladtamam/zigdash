# TEST ONLY: a self-signed certificate and its key

`test_only_cert.pem` and `test_only_key.pem` exist only for
`test/mqtt/tls_round_trip_test.dart`, which serves them on localhost to check
that ZigDash refuses a certificate the phone doesn't trust. They protect
nothing, are not secret, and must never be used anywhere else.

Made 2026-11-21, valid 50 years so the test never trips on expiry:

    openssl req -x509 -newkey rsa:2048 -nodes -days 18262 \
      -subj "/CN=zigdash-test-only.invalid" \
      -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" \
      -keyout test_only_key.pem -out test_only_cert.pem
