```
export PROJECT_ID=`gcloud config get-value project`
export PROJECT_NUMBER=$(gcloud projects list --filter project_id=`gcloud config get-value project` --format 'value(projectNumber)')

gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable serviceusage.googleapis.com

gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" --role 'roles/editor'
```
