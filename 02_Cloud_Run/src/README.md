# Create a Docker image and deploy to Cloud Run.

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
```

Push docker image to remote repository
```
docker push us-east1-docker.pkg.dev/playground-s-11-49aa7182/docker-repo/helloworld
```

Deploy using Cloud Run
```
gcloud run deploy helloworld --image us-east1-docker.pkg.dev/playground-s-11-49aa7182/docker-repo/helloworld 
```

# Create a Docker image and deploy to Cloud Run.

Deploy revision 1 "Alpha"
```
gcloud run deploy helloworld --image us-east1-docker.pkg.dev/playground-s-11-c867dfeb/docker-repo/helloworld --set-env-vars name=alpha
```

Deploy revision 2 "Beta"
```
gcloud run deploy helloworld --image us-east1-docker.pkg.dev/playground-s-11-c867dfeb/docker-repo/helloworld --set-env-vars name=beta
```

List revisions
```
gcloud run revisions list

# Output:
   REVISION              ACTIVE  SERVICE     DEPLOYED                 DEPLOYED BY
✔  helloworld-00002-gur  yes     helloworld  2020-12-05 09:36:22 UTC  dennislee 
✔  helloworld-00001-xox  yes     helloworld  2020-12-05 09:31:57 UTC  dennislee
```

Show traffic distribution
```
gcloud run services describe helloworld
✔ Service helloworld in region us-east1
 
Traffic: https://helloworld-xka2wnouga-ue.a.run.app
  50% helloworld-00001-xox
  50% helloworld-00002-gur
 
Last updated on 2020-12-05T09:44:32.861240Z by dennislee
  Revision helloworld-00002-gur
  Image:         us-east1-docker.pkg.dev/playground-s-11-c867dfeb/docker-repo/helloworld
  Port:          8080
  Memory:        256Mi
  CPU:           1000m
  Env vars:
    name         beta
  Concurrency:   80
  Max Instances: 1000
  Timeout:       300s

```

Update traffic distribution
```
gcloud run services update-traffic helloworld --to-revisions helloworld-00002-gur=80,helloworld-00001-xox=20

# Output:
✓ Updating traffic... Done.                                                                                                                                              

  ✓ Routing traffic...                                                                                                                                                   
Done.                                                                                                                                                                    
Traffic: https://helloworld-xka2wnouga-ue.a.run.app
  20% helloworld-00001-xox
  80% helloworld-00002-gur
```
