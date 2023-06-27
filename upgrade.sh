#!/bin/bash

# exit when any command fails
set -e

new_ver=$1
image_owner="sbcampbe"
image_base="nginx"
image_base_tag="1.25.1"
git_repo_url="git@github.com:sb-campbell/cicd-argocd-gitops-demo.git"
base_folder="example2-argocd-app-of-apps"

echo "new version: ${new_ver}"

# Simulate release of the new docker images
docker tag ${image_base}:${image_base_tag} ${image_owner}/${image_base}:${new_ver}

# Push new version to dockerhub
docker push ${image_owner}/${image_base}:${new_ver}

# Create temporary folder
tmp_dir=$(mktemp -d)
echo "tmp_dir: ${tmp_dir}"

# Clone GitHub repo
git clone ${git_repo_url} ${tmp_dir}

# Update image tag
# -i - update in place
# -e - script, or following command treated as a script
sed -i '' -e "s/${image_owner}\/${image_base}:.*/${image_owner}\/${image_base}:${new_ver}/g" ${tmp_dir}/${base_folder}/my-app-one/1-deployment.yaml
sed -i '' -e "s/${image_owner}\/${image_base}:.*/${image_owner}\/${image_base}:${new_ver}/g" ${tmp_dir}/${base_folder}/my-app-two/1-deployment.yaml

# Commit and push
cd $tmp_dir
git add .
git commit -m "Update image to $new_ver"
git push

# Optionally on build agents - remove folder
rm -rf $tmp_dir
