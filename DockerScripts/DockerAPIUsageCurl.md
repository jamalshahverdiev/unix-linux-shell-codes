### Readme file shows us how to use Docker API with curl

#### Get some images:
```bash
$ curl --unix-socket /var/run/docker.sock -X POST "http:/v1.24/images/create?fromImage=alpine"
$ curl --unix-socket /var/run/docker.sock -X POST "http:/v1.24/images/create?fromImage=nginx"
$ curl --unix-socket /var/run/docker.sock -X POST "http:/v1.24/images/create?fromImage=phpdockerio/php7-fpm"
```

#### List all images:
```bash
$ curl -s --unix-socket /var/run/docker.sock -X GET http:/v1.24/images/json?all=0 | jq -r .[].RepoTags
[
  "phpdockerio/php7-fpm:latest"
]
[
  "alpine:latest"
]
[
  "nginx:latest"
]
```

#### Create and start container (it wil create 2 containers with **web** and **phpfpm**):
```bash
$ containerId=$(curl -s --unix-socket /var/run/docker.sock -H "Content-Type: application/json" -d '{"Image": "nginx", "PortBindings": { "80/tcp": [{ "HostPort": "8080" }] }}' -X POST http:/v1.24/containers/create?name=web | jq -r .Id)
$ curl -s --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/$containerId/start 
$ containerId=$(curl -s --unix-socket /var/run/docker.sock -H "Content-Type: application/json" -d '{"Image": "phpdockerio/php7-fpm", "PortBindings": { "9000/tcp": [{ "HostPort": "9090" }] }}' -X POST http:/v1.24/containers/create?name=phpfpm | jq -r .Id)
$ curl -s --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/$containerId/start
```

#### List all running containers:
```bash
$ curl -s --unix-socket /var/run/docker.sock http:/v1.24/containers/json | jq -r .[].Names
[
  "/phpfpm"
]
[
  "/web"
]
```

#### List all running processes inside of container:
```bash
$ curl -s --unix-socket /var/run/docker.sock http:/v1.24/containers/$containerId/top | jq
```

#### Get last 10 line of logs for the selected container:
```bash
$ curl -s --unix-socket /var/run/docker.sock "http:/v1.24/containers/$containerId/logs??stderr=1&stdout=1&timestamps=1&follow=1&tail=10"
T2019-09-08T16:29:10.112165006Z [08-Sep-2019 16:29:10] NOTICE: fpm is running, pid 8
Z2019-09-08T16:29:10.112286248Z [08-Sep-2019 16:29:10] NOTICE: ready to handle connections
f2019-09-08T16:29:10.112296933Z [08-Sep-2019 16:29:10] NOTICE: systemd monitor interval set to 10000ms
```

#### Stop container with the selected ID:
```bash
$ curl -s --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/$containerId/stop
```

#### Kill selected container:
```bash
$ curl -s --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/2af1bc644e3f/kill
```

#### Rename container to new name **ngweb**:
```bash
$ curl -s --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/2af1bc644e3f/rename?name=ngweb
```

#### Remove container with selected ID:
```bash
$ curl -s --unix-socket /var/run/docker.sock -X DELETE http:/v1.24/containers/2af1bc644e3f?v1
```
