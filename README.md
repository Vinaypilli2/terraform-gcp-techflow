# terraform-gcp-techflow
Terraform for GCP
--------installation of gcloud--------------------
# Update packages
sudo apt-get update

# Install required dependencies
sudo apt-get install -y apt-transport-https ca-certificates gnupg curl

# Add Google Cloud SDK repo
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Add GPG key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Install gcloud CLI
sudo apt-get update && sudo apt-get install -y google-cloud-cli


login 
gcloud auth login --no-launch-browser --update-adc

gcloud config set project techflow-dev

gcloud auth application-default set-quota-project techflow-dev


verify 

gcloud config list 

gcloud projects list 