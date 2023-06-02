Main.yamlfilename: Terraform Deployment
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main


jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v2

    - name: Set up Terraform
      uses: hashicorp/setup-terraform@v1

    - name: Configure Google Cloud credentials
      uses: google-github-actions/setup-gcloud@v0
      with:
        project_id: ninth-beacon-388117
        service_account_key: ${{ secrets.GOOGLE_CRED }}
        export_default_credentials: true

    - name: Initialize Terraform
      run: terraform init

    - name: Terraform Plan
      run: terraform plan -out=tfplan
      
    - name: Terraform import
      run: export TF_VAR_my_google_cred=$GOOGLE_CRED

    - name: Terraform import
      run: export TF_VAR_my_secret_pub=$SSH_PUBLIC_KEY
      
    - name: Terraform import
      run: export TF_VAR_my_secret_pvt=$SSH_PVT_KEY

    - name: Terraform Apply
      run: terraform apply tfplan
      env:
        TF_VAR_project_id: ninth-beacon-388117
