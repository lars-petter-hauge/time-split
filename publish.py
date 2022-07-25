import sys
import requests
import click
from pathlib import Path
import logging


MOD_PORTAL_URL = "https://mods.factorio.com"
INIT_UPLOAD_URL = f"{MOD_PORTAL_URL}/api/v2/mods/releases/init_upload"


logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
logger.addHandler(handler)


def valid_package_dir(ctx, param, value):
    path = Path(value)
    if not path.exists():
        raise click.BadParameter(
            f"Package directory must be an existing folder, did not find <{str(path)}>"
        )
    return path


@click.command()
@click.option(
    "--zipfilepath",
    "-z",
    required=True,
    help="Path where the zipped mod directory is located",
    callback=valid_package_dir,
)
@click.option(
    "--api_key",
    "-a",
    required=True,
    help="API-KEY to use when authenticating against the upload server",
)
def publish(zipfilepath, api_key):
    logger.info(f"Preparing publish for the following file: {zipfilepath}")
    request_body = {"mod": "time-split"}

    request_headers = {"Authorization": f"Bearer {api_key}"}

    response = requests.post(
        INIT_UPLOAD_URL, data=request_body, headers=request_headers
    )

    if not response.ok:
        logger.error(f"init_upload failed: {response.text}")
        sys.exit(1)

    upload_url = response.json()["upload_url"]

    with open(zipfilepath, "rb") as f:
        request_body = {"file": f}
        response = requests.post(upload_url, files=request_body)

    if not response.ok:
        logger.error(f"upload failed: {response.text}")
        sys.exit(1)

    logger.info(f"upload successful: {response.text}")


if __name__ == "__main__":
    publish()
