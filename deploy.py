import json
import tempfile
import click
import shutil
from pathlib import Path
import os
import logging
import shutil
import re


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


def valid_version_format(ctx, param, value):
    pattern = re.compile("^\d{1,2}\.\d{1,2}(\.\d{1,2})?")
    if re.fullmatch(pattern, value) is None:
        raise click.BadParameter(
            f"Version provided must match pattern of major.minor.micro, where micro is optional. "
            f"Each subversion must be a number between 0 and 99. got <{value}>"
        )
    return value


def inject_version_value(info_file: Path, version: str) -> None:
    with open(info_file, "r") as fh:
        content = json.load(fh)

    content["version"] = version

    with open(info_file, "w") as fh:
        json.dump(content, fh)


def get_package_name(package_dir: Path) -> str:
    with open(package_dir / "info.json") as fh:
        content = json.load(fh)

    return content["name"]


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
        destination = tmpdirname + "/" + folder_name
        shutil.copytree(src=source_directory, dst=destination)
        inject_version_value(destination + "/" + "info.json", version)
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
@click.option(
    "--version",
    "-v",
    help="Version to inject",
    callback=valid_version_format,
    default="0.0.0",
    show_default=True,
)
def deploy(package_dir, target_path, version):
    logger.info("Initiating deploy...")

    package_name = get_package_name(package_dir)
    logger.info(f"Found <{package_name}> version <{version}> - bundling...")

    bundle(package_name, version, package_dir, target_path)

    logger.info("Completed")


if __name__ == "__main__":
    deploy()