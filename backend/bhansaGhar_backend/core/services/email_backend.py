"""
Custom email backend for development that handles SSL certificate issues.
"""
import ssl
from django.core.mail.backends.smtp import EmailBackend as SMTPEmailBackend


class DevelopmentEmailBackend(SMTPEmailBackend):
    """
    Custom SMTP email backend that disables SSL certificate verification in DEBUG mode.
    """

    def __init__(self, host=None, port=None, username=None, password=None,
                 use_tls=None, fail_silently=False, use_ssl=None,
                 timeout=None, ssl_keyfile=None, ssl_certfile=None,
                 **kwargs):
        super().__init__(host, port, username, password, use_tls, fail_silently, # type: ignore
                        use_ssl, timeout, ssl_keyfile, ssl_certfile, **kwargs)

        # In DEBUG mode, create SSL context that doesn't verify certificates
        if hasattr(self, 'use_ssl') and self.use_ssl:
            self.ssl_context = ssl.create_default_context()
            self.ssl_context.check_hostname = False
            self.ssl_context.verify_mode = ssl.CERT_NONE
        elif hasattr(self, 'use_tls') and self.use_tls:
            self.ssl_context = ssl.create_default_context()
            self.ssl_context.check_hostname = False
            self.ssl_context.verify_mode = ssl.CERT_NONE
