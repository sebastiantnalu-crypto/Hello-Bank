from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_home():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["message"] == "Hello Bank is running!"

def test_balance_found():
    response = client.get("/balance/ACC001")
    assert response.status_code == 200
    assert response.json()["balance"] == 1000.00

def test_balance_not_found():
    response = client.get("/balance/NOTEXIST")
    assert response.json()["error"] == "Account not found"

def test_transfer():
    response = client.post("/transfer", json={
        "from_acc": "ACC001", "to_acc": "ACC002", "amount": 100.00
    })
    assert response.json()["status"] == "Transfer done"

def test_insufficient_funds():
    response = client.post("/transfer", json={
        "from_acc": "ACC002", "to_acc": "ACC001", "amount": 999999
    })
    assert response.json()["error"] == "Insufficient funds"