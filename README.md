# 🚀 Application Deployment Assignment

## 📌 Problem Statement
Deploy the given React application to a **production-ready state**.

### Application:
- Clone the repo and deploy the app on port **80 (HTTP)**  
- Repo URL: [https://github.com/sriram-R-krishnan/devops-build](https://github.com/sriram-R-krishnan/devops-build)

---

## 🛠️ Prerequisites
Before starting, make sure you have:

- **GitHub account** (for version control)  
- **Docker & Docker Compose** installed (for containerization)  
- **Docker Hub account** (to store images)  
- **Jenkins server** installed (local or EC2)  
- **AWS account** (for EC2 deployment)  
- **Basic Linux knowledge**  

---

## 📂 Project Structure
These are the required files for the project:

```
.
├── Dockerfile
├── docker-compose.yml
├── build.sh
├── deploy.sh
├── Jenkinsfile
└── devops-build/
    └── nginx.conf
```
## Step 1: Clone the Repository

```bash
git clone https://github.com/sriram-R-krishnan/devops-build
cd devops-build
```
***
## Step 2: Dockerize the React Application

Create and verify the following files:
### Dockerfile (root directory)

```Dockerfile
FROM nginx:alpine
COPY build/ /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget -qO- http://127.0.0.1/ || exit 1
CMD ["nginx", "-g", "daemon off;"]
```

### `.dockerignore`

```
node_modules
build
.git
.gitignore
Dockerfile
*.md
*.log
```

### `.gitignore`

```
node_modules/
build/
.env
docker-compose.yml
*.log
```

***

## Step 3: Docker Compose Setup

Create `docker-compose.yml` (root directory):

```yaml
version: '3'
services:
  react-app:
    build: .
    ports:
      - "80:80"
```

***

## Step 4: Build and Deploy Scripts

### 1. `build.sh`

```bash
#!/bin/bash
# build.sh - Build and push Docker image based on Git branch

# Login to Docker Hub securely using environment variables
echo "$DOCKER_HUB_PASSWORD" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin
BRANCH_NAME=${BRANCH_NAME:-$(git rev-parse --abbrev-ref HEAD)}
IMAGE_NAME="yourdockerhubusername/devops-build"  # Replace with your DockerHub username and repo

if [ "$BRANCH" == "dev" ]; then
  # Build dev tag image
  docker build -t ${IMAGE_NAME}:dev .
  # Push to DockerHub dev repo
  docker push ${IMAGE_NAME}:dev
elif [ "$BRANCH" == "master" ]; then
  # Build prod tag image
  docker build -t ${IMAGE_NAME}:prod .
  # Push to DockerHub prod repo
  docker push ${IMAGE_NAME}:prod
else
  echo "Branch $BRANCH is not configured for image push."
fi
```

> **IMPORTANT:**
> Replace `yourdockerhubusername` with your actual Docker Hub username.
> Set `DOCKER_HUB_USERNAME` and `DOCKER_HUB_PASSWORD` as environment variables on your local machine or CI environment before running this script, for example:
> ```bash > export DOCKER_HUB_USERNAME=yourusername > export DOCKER_HUB_PASSWORD=yourtoken > ```

### 2. `deploy.sh`

```bash
#!/bin/bash
# deploy.sh - Deploy the Docker Compose application

docker-compose down
docker-compose up -d --build
```


***

## Step 5: Git Version Control

Ensure `.gitignore` is added as above.

Commit and push on the `dev` branch for development:

```bash
git checkout -b dev
git add .
git commit -m "Dockerize app with build and deploy scripts"
git push origin dev
```

***

## Step 6: Docker Hub Setup
We need **2 repositories** in Docker Hub:
- `devops-build-dev` → Public (for development images)
- `devops-build-prod` → Private (for production images)

### Steps:
1. Go to [https://hub.docker.com/](https://hub.docker.com/) and log in.
2. Click **Repositories → Create Repository**.
3. For Dev repo:
   - Name: `devops-build-dev`
   - Visibility: Public
   - Description: "Dev images for CI/CD pipeline"
   - Click **Create**
4. For Prod repo:
   - Name: `devops-build-prod`
   - Visibility: Private
   - Description: "Production images for CI/CD pipeline"
   - Click **Create**

👉 Now, images from **dev branch** will go to the dev repo, and images from **main/master branch** will go to the prod repo.

***

## Step 7: Jenkins Pipeline Setup
Jenkins automates build → push → deploy whenever we push code to GitHub.
### Part A: Install Plugins
1. Open Jenkins → **Manage Jenkins → Plugins**.
2. Install these plugins:
   - Docker Pipeline
   - GitHub Integration Plugin
   - Pipeline

### Part B: Add Credentials
1. Go to **Manage Jenkins → Credentials → Global Credentials**.
2. Add:
   - ID: `dockerhub-username` → Docker Hub username
   - ID: `dockerhub-password` → Docker Hub password/token
   - ID: `ec2-host-ip` → Secret text containing EC2 Public IP

### Part C: Connect GitHub Repo
1. Create a new Jenkins item → **Pipeline project**.
2. Under Pipeline definition → choose *Pipeline script from SCM*.
3. SCM: Git → enter your GitHub repo URL.
4. Branches: `*/dev` and `*/master`.

👉 Now Jenkins will auto-trigger on each `git push`.
3. **Add a pipeline job** with this Jenkinsfile in your repo:
```groovy
pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-id')  // Replace with your Jenkins credential ID
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        // Run build.sh which handles docker login, build, and push
        sh './build.sh'
      }
    }

    stage('Deploy Application') {
      steps {
        // Deploy with docker-compose
        sh './deploy.sh'
      }
    }
  }

  triggers {
    githubPush()  // Auto-trigger pipeline on GitHub push
  }
}
```
### Part D: GitHub Webhook
1. In GitHub repo → **Settings → Webhooks → Add webhook**.
2. Payload URL:
   ```
   http://<YOUR_JENKINS_PUBLIC_IP>:8080/github-webhook/
   ```
3. Content type: `application/json`
4. Trigger: Push events
5. Save ✅

5. Now, pushing code to `dev` will build and push dev-tagged Docker images; merging `dev` to `master` will push prod-tagged images.

***

## Step 8: AWS EC2 Deployment

1. Launch a t2.micro EC2 instance with Ubuntu.
2. SSH into the instance.
3. Install Docker \& Docker Compose.
```bash
sudo apt update
sudo apt install docker.io docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

4. Configure Security Group for:
    - Port 80 open to 0.0.0.0/0 (for HTTP)
    - Port 22 open only to your public IP (SSH)
5. Clone your GitHub repo:
```bash
git clone https://github.com/yourusername/devops-build.git
cd devops-build
```

6. Run deployment:
```bash
./deploy.sh
```

7. Access the application via the EC2 public IP or DNS on HTTP port 80.

***

## Step 9: Monitoring Setup (Optional but Recommended)

Install an open-source monitoring tool like Uptime Kuma using Docker:

```bash
docker run -d --restart=always -p 3001:3001 --name uptime-kuma louislam/uptime-kuma
```

Access the monitoring UI at `http://your-ec2-ip:3001`. Configure a monitor for your app URL and notifications (Slack/Email) to alert if the app goes down.

***

## Submission Checklist
## ✅ Checklist
- [ ] Repo cloned & dockerized  
- [ ] Images built & pushed (dev + prod)  
- [ ] Jenkins pipeline running  
- [ ] EC2 deployed  
- [ ] Monitoring added  
- [ ] Screenshots collected  

***

## Notes

- Always export your Docker Hub credentials as environment variables to avoid hardcoding secrets.
- Use Jenkins credentials plugin to securely store Docker Hub credentials for CI/CD.
- Adjust image names and tags as needed in `build.sh` and Jenkinsfile.
- The deploy script and Docker Compose currently run on the same instance as Jenkins. For scaling, consider separate instances or agents.

---

🎉 Congrats! You’ve successfully built a **CI/CD pipeline with Docker, Jenkins, AWS & Monitoring**.



---

This will guide you smoothly through the project from cloning to production deployment.

