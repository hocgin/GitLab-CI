#!/usr/bin/env bash



# Docker 加速
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://c4s9wr50.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

#https://wjqwsp.github.io/2016/11/23/Gitlab-CI-%E4%B8%8E-Docker-%E7%9A%84%E9%85%8D%E7%BD%AE%E4%B8%8E%E6%95%B4%E5%90%88%E6%B5%81%E7%A8%8B/
#https://jiangtj.gitlab.io/2018/04/22/spring-boot-autodeploy-with-gitlab/
#https://my.oschina.net/gudaoxuri/blog/897243   **重点**
#http://www.spring4all.com/article/953
#https://mritd.me/2017/11/28/ci-cd-gitlab-ci/
#https://www.jianshu.com/p/c1effc3179be
#https://docs.gitlab.com/runner/executors/docker.html

# Docker 启动 Gitlab
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


# 后台方式启动 Runners 镜像
docker run --rm -t -d -i -p 8084:8080 \
    -v /data/gitlab-runner:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --add-host ad4aac43c567:172.17.0.2 \
    --name gitlab-runner \
    gitlab/gitlab-runner

# /data/gitlab-runner/config.toml  这边可以处理HOST问题，当配置在/etc/hosts内并不能解决时可使用。
# extra_hosts = ["ad4aac43c567:172.17.0.2"]

# Runners 注册（更改URL和Token）
docker exec -it gitlab-runner  gitlab-runner register -n \
  --url http://192.168.1.13/ \
  --registration-token pfHxurfRMBctWwkqrt1c \
  --tag-list=docker-privileged \
  --description "dockersock" \
  --docker-privileged=false \
  --docker-image "docker:latest" \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
  --docker-volumes /root/m2:/root/.m2 \
  --executor docker

# docker-privileged=false
# #docker-pull-policy="if-not-present"

# host 会使用和主机一样的IP，占用主机端口    [和主机同等地位]
# bridge 由一个docker0充当网桥, 相当于局域网
# Container Docker和Docker之间使用同一个IP, 占用端口    [容器之间同等地位]
# None 自定义

## 查看容器 IP
docker inspect -f='{{.NetworkSettings.IPAddress}}' $(sudo docker ps -a -q)
## 删除所有容器
docker rm -f $(docker ps -a -q)