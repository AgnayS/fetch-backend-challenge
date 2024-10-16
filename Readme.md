
# 🚀 Fetch Backend Challenge

## 🛠 Quick Setup

### 1. Prerequisites

- Install [Docker](https://www.docker.com/get-started)
- Install [Docker Compose](https://docs.docker.com/compose/install/)

Make sure you have both installed before continuing.

### 2. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/agnays/fetch-backend-challenge.git
cd fetch-backend-challenge
```

### 3. Build and Run the Project

Once inside the root project directory, use Docker Compose to build and run the containers:

```bash
docker-compose up --build
```

This will build the backend and frontend, and start the services.

### 4. Access the Application

- **Backend API**: The backend API will be available at `http://localhost:8000`.
- **Frontend**: The frontend interface will be available at `http://localhost:3000`.

You will see `0.0.0.0` in the Docker logs, but use `localhost` to access the services from your browser or API client.

---

## 🖥 Backend API

The backend is built with **Python** using **FastAPI**. It provides the following endpoints to manage points for users:

- **POST `/add`**: Adds points to a user's account from a specific payer.
- **POST `/spend`**: Allows users to spend their points, deducting the oldest points first.
- **GET `/balance`**: Returns the current balance of points per payer.
- **POST `/reset`**: Custom endpoint for testing, resets all transactions.

Example API requests:

```bash
# Add points
curl -X POST http://localhost:8000/add -H "Content-Type: application/json" -d '{"payer": "DANNON", "points": 1000, "timestamp": "2022-11-02T14:00:00Z"}'

# Spend points
curl -X POST http://localhost:8000/spend -H "Content-Type: application/json" -d '{"points": 5000}'

# Get balance
curl http://localhost:8000/balance
```

---

## 🌐 Frontend

The frontend is built using **Flutter Web** and communicates with the backend API to manage point transactions.

### Features:
- Add points to the user's account.
- Spend points based on the oldest transaction first.
- View the current balance of points from each payer.
- Reset all points for testing.

You can interact with the backend through the frontend UI, which runs on `http://localhost:3000`.

---

## 🧪 Testing the Application

You can test the application in two ways:
1. Using the **Frontend Interface** to interact with the API.
2. Using **API testing tools** like Postman or curl to make requests directly to the backend.

---

## 🛠 Technologies Used

- **Backend**: Python, FastAPI
- **Frontend**: Flutter, Dart
- **Containerization**: Docker, Docker Compose

---

## 📋 Project Structure

```
fetch-backend-challenge/
├── backend-api/
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── flutter-frontend/
│   ├── Dockerfile
│   ├── lib/
│   ├── pubspec.yaml
│   └── web/
├── docker-compose.yml
└── README.md
```
