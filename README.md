# git-clone-container

[![Travis (.org)](https://img.shields.io/travis/wilmardo/ansible-role-oscam.svg?style=flat-square)](https://travis-ci.org/wilmardo/ansible-role-oscam)

Minimal Git CLI container build from scratch. 
I use this as init container on Kubernetes.

The container is optimized with [UPX](https://github.com/upx/upx) and only contains the binaries needed for a git clone 
from HTTP or HTTPS, **NO SSH SUPPORT**. This is a personal choice, if needed I can add it :)

### Usage
```bash
docker run -v $PWD:/config lansible/git-clone \
clone --depth 1 https://github.com/LANsible/git-container.git /config
```

# Examples

## Kubernetes init container for Home-Assistant

In the following examples an init container pulls a git repository into a shared emptyDir volume.

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: example
spec:
  initContainers:
    - image: lansible/git-clone:latest
      name: init-config
      command: ['--depth 1 https://github.com/wilmardo/home-assistant.git /config']
      volumeMounts:
        - mountPath: /config
          name: config
  containers:
    - image: main/main-container
      name: main-container
      volumeMounts:
        - mountPath: /config
          name: config
  volumes:
    - name: config
      emptyDir: {}
```