import scrapy
import json


class FastAPItesting(scrapy.Spider):
    name = "api_auth_test"
    start_urls = [
        "http://127.0.0.1:8000/users/register",
        "http://127.0.0.1:8000/users/login",
    ]

    def __init__(self, username=None, email=None, password=None, *args, **kwargs):
        super(FastAPItesting, self).__init__(*args, **kwargs)
        self.username = username
        self.email = email
        self.password = password

    def start_requests(self):

        yield scrapy.Request(
            url=self.start_urls[0],
            method="POST",
            headers={"Content-Type": "application/json"},
            body=json.dumps(
                {
                    "username": self.username,
                    "email": self.email,
                    "password": self.password,
                }
            ),
            callback=self.parse_register,
        )

    def parse_register(self, response):

        if response.status in [200, 201]:
            self.logger.info(f"registration success : {response.text}")
        else:
            self.logger.error(f"something gone wrong : {response.text}")

        yield scrapy.Request(
            url=self.start_urls[1],
            method="POST",
            headers={"Content-Type": "application/json"},
            body=json.dumps(
                {
                    "username": self.username,
                    "password": self.password,
                }
            ),
            callback=self.parse_login,
        )

    def parse_login(self, response):
        if response.status in [200, 201]:
            self.logger.info(f"Login Success : {response.text}")
        else:
            self.logger.error(f"something wrong : {response.text}")

    #

    #

    #
