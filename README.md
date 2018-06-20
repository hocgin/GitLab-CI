## 使用 GitLab CI 构建 Spring Boot 项目
### 搭建 GitLab CE
> 使用 Docker 方式搭建 GitLab CE

```shell
sudo docker run --detach \
    --publish 443:443 \
    --publish 80:80 \
    --publish 2222:22 \
    --name gitlab \
    --restart always \
    --volume /data/gitlab/config:/etc/gitlab \
    --volume /data/gitlab/logs:/var/log/gitlab \
    --volume /data/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
```

### 搭建 GitLab Runner
```shell
sudo docker run --rm -t -d -i -p 8084:8080 \
    -v /data/gitlab-runner:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --add-host ad4aac43c567:172.17.0.2 \
    --name gitlab-runner \
    gitlab/gitlab-runner
```

- 1. 此处需注意`--add-host`请自行替换为GitLab CE Docker 容器 ID，此处是为了让 GitLab CE Docker 容器可以被 GitLab Runner 访问到, 如果使用公网 IP 可以忽略。
- 2. 如果通过`/etc/hosts`仍然无法解决HOST问题, 请自行更改`/data/gitlab-runner/config.toml`文件，在`[runners.docker]`节点下面添加`extra_hosts = ["ad4aac43c567:172.17.0.2"]`。


### 注册 Runner
```shell 
sudo docker exec -it gitlab-runner  gitlab-runner register -n \
      --url http://192.168.1.13/ \
      --registration-token pfHxurfRMBctWwkqrt1c \
      --tag-list=docker-privileged \
      --description "dockersock" \
      --docker-privileged=false \
      --docker-image "docker:latest" \
      --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
      --docker-volumes /root/m2:/root/.m2 \
      --executor docker
```

- url: GitLab CE 里面 CI 栏目查看
- registration-token: GitLab CE 里面 CI 栏目查看
- tag-list: 标签, 后续用于执行步骤时指定 Runner
- description: 描述
- docker-image: 外层使用的 Docker 镜像
- executor: 执行器

### 一键部署
[点击获取](docker-compose.yml), 记得修改HOST。