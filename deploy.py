import json
import tempfile
import click
import shutil
from pathlib import Path
import os
import logging
import shutil


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
    if not any([str(abspath).endswith("info.json") for abspath in path.iterdir()]):
        raise click.BadParameter(
            f"Package directory <{str(path)}> must contain an info.json file"
        )
    return path


def valid_target_path(ctx, param, value):
    path = Path(value)
    if not path.exists():
        raise click.BadParameter(
            f"Target directory must be an existing folder, did not find <{str(path)}>"
        )
    if not os.access(path, os.W_OK):
        raise click.BadParameter(
            f"Must have write access to target folder <{str(path)}>"
        )
    return path


def package_info(package_dir: Path) -> str:
    with open(package_dir / "info.json") as fh:
        content = json.load(fh)

    return content["name"], content["version"]


def bundle(
    package_name: str,
    version: str,
    source_directory: Path,
    target_path: Path,
) -> None:
    folder_name = package_name + "_" + version
    write_path = target_path / folder_name

    logger.info(f"Writing <{folder_name}> to <{target_path.absolute()}>")
    with tempfile.TemporaryDirectory() as tmpdirname:
        shutil.copytree(src=source_directory, dst=tmpdirname + "/" + folder_name)
        shutil.make_archive(write_path, "zip", tmpdirname)


@click.command()
@click.option(
    "--package_dir",
    "-p",
    required=True,
    help="Source directory for the package to be deployed",
    callback=valid_package_dir,
)
@click.option(
    "--target_path", "-t", required=True, help="Target path", callback=valid_target_path
)
def deploy(package_dir, target_path):
    logger.info("Initiating deploy...")

    package_name, version = package_info(package_dir)
    logger.info(f"Found <{package_name}> version <{version}> - bundling...")

    bundle(package_name, version, package_dir, target_path)

    logger.info("Completed")


if __name__ == "__main__":
    deploy()