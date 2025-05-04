import subprocess

def setup_project_root():
    subprocess.run(["pip", "install", "-e", "."], check=True)
