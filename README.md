# Bookstore Admin - CI/CD & Cloud Deployment Starter

## Introduction

This repository contains the starting codebase and in-class exercise for **[Lecture 4.0 CSD230 W26 : CI/CD and Cloud Deployment](#)** *(Link to your new Google Doc here)*.

**Please refer to the lecture document linked above for the complete, step-by-step instructions required to complete this DevOps exercise.**

### What this App Does
The Bookstore Admin application is a full-stack project featuring a Spring Boot REST API backend (connected to a MySQL database) and a React (Vite) frontend. It allows administrators to manage a digital bookstore inventory—including adding, editing, and deleting books and magazines—and simulates a shopping cart experience. It is fully secured using JSON Web Tokens (JWT).

### Objective for this Module
In this exercise, we take this working local application and transition it to a production-ready cloud environment. You will learn the fundamentals of DevOps by completing the following steps:
1. **Configuration Management:** Externalizing database credentials using Environment Variables.
2. **Containerization:** Writing a multi-stage `Dockerfile` to package the React frontend and Spring Boot backend into a single, immutable artifact.
3. **Continuous Integration (CI):** Setting up **GitHub Actions** to automatically build and test your code every time you push to the repository.
4. **Continuous Deployment (CD):** Connecting your GitHub repository to a cloud hosting platform (e.g., Render) to automatically deploy your application to the live internet.

---

## Local Development: Running the Application

Before deploying to the cloud, ensure the application runs correctly on your local machine. 

### **Prerequisites**
Before starting either side of the application, ensure your local MySQL database is running via Docker:
```bash
docker-compose up -d
```

---

### **Option 1: Running from the Command Line (CLI)**

#### **Backend (Spring Boot)**
Open a terminal in the **root** folder of the project:
*   **Windows:**
    ```cmd
    mvnw.cmd spring-boot:run
    ```
*   **macOS / Linux:**
    ```bash
    ./mvnw spring-boot:run
    ```

#### **Frontend (React/Vite)**
Open a second terminal window and navigate to the `frontend` folder:
```bash
cd frontend
npm install   # Only needed the first time
npm run dev
```

---

### **Option 2: Running from IntelliJ IDEA**

#### **Backend (Spring Boot)**
1.  Open the **root project folder** in IntelliJ.
2.  In the Project window, navigate to: `src/main/java/csd230/bookstore/Application.java`.
3.  Right-click the `Application` class and select **Run 'Application'**.
4.  Alternatively, open the **Maven** tool window (usually on the right), expand `Application > Plugins > spring-boot`, and double-click `spring-boot:run`.
5.  The API server will start on `http://localhost:8080`.

#### **Frontend (React/Vite)**
1.  Open the **`frontend` sub-folder** in a separate IntelliJ window.
2.  Open the `package.json` file.
3.  Look for the `"scripts"` section and click the **green Play button** in the gutter next to the `"dev": "vite"` line.
4.  Select **Run 'dev'**.
5.  Check the **Terminal** tab at the bottom of IntelliJ to see the local URL (usually `http://localhost:5173/`). Open this URL in your browser.
