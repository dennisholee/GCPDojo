Authenticate gcloud SDK with GCP project account.
```Bash
gcloud auth login
```

Create Google Repository to store docker image
```Bash
gcloud artifacts repositories create docker-repo --repository-format=docker --location us-east1
```

Set gcloud sdk project
```
gcloud config set project playground-s-11-49aa7182
```

Create docker repo in GCP artifacts
```
gcloud artifacts repositories create docker-repo --repository-format=docker --location us-east1
```

Authenticate docker against new docker repo
```
gcloud auth configure-docker us-east1-docker.pkg.dev
```

Build local docker image
```
docker build . -t local/helloworld
```

Tag local image to remote repository
```
docker tag local/helloworld us-east1-docker.pkg.dev/playground-s-11-49aa7182/docker-repo/helloworld
````

Push docker image to remote repository
```
docker push us-east1-docker.pkg.dev/playground-s-11-49aa7182/docker-repo/helloworld
```

Deploy using Cloud Run
```
gcloud run deploy helloworld --image us-east1-docker.pkg.dev/playground-s-11-49aa7182/docker-repo/helloworld 
```
