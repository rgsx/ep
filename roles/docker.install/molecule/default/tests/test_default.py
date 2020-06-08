def test_docker_is_installed(host):
    docker = host.package("docker-ce")
    assert docker.is_installed

def test_daemon_file(host):
    daemon = host.file("/etc/docker/daemon.json")
    assert daemon.exists
